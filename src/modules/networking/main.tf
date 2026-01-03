# Module: Networking - Main Configuration

locals {
  # Generate default resource names based on name_prefix
  resource_group_name = var.network_resource_group_name != null ? var.network_resource_group_name : "rg-${var.name_prefix}-network"
  vnet_name           = var.vnet_name != null ? var.vnet_name : "vnet-${var.name_prefix}"
  subnet_name         = var.subnet_name != null ? var.subnet_name : "snet-${var.name_prefix}-sessionhosts"
}

# Resource Group for Networking
resource "azurerm_resource_group" "network" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Subnet for Session Hosts
resource "azurerm_subnet" "session_hosts" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_address_prefix]
}
