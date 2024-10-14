resource "azurerm_resource_group" "semi-colon_aks_group" {
  name     = local.resource_group
  location = local.location
}