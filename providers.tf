terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">=1.1.0"

  backend "azurerm" {
    resource_group_name = "rg-tfstorage"
    storage_account_name = "tfbootcampstorageaccount"
    container_name = "tfstoragecontainer"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
