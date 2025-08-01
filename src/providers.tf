# Configure the Azure Provider
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115.0"
    }
    
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# Configure the Azure Provider features
provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

provider "azuread" {}

provider "random" {}