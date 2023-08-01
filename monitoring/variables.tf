variable "rg_name" {}
variable "location" {}
variable "monitor-sub" {}
variable "monitoring_node_size" {}
variable "monitoring_node_name" {}
variable "monitoring_node_rg_name" {}
variable "monitoring_dns_prefix" {}
variable "monitoring_node_pool_name" {}
variable "monitoring_node_count" {}
variable "monitoring_namespace_provision_file" {}
variable "monitoring_storage_provision_file" {}
variable "monitoring_grafanapvc_provision_file" {}
variable "monitoring_prometheuspvc_provision_file" {}
variable "monitoring_promdeploy_provision_file" {}
variable "monitoring_promservice_provision_file" {}
variable "monitoring_grafdeploy_provision_file" {}
variable "monitoring_lb_provision_file" {}
# variable "kubectl_command" {}