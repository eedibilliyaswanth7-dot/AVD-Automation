variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the host pool"
  type        = string
}

variable "hostpool_name" {
  description = "The name of the AVD Host Pool"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics Workspace for diagnostic routing"
  type        = string
}