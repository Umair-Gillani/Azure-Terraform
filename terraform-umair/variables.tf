##########################################
# variables.tf (Root Module) - Fixed
##########################################

variable "location" {
  type        = string
  description = "Azure region"
  default     = "Central US"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name for backend"
}

variable "state_container_name" {
  type        = string
  description = "Storage container name for backend"
}

variable "state_rg_name" {
  type        = string
  description = "Resource group name for Terraform backend"
}

variable "state_sa_name" {
  type        = string
  description = "Storage account name for Terraform backend"
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "vnet_cidr" {
  type        = string
  description = "Base CIDR for the VNet (e.g. 10.17.0.0/16). Changing this automatically changes subnet CIDRs."
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
}

variable "aks_subnet_name" {
  type        = string
  description = "Name of the AKS subnet"
}

variable "db_subnet_name" {
  type        = string
  description = "Name of the DB subnet"
}

variable "bastion_name" {
  type        = string
  description = "Name of the Bastion host"
}

variable "bastion_vm_size" {
  type        = string
  description = "VM size for bastion host"
  default     = "Standard_B1s"
}

variable "bastion_admin_username" {
  type        = string
  description = "Admin username for bastion"
}

variable "bastion_ssh_key" {
  type        = string
  description = "SSH public key for bastion host"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
}

variable "acr_sku" {
  type        = string
  description = "SKU for ACR"
  default     = "Basic"
}

variable "db_name" {
  type        = string
  description = "Name of the database instance"
}

variable "db_admin_username" {
  type        = string
  description = "DB admin username"
}

variable "db_admin_password" {
  type        = string
  description = "DB admin password"
}

variable "aks_cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for AKS"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to resources"
  default     = {}
}
