# Module: Networking - Main Configuration

locals {
  # Generate default resource names based on name_prefix
  vnet_name   = var.vnet_name != null ? var.vnet_name : "vnet-${var.name_prefix}"
  subnet_name = var.subnet_name != null ? var.subnet_name : "snet-${var.name_prefix}-sessionhosts"
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Subnet for Session Hosts
resource "azurerm_subnet" "session_hosts" {
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_address_prefix]
}
