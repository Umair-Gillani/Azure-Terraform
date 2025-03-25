############################################
# 5) Outputs
############################################
output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "public_subnet_name" {
  description = "Public Subnet name"
  value       = azurerm_subnet.public.name
}

output "aks_subnet_name" {
  description = "AKS Subnet name"
  value       = azurerm_subnet.aks.name
}

output "db_subnet_name" {
  description = "DB Subnet name"
  value       = azurerm_subnet.db.name
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = azurerm_subnet.public.id
}

output "aks_subnet_id" {
  description = "AKS Subnet ID"
  value       = azurerm_subnet.aks.id
}

output "db_subnet_id" {
  description = "DB Subnet ID"
  value       = azurerm_subnet.db.id
}
