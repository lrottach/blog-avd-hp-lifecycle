# Azure Virtual Desktop Session Hosts Deployment
# This configuration uses the session-hosts module to deploy AVD session hosts

# Data source for existing resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Deploy networking infrastructure
module "networking" {
  source = "./modules/networking"

  name_prefix = var.network_name_prefix
  location    = var.location

  # Optional overrides (if provided)
  network_resource_group_name = var.network_resource_group_name
  vnet_name                   = var.vnet_name
  vnet_address_space          = var.vnet_address_space
  subnet_name                 = var.subnet_name
  subnet_address_prefix       = var.subnet_address_prefix

  tags = var.tags
}

# Data source for the gallery image
data "azurerm_shared_image_version" "avd" {
  name                = var.gallery_image_version
  image_name          = var.gallery_image_name
  gallery_name        = var.gallery_name
  resource_group_name = var.gallery_resource_group
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
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  # Network configuration
  subnet_id = module.networking.subnet_id

  # Gallery image configuration
  gallery_image_id      = data.azurerm_shared_image_version.avd.id
  gallery_image_version = var.gallery_image_version

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