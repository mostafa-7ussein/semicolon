resource "azurerm_storage_account" "semi-colonstorageac" {
  name                     = "semicolonstorageac"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "semi-colon-storage-cont" {
  name                  = "semi-colon-storage-cont"
  storage_account_name  = azurerm_storage_account.semi-colonstorageac.name
  container_access_type = "private"
}