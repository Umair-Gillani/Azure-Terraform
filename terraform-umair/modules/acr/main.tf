resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = true
  tags                = var.tags
}

output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "acr_id" {
  value = azurerm_container_registry.this.id
}
