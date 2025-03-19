#####################################################################
# terraform.tfvars
# 
# These values configure our environment for "staging" (example).
# 
# For production, simply change vnet_cidr from
# "10.17.0.0/16" to "10.18.0.0/16" (or any valid CIDR).
#####################################################################

# -------------------------------------------------------------------
# General Settings
# -------------------------------------------------------------------
location = "Central US"
rg_name  = "cw-centralus-rg"

default_tags = {
  environment = "dev"
  project     = "cw"
}

# -------------------------------------------------------------------
# Terraform State Storage (if applicable)
# -------------------------------------------------------------------
storage_account_name = "cwcentralusstore"
state_container_name = "tfstate"

# If you plan to store state in the same RG/SA, you can keep them the same:
state_rg_name = "cw-centralus-rg"
state_sa_name = "cwcentralusstore"

# -------------------------------------------------------------------
# Virtual Network & Subnets
# -------------------------------------------------------------------
vnet_name = "cw-centralus-vnet"
vnet_cidr = "10.17.0.0/16"

public_subnet_name = "cw-centralus-public-subnet"
aks_subnet_name    = "cw-centralus-aks-subnet"
db_subnet_name     = "cw-centralus-db-subnet"

# -------------------------------------------------------------------
# Bastion Host Settings
# -------------------------------------------------------------------
bastion_name           = "cw-centralus-bastion"
bastion_admin_username = "azureuser"
bastion_ssh_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjmLK0jNU/3ryRRf4kEexpghwlLVkSaeAfUnEWhLP6YbJ94ZpEBxtbJUhVv5jxBQsTr17PHcRjHbnFWtpnhPHKobu9UtwizLIqElIXJ1hJc3c5S4eLo2/nBK+BdVpm0WTw2IFcgAo1hVz+Y+xkVjocT3Idg0gyrARdY2dY7YwCVCHZ/YzuAtrBLnltui9rbehV7l8H/tviSrvwWk30GWSSFVhLup1n+zLrf3C+DC8OSjAwXuPkiunhdsnsXes8XBebH/mv1Dp4wtJ7QDmuGKgOafD2fpbhK+wls5dxvZ9VZv+u53phz+0mIBfm/2tl6dwoO50iuy/vclvNgz3Xubz7"

# -------------------------------------------------------------------
# Azure Container Registry
# -------------------------------------------------------------------
acr_name = "cwcentralusacr"

# -------------------------------------------------------------------
# Database Settings
# -------------------------------------------------------------------
db_name           = "cw-centralus-db"
db_admin_username = "dbadmin"
db_admin_password = "SomeStrongP@ssw0rd"

# -------------------------------------------------------------------
# AKS Cluster
# -------------------------------------------------------------------
aks_cluster_name = "cw-centralus-aks_cluster"
dns_prefix       = "cwcentralus"
