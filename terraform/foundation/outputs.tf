# These outputs are just for terminal visibility during Pipeline 1.
# Phase 2 will use data blocks to look these up dynamically.

# Resource Group

output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

# Network

output "vnet_name" {
  value = module.network.vnet_name
}

output "subnet_id" {
  value = module.network.subnet_id
}

# Host Pool

output "hostpool_id" {
  value = module.hostpool.id
}

output "hostpool_name" {
  value = module.hostpool.name
}

output "registration_token" {
  value     = module.hostpool.registration_token
  sensitive = true
}

# Application Group

output "application_group_id" {
  value = module.application_group.id
}

# Workspace

output "workspace_id" {
  value = module.workspace.id
}

# Key Vault

output "keyvault_id" {
  value = module.keyvault.id
}

output "keyvault_name" {
  value = module.keyvault.name
}

# Log Analytics

output "loganalytics_id" {
  value = module.loganalytics.id
}