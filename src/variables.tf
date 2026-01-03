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
variable "network_name_prefix" {
  description = "Prefix for network resource names (e.g., 'avd-demo' creates 'vnet-avd-demo')"
  type        = string
  default     = "avd"
}

variable "network_resource_group_name" {
  description = "Name override for the network resource group (default: rg-{network_name_prefix}-network)"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "Name override for the virtual network (default: vnet-{network_name_prefix})"
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.vnet_address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "subnet_name" {
  description = "Name override for the session hosts subnet (default: snet-{network_name_prefix}-sessionhosts)"
  type        = string
  default     = null
}

variable "subnet_address_prefix" {
  description = "Address prefix for the session hosts subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_address_prefix, 0))
    error_message = "Subnet address prefix must be a valid CIDR notation."
  }
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