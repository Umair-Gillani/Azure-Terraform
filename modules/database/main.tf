########################################
# modules/database/main.tf
########################################

/*

resource "azurerm_mysql_flexible_server" "this" {
  name                   = var.db_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password

  sku_name               = var.db_sku_name
  version                = var.db_version
  storage_mb             = var.db_storage_mb

  backup_retention_days       = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # Free-tier doesn't allow HA, so we disable
  high_availability {
    mode = "Disabled"
  }

  publicly_accessible = var.publicly_accessible

  # If the user provides a subnet ID, then use a delegated subnet approach
  dynamic "network" {
    for_each = var.db_subnet_id != null ? [var.db_subnet_id] : []
    content {
      delegated_subnet_id = network.value
    }
  }

  tags = var.tags
}

# Example output
output "db_server_fqdn" {
  description = "FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.this.fqdn
}


*/