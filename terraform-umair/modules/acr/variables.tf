variable "resource_group_name" {
  type        = string
  description = "RG name"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "acr_name" {
  type        = string
  description = "ACR name"
}

variable "sku" {
  type        = string
  description = "ACR SKU"
  default     = "Basic"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
