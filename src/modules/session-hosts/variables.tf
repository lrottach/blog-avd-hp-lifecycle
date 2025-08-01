# Module: Session Hosts - Input Variables

variable "resource_group_name" {
  description = "Name of the resource group where session hosts will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where session hosts will be deployed"
  type        = string
}

variable "gallery_image_id" {
  description = "ID of the shared image version to use"
  type        = string
}

variable "gallery_image_version" {
  description = "Version string of the image (used for naming)"
  type        = string
}

variable "session_host_count" {
  description = "Number of session hosts to deploy"
  type        = number
}

variable "session_host_size" {
  description = "Size of the session host VMs"
  type        = string
}

variable "admin_username" {
  description = "Local administrator username"
  type        = string
}

variable "admin_password" {
  description = "Local administrator password"
  type        = string
  sensitive   = true
}

variable "hostpool_name" {
  description = "Name of the AVD host pool"
  type        = string
}

variable "hostpool_resource_group" {
  description = "Resource group of the AVD host pool"
  type        = string
}

variable "host_pool_registration_token" {
  description = "Registration token for the AVD host pool"
  type        = string
  sensitive   = true
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "avd"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}