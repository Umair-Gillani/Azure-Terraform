########################################
# modules/database/variables.tf
########################################

/*

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "db_name" {
  type        = string
  description = "Name of the MySQL Flexible Server"
}

variable "db_admin_username" {
  type        = string
  description = "Admin username for the DB"
}

variable "db_admin_password" {
  type        = string
  description = "Admin password for the DB"
  sensitive   = true
}

variable "db_sku_name" {
  type        = string
  description = "SKU for MySQL Flexible Server (e.g. Standard_B1ms, GP_Standard_D4s_v2, etc.)"
  default     = "Standard_B1ms"
}

variable "db_version" {
  type        = string
  description = "MySQL version (5.7, 8.0, etc.)"
  default     = "5.7"
}

variable "db_storage_mb" {
  type        = number
  description = "Storage in MB for the DB (e.g. 5120 for 5GB)"
  default     = 5120
}

variable "publicly_accessible" {
  type        = bool
  description = "If true, DB is accessible from public internet (not recommended). If false, must use delegated subnet or Private Endpoint."
  default     = false
}

variable "db_subnet_id" {
  type        = string
  description = "If using a delegated subnet for MySQL Flexible Server. If null, no delegated subnet is used."
  default     = null
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups."
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backups?"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources."
  default     = {}
}


*/