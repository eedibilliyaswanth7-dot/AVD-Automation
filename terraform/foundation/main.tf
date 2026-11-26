module "resource_group" {
  source   = "../modules/resource_group"
  name     = var.rg_name
  location = var.location
}

module "network" {
  source                = "../modules/network"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  vnet_name             = var.vnet_name
  subnet_name           = var.subnet_name
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
}

module "keyvault" {
  source              = "../modules/keyvault"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  keyvault_name       = var.keyvault_name
}

module "loganalytics" {
  source              = "../modules/loganalytics"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  workspace_name      = var.workspace_name
}

module "hostpool" {
  source              = "../modules/hostpool"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  hostpool_name       = var.hostpool_name
  log_analytics_workspace_id = module.loganalytics.id
}

module "workspace" {
  source              = "../modules/workspace"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  workspace_name      = var.workspace_name_avd
}

module "application_group" {
  source              = "../modules/application_group"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  appgroup_name       = var.appgroup_name
  hostpool_id         = module.hostpool.id
  workspace_id        = module.workspace.id
}

# 1. Create the Entra ID Security Group (Named dynamically based on the App Group)
resource "azuread_group" "team_group" {
  display_name     = "access-${var.appgroup_name}"
  security_enabled = true
}

# 2. Bind the Security Group to the App Group via the module output
resource "azurerm_role_assignment" "app_group_assignment" {
  scope                = module.application_group.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.team_group.object_id
}

# -------------------------------------------------------------------------
# SECURE HANDOFF: Save the Registration Token to Key Vault for Pipeline 2
# -------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "avd_token" {
  name         = "HostPoolRegistrationToken"
  value        = module.hostpool.registration_token
  key_vault_id = module.keyvault.id

  # Ensure the Key Vault is fully provisioned before trying to add a secret
  depends_on   = [module.keyvault]
}

# Route Application Group Logs
resource "azurerm_monitor_diagnostic_setting" "appgroup_diag" {
  name                       = "avd-diagnostics-routing"
  target_resource_id         = module.application_group.id
  log_analytics_workspace_id = module.loganalytics.id

  enabled_log {
    category_group = "allLogs"
  }
}

# Route AVD Workspace Logs
resource "azurerm_monitor_diagnostic_setting" "workspace_diag" {
  name                       = "avd-diagnostics-routing"
  target_resource_id         = module.workspace.id
  log_analytics_workspace_id = module.loganalytics.id

  enabled_log {
    category_group = "allLogs"
  }
}
