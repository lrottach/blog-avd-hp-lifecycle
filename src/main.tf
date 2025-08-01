# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source for existing virtual network
data "azurerm_virtual_network" "existing" {
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_resource_group
}

# Data source for existing subnet
data "azurerm_subnet" "existing" {
  name                 = var.existing_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_resource_group
}

# Data source for the gallery image
data "azurerm_shared_image_version" "avd" {
  name                = var.gallery_image_version
  image_name          = var.gallery_image_name
  gallery_name        = var.gallery_name
  resource_group_name = var.gallery_resource_group
}

# Create a clean version string for hostname (remove dots)
locals {
  # Replace dots with empty string to create valid Windows hostname
  clean_version = replace(var.gallery_image_version, ".", "")

  # Ensure hostname doesn't exceed 15 characters
  # Format: avd-sh-vXXX-NNN (where XXX is version, NNN is index)
  hostname_prefix = "avd-sh-v${local.clean_version}"
}

# Network Security Group for Session Hosts
resource "azurerm_network_security_group" "session_hosts" {
  name                = "nsg-avd-session-hosts"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Network Interfaces for Session Hosts
resource "azurerm_network_interface" "session_hosts" {
  count               = var.session_host_count
  name                = "nic-${local.hostname_prefix}-${format("%03d", count.index + 1)}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Associate NSG with Network Interfaces
resource "azurerm_network_interface_security_group_association" "session_hosts" {
  count                     = var.session_host_count
  network_interface_id      = azurerm_network_interface.session_hosts[count.index].id
  network_security_group_id = azurerm_network_security_group.session_hosts.id
}

# Session Host Virtual Machines
resource "azurerm_windows_virtual_machine" "session_hosts" {
  count               = var.session_host_count
  name                = "${local.hostname_prefix}-${format("%03d", count.index + 1)}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  size                = var.session_host_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  # Distribute VMs across availability zones
  zone = tostring((count.index % 3) + 1)

  # Enable encryption at host
  encryption_at_host_enabled = true

  # Enable Trusted Launch
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Configure OS disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"

    # Enable disk encryption
    disk_encryption_set_id = null # Using platform-managed keys
  }

  # Source image from Azure Compute Gallery
  source_image_id = data.azurerm_shared_image_version.avd.id

  # Network configuration
  network_interface_ids = [
    azurerm_network_interface.session_hosts[count.index].id
  ]

  # Boot diagnostics
  boot_diagnostics {
    storage_account_uri = null # Use managed storage account
  }

  # Enable system-assigned managed identity for Entra ID join
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    "AVD-Version" = var.gallery_image_version
    "AVD-Index"   = format("%03d", count.index + 1)
  })
}

# Entra ID Join Extension
resource "azurerm_virtual_machine_extension" "aad_join" {
  count                      = var.session_host_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_hosts[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    mdmId = ""
  })

  tags = var.tags
}

# Guest Attestation Extension for Trusted Launch
resource "azurerm_virtual_machine_extension" "guest_attestation" {
  count                      = var.session_host_count
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_hosts[count.index].id
  publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AttestationConfig = {
      MaaSettings = {
        maaEndpoint                 = ""
        maaTenantName               = "GuestAttestation"
        maaAttestationPolicyContent = ""
      }
      AscSettings = {
        ascReportingEndpoint  = ""
        ascReportingFrequency = ""
      }
      useCustomToken = false
      disableAlerts  = false
    }
  })

  tags = var.tags
}

# AVD Host Pool Registration
resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count                      = var.session_host_count
  name                       = "Microsoft.PowerShell.DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_hosts[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_11-22-2022.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName          = var.hostpool_name
      ResourceGroupName     = var.hostpool_resource_group
      RegistrationInfoToken = var.host_pool_registration_token
      Aadjoined             = true
    }
  })

  protected_settings = jsonencode({
    properties = {
      RegistrationInfoToken = var.host_pool_registration_token
    }
  })

  depends_on = [
    azurerm_virtual_machine_extension.aad_join,
    azurerm_virtual_machine_extension.guest_attestation
  ]

  tags = var.tags
}
