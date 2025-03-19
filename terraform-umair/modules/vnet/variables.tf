variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "vnet_cidr" {
  type        = string
  description = "Base CIDR for the VNet (e.g. 10.17.0.0/16). Changing this automatically changes subnet CIDRs."
  default     = "10.17.0.0/16"
}

variable "public_subnet_name" {
  type        = string
  description = "Name of the public subnet"
  default     = "public-subnet"
}

variable "aks_subnet_name" {
  type        = string
  description = "Name of the AKS (cluster) subnet"
  default     = "aks-subnet"
}

variable "db_subnet_name" {
  type        = string
  description = "Name of the DB subnet"
  default     = "db-subnet"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
