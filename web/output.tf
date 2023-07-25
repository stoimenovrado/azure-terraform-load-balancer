output "private_ip_address" {
  value = azurerm_linux_virtual_machine.web_vm.*.private_ip_address
}

output "web-vm-nic_ids" {
  value = azurerm_linux_virtual_machine.web_vm[*].network_interface_ids[0]
}
