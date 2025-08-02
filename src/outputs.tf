# Session Host Information
output "session_host_names" {
  description = "Names of the deployed session hosts"
  value       = module.session_hosts.vm_names
}

output "session_host_ids" {
  description = "Resource IDs of the deployed session hosts"
  value       = module.session_hosts.vm_ids
}

output "session_host_private_ips" {
  description = "Private IP addresses of the session hosts"
  value       = module.session_hosts.private_ip_addresses
}

output "session_host_zones" {
  description = "Availability zones of the session hosts"
  value       = module.session_hosts.availability_zones
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
  value       = module.session_hosts.network_security_group_id
}

output "subnet_id" {
  description = "ID of the subnet where session hosts are deployed"
  value       = data.azurerm_subnet.existing.id
}

# Managed Identity Information
output "managed_identity_ids" {
  description = "System-assigned managed identity IDs of the session hosts"
  value       = module.session_hosts.managed_identity_ids
}

# Host Pool Registration Information
output "registration_token_expiry" {
  description = "Expiration date of the generated host pool registration token"
  value       = azurerm_virtual_desktop_host_pool_registration_info.avd.expiration_date
}