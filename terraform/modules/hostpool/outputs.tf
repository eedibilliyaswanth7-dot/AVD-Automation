output "id" {
  description = "The ID of the AVD Host Pool"
  value       = azurerm_virtual_desktop_host_pool.hp.id
}

output "name" {
  description = "The name of the AVD Host Pool"
  value       = azurerm_virtual_desktop_host_pool.hp.name
}

output "registration_token" {
  description = "The registration token used by session hosts to register with the host pool"
  value       = azurerm_virtual_desktop_host_pool_registration_info.hp_token.token
  sensitive   = true
}