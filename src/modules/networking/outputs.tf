# Module: Networking - Outputs

output "resource_group_name" {
  description = "Name of the network resource group"
  value       = var.resource_group_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_id" {
  description = "ID of the session hosts subnet"
  value       = azurerm_subnet.session_hosts.id
}

output "subnet_name" {
  description = "Name of the session hosts subnet"
  value       = azurerm_subnet.session_hosts.name
}

output "subnet_address_prefix" {
  description = "Address prefix of the session hosts subnet"
  value       = azurerm_subnet.session_hosts.address_prefixes[0]
}
