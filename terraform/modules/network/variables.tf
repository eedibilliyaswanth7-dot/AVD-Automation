variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_address_space" {
  type        = string
  description = "The CIDR block for the entire VNet (e.g., 10.1.0.0/16)"
}

variable "subnet_name" {
  type = string
}

variable "subnet_address_prefix" {
  type        = string
  description = "The CIDR block for the Subnet (e.g., 10.1.0.0/24)"
}