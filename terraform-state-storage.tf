resource "azurerm_resource_group" "rg-tfstorage" {
  name     = "rg-tfstorage"
  location = "East US"
}

resource "azurerm_storage_account" "storage-account-tfstate" {
  name                     = "tfbootcampstorageaccount"
  resource_group_name      = azurerm_resource_group.rg-tfstorage.name
  location                 = azurerm_resource_group.rg-tfstorage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstoragecontainer" {
  name                  = "tfstoragecontainer"
  storage_account_name  = azurerm_storage_account.storage-account-tfstate.name
  container_access_type = "blob"
}