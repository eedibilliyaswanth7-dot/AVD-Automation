terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
  }
}

# 1. Create the Security Group named after the App Group
resource "azuread_group" "team_group" {
  display_name     = "avd-access-${var.appgroup_name}"
  security_enabled = true
}

# 2. Grant Workspace Access to the Group
resource "azurerm_role_assignment" "app_group_assignment" {
  scope                = var.app_group_id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.team_group.object_id
}

# 3. Grant VM Login Access to the Group
resource "azurerm_role_assignment" "vm_login_assignment" {
  scope                = var.resource_group_id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.team_group.object_id
}