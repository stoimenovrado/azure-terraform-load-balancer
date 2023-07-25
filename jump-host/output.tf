output "public_ip_address" {
  value = azurerm_linux_virtual_machine.jump-host-vm.public_ip_address
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.jump-host-vm.private_ip_address
}