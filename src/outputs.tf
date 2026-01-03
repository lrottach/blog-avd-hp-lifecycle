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
    trusted_launch     = true
    secure_boot        = true
    vtpm               = true
    encryption_at_host = true
    entra_id_joined    = true
    guest_attestation  = true
  }
}

# Image Information
output "image_details" {
  description = "Details of the marketplace image used for deployment"
  value = {
    publisher = var.marketplace_image_publisher
    offer     = var.marketplace_image_offer
    sku       = var.marketplace_image_sku
    version   = var.marketplace_image_version
  }
}

# Network Information
output "network_resource_group_name" {
  description = "Name of the network resource group"
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = module.networking.vnet_address_space
}

output "subnet_id" {
  description = "ID of the subnet where session hosts are deployed"
  value       = module.networking.subnet_id
}

output "subnet_name" {
  description = "Name of the session hosts subnet"
  value       = module.networking.subnet_name
}

output "subnet_address_prefix" {
  description = "Address prefix of the session hosts subnet"
  value       = module.networking.subnet_address_prefix
}

output "network_security_group_id" {
  description = "ID of the network security group for session hosts"
  value       = module.session_hosts.network_security_group_id
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