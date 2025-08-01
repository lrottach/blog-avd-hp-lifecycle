# Module: Session Hosts - Main Configuration

locals {
  # Clean version string for Windows hostname compatibility
  clean_version = replace(var.gallery_image_version, ".", "")
  
  # Hostname prefix with version
  hostname_prefix = "${var.name_prefix}-sh-v${local.clean_version}"
}

# Network Security Group
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.name_prefix}-session-hosts"
  location            = var.location
  resource_group_name = var.resource_group_name
  
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

# Network Interfaces
resource "azurerm_network_interface" "this" {
  count               = var.session_host_count
  name                = "nic-${local.hostname_prefix}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  
  tags = var.tags
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.session_host_count
  network_interface_id      = azurerm_network_interface.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Virtual Machines with Enhanced Security
resource "azurerm_windows_virtual_machine" "this" {
  count               = var.session_host_count
  name                = "${local.hostname_prefix}-${format("%03d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.session_host_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
  # Availability zone distribution
  zone = tostring((count.index % 3) + 1)
  
  # Security features
  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled              = true
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  source_image_id = var.gallery_image_id
  
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id
  ]
  
  boot_diagnostics {
    storage_account_uri = null
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = merge(var.tags, {
    "AVD-Version" = var.gallery_image_version
    "AVD-Index"   = format("%03d", count.index + 1)
  })
}

# Entra ID Join
resource "azurerm_virtual_machine_extension" "aad_join" {
  count                      = var.session_host_count
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
  
  settings = jsonencode({
    mdmId = ""
  })
  
  tags = var.tags
}

# Guest Attestation
resource "azurerm_virtual_machine_extension" "guest_attestation" {
  count                      = var.session_host_count
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
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

# AVD Registration
resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count                      = var.session_host_count
  name                       = "Microsoft.PowerShell.DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
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