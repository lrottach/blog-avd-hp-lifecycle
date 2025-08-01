# Module: Session Hosts - Outputs

output "vm_names" {
  description = "Names of the deployed virtual machines"
  value       = [for vm in azurerm_windows_virtual_machine.this : vm.name]
}

output "vm_ids" {
  description = "Resource IDs of the deployed virtual machines"
  value       = [for vm in azurerm_windows_virtual_machine.this : vm.id]
}

output "private_ip_addresses" {
  description = "Private IP addresses of the session hosts"
  value       = [for nic in azurerm_network_interface.this : nic.private_ip_address]
}

output "availability_zones" {
  description = "Availability zones where VMs are deployed"
  value       = [for vm in azurerm_windows_virtual_machine.this : vm.zone]
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.this.id
}

output "managed_identity_ids" {
  description = "System-assigned managed identity IDs"
  value       = [for vm in azurerm_windows_virtual_machine.this : vm.identity[0].principal_id]
}