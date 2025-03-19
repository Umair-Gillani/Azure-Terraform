output "rg_name" {
  description = "Resource Group Name"
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = module.aks.aks_name
}

output "acr_name" {
  description = "ACR Name"
  value       = module.acr.acr_name
}

output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = module.bastion_host.public_ip
}

output "db_server_name" {
  description = "Database Server Name"
  value       = module.database.db_server_name
}
