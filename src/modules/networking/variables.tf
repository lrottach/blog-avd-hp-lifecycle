# Module: Networking - Input Variables

variable "name_prefix" {
  description = "Prefix for resource naming (e.g., 'avd-demo' creates 'vnet-avd-demo')"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for networking resources"
  type        = string
}

variable "location" {
  description = "Azure region where networking resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "Optional name override for the virtual network (default: vnet-{name_prefix})"
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
  description = "Optional name override for the session hosts subnet (default: snet-{name_prefix}-sessionhosts)"
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

variable "tags" {
  description = "Tags to apply to all networking resources"
  type        = map(string)
  default     = {}
}
