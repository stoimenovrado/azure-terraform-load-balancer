# variable "rg_name" {
#     description = "Resource Group Name"
# }
# variable "location" {
#     description = "Project Location"
# }
# variable "ssh_rg_name" {
#     description = "SSH Key Resource Group"
# }
# variable "ssh_key_name" {
#     description = "SSH Key Name"
# }
# variable "ssh_key_jh_name" {
#     description = "SSH Key Jump Host Name"
# }
# variable "web_vm_size" {
#     description = "Size of the web VMs"
# }
# variable "db_vm_size" {
#     description = "Size of the db VMs"
# }
# variable "jh_vm_size" {
#     description = "Size of the jh VMs"
# }
# variable "web_availability_set_name" {
#     description = "Name of the Avaiability set for web vms"
# }
# variable "web_vm_name" {
#     description = "Name of the Web VMs"
# }
# variable "web_vm_count" {
#     description = "Count of the web VMs to be created"
# }
# variable "db_vm_name" {
#     description = "Name of the DB VMs"
# }
# variable "jh_vm_name" {
#     description = "Name of the JH VMs"
# }
# variable "web_vm_extension_name" {
#     description = "Name of the Web VM extension for provisioning"
# }
# variable "db_vm_extension_name" {
#     description = "Name of the DB VM extension for provisioning"
# }
# variable "web_vm_publisher" {
#     description = "Web VM publisher name"
# }
# variable "web_vm_offer"{
#     description = "Web VM offer name"
# }
# variable "web_vm_sku"{
#     description = "The name of the OS distribution"
# }
# variable "web_vm_version"{
#     description = "The distribution version"
# }
# variable "web_provision_file_uri"{
#     description = "The Web provision file URL for example from github"
# }
# variable "web_provision_command_exec"{
#     description = "The command to execute for the provisioning Web file"
# }
# variable "db_provision_file_uri"{
#     description = "The DB provision file URL for example from github"
# }
# variable "db_provision_command_exec"{
#     description = "The command to execute for the provisioning DB file"
# }
# variable "key_file_name" {
#     description = "The key file name for the remote hosts login"
# }
# variable "key-location" {
#     description = "Location of the key file for the remote login"
# }
# variable "admin_username" {
#     description = "The administrator user for the VMs"
# }
# variable "vnet_name" {
#     description = "Name of the Virtual Network"
# }
# variable "vnet_address_space"{
#     description = "IP ranage of the Vnet"
# }
# variable "web_subnet"{
#     description = "Web subnet range"
# }
# variable "db_subnet"{
#     description = "DB subnet range"
# }
# variable "jh_subnet"{
#     description = "JH subnet range"
# }
# variable "private_dns_zone_name"{
#     description = "Private DNS Zone Name"
# }
# variable "kubectl_command"{
#     description = "Kubectl command (Apply or Delete)"
# #    default = "kubectl apply"
# }