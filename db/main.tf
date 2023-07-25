
provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "vm-login" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_rg_name
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = var.db_vm_name
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.db_vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true
  network_interface_ids = [
    var.nic-db,
  ]
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_ssh_public_key.vm-login.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.db_vm_publisher
    offer     = var.db_vm_offer
    sku       = var.db_vm_sku
    version   = var.db_vm_version
  }
}

resource "azurerm_virtual_machine_extension" "db_vm-extension" {
  name                 = var.db_vm_extension_name
  virtual_machine_id   = azurerm_linux_virtual_machine.db_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris": ["${var.db_provision_file_uri}"],
        "commandToExecute": "${var.db_provision_command_exec}"
    }
SETTINGS
}
