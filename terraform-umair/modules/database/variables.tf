variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "db_name" {
  type        = string
  description = "Database server name"
}

variable "db_subnet_id" {
  type        = string
  description = "Subnet ID for the DB"
}

variable "admin_username" {
  type        = string
}

variable "admin_password" {
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}
