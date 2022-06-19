
resource "azurerm_resource_group" "tf" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags = {
    "key" = "rg-weight-tracker"
  }
}

resource "random_password" "password" {
  length  = 16
  special = false
}