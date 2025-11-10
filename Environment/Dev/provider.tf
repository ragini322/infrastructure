terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.0.1"
    }
     random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  subscription_id = "b1b957bb-e1e5-4b27-9d96-43a97ee9b891"
  features {}
}
provider "random" {}