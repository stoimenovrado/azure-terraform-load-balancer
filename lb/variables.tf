
variable "rg_name" {}
variable "location" {}
variable "vnet" {}

variable "nic-web" {
  type = list(string)
}

variable "web_vm_count" {
  type    = number
  default = 3
}

variable web-vm-nics{
  type = list(string)
}