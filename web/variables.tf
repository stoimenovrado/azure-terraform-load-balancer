
variable "rg_name" {}
variable "location" {}
variable "ssh_rg_name" {}
variable "ssh_key_name" {}
variable "web_vm_size" {}
variable "web_availability_set_name" {}
variable "web_vm_name" {}
variable "web_vm_publisher" {}
variable "web_vm_offer"{}
variable "web_vm_sku"{}
variable "web_vm_version"{}
variable "web_vm_extension_name" {}
variable "web_provision_file_uri"{}
variable "web_provision_command_exec"{}
variable "web_vm_count" {}
variable "admin_username" {}

variable "nic-web" {
  type = list(string)
}
