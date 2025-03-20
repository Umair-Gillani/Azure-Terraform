variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "default_node_count" {
  type    = number
  description = "Initial node count for AKS"
 # default = 3
}

variable "min_count" {
  type    = number
  description = "Minimum node count for auto-scaling"
  #default = 3
}

variable "max_count" {
  type    = number
  description = "Maximum node count for auto-scaling"
  #default = 4
}

variable "vm_size" {
  type        = string
  description = "Size of AKS nodes"
}

variable "tags" {
  type    = map(string)
  default = {}
}
