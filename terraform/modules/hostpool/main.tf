# 1. Provision the AVD Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp" {
  name                  = var.hostpool_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  type                  = "Pooled"
  load_balancer_type    = "BreadthFirst"
  custom_rdp_properties = "enablerdsaadauth:i:1;targetisaadjoined:i:1;audiocapturemode:i:1;audiomode:i:0;enablecredsspsupport:i:1;videoplaybackmode:i:1;devicestoredirect:s:*;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:1;redirectprinters:i:0;redirectsmartcards:i:1;redirectwebauthn:i:1;usbdevicestoredirect:s:;use multimon:i:1"
}

# 2. Generate the secure registration token for session hosts to join
# - Instruct Terraform to rotate this resource automatically every 28 days
resource "time_rotating" "token_timer" {
  rotation_days = 28
}

# - Bind the AVD token expiration to that rotating timer
resource "azurerm_virtual_desktop_host_pool_registration_info" "hp_token" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hp.id
  expiration_date = time_rotating.token_timer.rotation_rfc3339
}

# 3. Route AVD diagnostics directly to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "avd_diagnostics" {
  name                       = "avd-diagnostics-routing"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hp.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

# Fetch the existing Resource Group to get its ID
data "azurerm_client_config" "current" {}

# Automate the Role Assignment
resource "azurerm_role_assignment" "avd_power_role" {
  # Dynamically builds the ID string
  scope                              = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name               = "Desktop Virtualization Power On Off Contributor"
  principal_id                       = "b2031cb1-74c5-414e-ba32-ac299654946f"
  
  # Bypasses the Azure AD replication delay that caused the timeout
  skip_service_principal_aad_check   = true
}

# 4. AVD Autoscale (Scaling Plan) for Cost Optimization
resource "azurerm_virtual_desktop_scaling_plan" "autoscale" {
  name                = "${var.hostpool_name}-scaling-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "Enterprise Cost Optimization Plan"
  time_zone           = "India Standard Time"

  depends_on = [
    azurerm_role_assignment.avd_power_role
  ]

  schedule {
    name                                 = "BusinessHours"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    # 1. Ramp Up (8:00 AM) - Turn on 20% of VMs before employees arrive
    ramp_up_start_time                   = "08:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 60

    # 2. Peak Hours (9:00 AM) - Switch to filling VMs efficiently
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "DepthFirst"

    # 3. Ramp Down (6:00 PM) - Stop accepting new users and prepare to shut down
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "Please save your work. The virtual desktop will shut down in 30 minutes for cost optimization."
    ramp_down_capacity_threshold_percent = 90
    ramp_down_stop_hosts_when            = "ZeroSessions"

    # 4. Off-Peak (8:00 PM) - Shut down all idle VMs for the night
    off_peak_start_time                  = "20:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.hp.id
    scaling_plan_enabled = true
  }
}