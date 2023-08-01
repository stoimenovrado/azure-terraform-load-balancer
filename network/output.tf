output "azurerm_network_interface_db" {
  value = azurerm_network_interface.db_vm.id
}

output "azurerm_network_interface_web" {
  value = azurerm_network_interface.web_vm.*.id
}

output "azurerm_virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "azurerm_network_interface_jh" {
  value = azurerm_network_interface.jump_host.id
}

output "azurerm_monitoring_subnet" {
  value = azurerm_subnet.monitoring.id
}