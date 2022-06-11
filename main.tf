terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  # Configure Terraform to persist terraform.tfstate into an Azure storage container
  backend "azurerm" {
    resource_group_name   = "tf_rg_blobstore"
    storage_account_name  = "tfstoragepraaline"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"    
  }
}

# Get the image build tag variable from Azure pipeline
variable "image_build_tag" {
  type = string
  description = "Latest build tag"
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "tf_test" {
    name     = "tfmainrg"
    location = "West Europe"
}

# Create a resource group
resource "azurerm_container_group" "tfcg_test" {
    name                = "weatherapi"
    location            = azurerm_resource_group.tf_test.location
    resource_group_name = azurerm_resource_group.tf_test.name

    ip_address_type     = "Public"
    dns_name_label      = "praalineweatherapi"
    os_type             = "Linux"

    container {
        name    = "weatherapi"
        image   = "praaline/weatherapi:${var.image_build_tag}"
        cpu     = "1"
        memory  = "1"
        ports {
           port     = 80
           protocol = "TCP"
        }
    }
}

