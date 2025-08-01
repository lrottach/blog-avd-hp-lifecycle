# Resource Group Configuration
variable "resource_group_name" {
  description = "Name of the resource group where session hosts will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "West Europe"
}

# Networking Configuration
variable "existing_vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "existing_vnet_resource_group" {
  description = "Resource group name of the existing virtual network"
  type        = string
}

variable "existing_subnet_name" {
  description = "Name of the existing subnet where session hosts will be deployed"
  type        = string
}

# Azure Compute Gallery Configuration
variable "gallery_name" {
  description = "Name of the Azure Compute Gallery containing the image"
  type        = string
}

variable "gallery_resource_group" {
  description = "Resource group name of the Azure Compute Gallery"
  type        = string
}

variable "gallery_image_name" {
  description = "Name of the image definition in the gallery"
  type        = string
}

variable "gallery_image_version" {
  description = "Version of the image to use (e.g., 1.2.0)"
  type        = string
}

# Session Host Configuration
variable "session_host_count" {
  description = "Number of session hosts to deploy"
  type        = number
  default     = 2
  
  validation {
    condition     = var.session_host_count > 0 && var.session_host_count <= 100
    error_message = "Session host count must be between 1 and 100."
  }
}

variable "session_host_size" {
  description = "Size of the session host VMs (must support Trusted Launch and Encryption at Host)"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "admin_username" {
  description = "Local administrator username for the session hosts"
  type        = string
  default     = "avdadmin"
}

variable "admin_password" {
  description = "Local administrator password for the session hosts"
  type        = string
  sensitive   = true
}

# Azure Virtual Desktop Configuration
variable "hostpool_name" {
  description = "Name of the existing AVD host pool"
  type        = string
}

variable "hostpool_resource_group" {
  description = "Resource group name of the existing AVD host pool"
  type        = string
}

variable "host_pool_registration_token" {
  description = "Registration token for the AVD host pool"
  type        = string
  sensitive   = true
}

# Tagging
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    ManagedBy   = "Terraform"
    Purpose     = "AVD-Blog-Post"
  }
}