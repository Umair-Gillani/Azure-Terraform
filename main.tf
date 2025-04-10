##############################################
# main.tf (Root Module)
##############################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# If you plan to store the state in Azure, you can uncomment and fill these in,
# after creating the storage account once.
# backend "azurerm" {
#   resource_group_name  = var.state_rg_name
#   storage_account_name = var.state_sa_name
#   container_name       = var.state_container_name
#   key                  = "infrastructure.tfstate"
# }


provider "azurerm" {
  features {}
}

# ------------------------------------------------------------------------------
# 1. Resource Group
# ------------------------------------------------------------------------------
module "resource_group" {
  source   = "./modules/resource_group"
  location = var.location
  name     = var.rg_name
  tags     = var.default_tags
}





# ------------------------------------------------------------------------------
# 2. (Optional) Storage Account for Remote Backend
#    - If you want Terraform state in Azure, uncomment.
# ------------------------------------------------------------------------------
# module "storage_account_backend" {
#   source                = "./modules/storage_account_backend"
#   resource_group_name   = module.resource_group.name
#   location              = var.location
#   name                  = var.storage_account_name
#   container_name        = var.state_container_name
#   tags                  = var.default_tags
# }

# local "sa_name"        = module.storage_account_backend.storage_account_name
# local "rg_for_backend" = module.resource_group.name





# ------------------------------------------------------------------------------
# 3. Virtual Network and Subnets (Dynamic Subnets)
# ------------------------------------------------------------------------------
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = module.resource_group.name
  location            = var.location

  # VNet name + single base CIDR
  vnet_name = var.vnet_name
  vnet_cidr = var.vnet_cidr

  # Subnet names
  public_subnet_name = var.public_subnet_name
  aks_subnet_name    = var.aks_subnet_name
  db_subnet_name     = var.db_subnet_name

  tags = var.default_tags
}




# ------------------------------------------------------------------------------
# 4. Bastion Host in Public Subnet
# ------------------------------------------------------------------------------
module "bastion_host" {
  source              = "./modules/bastion"
  resource_group_name = module.resource_group.name
  location            = var.location

  bastion_name   = var.bastion_name
  vm_size        = var.bastion_vm_size
  admin_username = var.bastion_admin_username
  ssh_key        = var.bastion_ssh_key

  # Pass the subnet ID from the VNet module output
  subnet_id = module.vnet.public_subnet_id

  tags = var.default_tags
}



# ------------------------------------------------------------------------------
# 5. Azure Container Registry
# ------------------------------------------------------------------------------
module "acr" {
  source              = "./modules/acr"
  resource_group_name = module.resource_group.name
  location            = var.location
  acr_name            = var.acr_name
  sku                 = var.acr_sku
  tags                = var.default_tags
}



/*

# ------------------------------------------------------------------------------
# 6. Database (in DB subnet)
# ------------------------------------------------------------------------------
module "database" {
  source              = "./modules/database"
  resource_group_name = module.resource_group.name
  location            = var.location

  db_name             = var.db_name
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  db_sku_name         = var.db_sku_name
  db_version          = var.db_version
  db_storage_mb       = var.db_storage_mb
  publicly_accessible = var.publicly_accessible
  #db_subnet_id        = var.db_subnet_id

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  tags = var.default_tags
}

*/




# ------------------------------------------------------------------------------
# 7. AKS Cluster in Private (AKS) Subnet
# ------------------------------------------------------------------------------
module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.resource_group.name
  location            = var.location

  aks_cluster_name = var.aks_cluster_name
  dns_prefix       = var.dns_prefix

  # The AKS subnet is derived from your VNet module
  vnet_subnet_id = module.vnet.aks_subnet_id

  # Pass node count variables from root variables.tf
  default_node_count = var.default_node_count
  min_count          = var.min_count
  max_count          = var.max_count
  vm_size            = var.vm_size

  # Link ACR to AKS
  acr_id = module.acr.acr_id

  tags = var.default_tags
}
