
variable "rg_name" {}
variable "location" {}
variable "vnet_name" {}
variable "vnet_address_space"{}
variable "web_subnet"{}
variable "db_subnet"{}
variable "jh_subnet"{}
variable "private_dns_zone_name"{}
variable "web-prip" {
  type = list(string)
}
variable "db-prip" {}

variable "web_vm_count" {
  type    = number
  default = 3
}