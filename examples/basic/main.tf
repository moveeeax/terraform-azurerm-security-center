terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.30, < 6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "security_center" {
  source = "../.."

  resource_types = {
    VirtualMachines = "Standard"
    StorageAccounts = "Standard"
  }

  contact = {
    name  = "security-team"
    email = "security@example.com"
    phone = "+1-555-0100"
  }
}

output "pricing_ids" {
  value = module.security_center.pricing_ids
}
