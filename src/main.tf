# Azure Virtual Desktop Session Hosts Deployment
# This configuration uses the session-hosts module to deploy AVD session hosts

# Local variables for resource group naming
locals {
  network_resource_group_name = var.network_resource_group_name != null ? var.network_resource_group_name : "rg-${var.network_name_prefix}-network"
}

# Resource Group for Session Hosts
resource "azurerm_resource_group" "session_hosts" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Resource Group for Networking
resource "azurerm_resource_group" "network" {
  name     = local.network_resource_group_name
  location = var.location
  tags     = var.tags
}

# Deploy networking infrastructure
module "networking" {
  source = "./modules/networking"

  name_prefix         = var.network_name_prefix
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  # Optional overrides (if provided)
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  subnet_name           = var.subnet_name
  subnet_address_prefix = var.subnet_address_prefix

  tags = var.tags
}

# Data source to get existing host pool
data "azurerm_virtual_desktop_host_pool" "avd" {
  name                = var.hostpool_name
  resource_group_name = var.hostpool_resource_group
}

# Generate registration token with dynamic expiration
resource "azurerm_virtual_desktop_host_pool_registration_info" "avd" {
  hostpool_id     = data.azurerm_virtual_desktop_host_pool.avd.id
  expiration_date = timeadd(timestamp(), "4h") # Token valid for 4 hours
}

# Deploy session hosts using the module
module "session_hosts" {
  source = "./modules/session-hosts"

  # Core configuration
  resource_group_name = azurerm_resource_group.session_hosts.name
  location            = azurerm_resource_group.session_hosts.location

  # Network configuration
  subnet_id = module.networking.subnet_id

  # Marketplace image configuration
  image_publisher = var.marketplace_image_publisher
  image_offer     = var.marketplace_image_offer
  image_sku       = var.marketplace_image_sku
  image_version   = var.marketplace_image_version
  vm_name_suffix  = var.vm_name_suffix

  # Session host configuration
  session_host_count = var.session_host_count
  session_host_size  = var.session_host_size
  admin_username     = var.admin_username
  admin_password     = var.admin_password

  # AVD host pool configuration
  hostpool_name                = var.hostpool_name
  hostpool_resource_group      = var.hostpool_resource_group
  host_pool_registration_token = azurerm_virtual_desktop_host_pool_registration_info.avd.token

  # Naming and tagging
  name_prefix = "avd"
  tags        = var.tags
}