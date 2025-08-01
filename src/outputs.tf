# Session Host Information
output "session_host_names" {
  description = "Names of the deployed session hosts"
  value       = [for vm in azurerm_windows_virtual_machine.session_hosts : vm.name]
}

output "session_host_ids" {
  description = "Resource IDs of the deployed session hosts"
  value       = [for vm in azurerm_windows_virtual_machine.session_hosts : vm.id]
}

output "session_host_private_ips" {
  description = "Private IP addresses of the session hosts"
  value       = [for nic in azurerm_network_interface.session_hosts : nic.private_ip_address]
}

output "session_host_zones" {
  description = "Availability zones of the session hosts"
  value       = [for vm in azurerm_windows_virtual_machine.session_hosts : vm.zone]
}

# Security Information
output "security_features" {
  description = "Security features enabled on session hosts"
  value = {
    trusted_launch      = true
    secure_boot         = true
    vtpm                = true
    encryption_at_host  = true
    entra_id_joined     = true
    guest_attestation   = true
  }
}

# Image Information
output "image_details" {
  description = "Details of the image used for deployment"
  value = {
    gallery_name    = var.gallery_name
    image_name      = var.gallery_image_name
    image_version   = var.gallery_image_version
    image_id        = data.azurerm_shared_image_version.avd.id
  }
}

# Network Information
output "network_security_group_id" {
  description = "ID of the network security group for session hosts"
  value       = azurerm_network_security_group.session_hosts.id
}

output "subnet_id" {
  description = "ID of the subnet where session hosts are deployed"
  value       = data.azurerm_subnet.existing.id
}