resource "azurerm_mysql_server" "this" {
  name                = var.db_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Try to pick a minimal, free-tier friendly SKU if available
  sku_name            = "B_Gen5_1"

  storage_mb          = 5120
  version             = "5.7"
  administrator_login = var.admin_username
  administrator_login_password = var.admin_password

  ssl_enforcement_enabled = false
  infrastructure_encryption_enabled = false

  tags = var.tags
}

# MySQL DB firewall to allow only within the VNet, or specifically from the AKS subnet
# Alternatively, you can do Private Endpoint. For simplicity, let's do VNet-based rule:
# For real production, you'd consider Service Endpoints or Private Link.
resource "azurerm_mysql_virtual_network_rule" "aks_vnet_rule" {
  name                = "allow-aks-subnet"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.this.name
  subnet_id           = var.db_subnet_id
}

output "db_server_name" {
  value = azurerm_mysql_server.this.fqdn
}
