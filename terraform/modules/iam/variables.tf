variable "appgroup_name" {
  type        = string
  description = "The name of the AVD Application Group (used to name the Entra ID group)"
}

variable "app_group_id" {
  type        = string
  description = "The ID of the AVD Application Group"
}

variable "resource_group_id" {
  type        = string
  description = "The ID of the Resource Group containing the VMs"
}