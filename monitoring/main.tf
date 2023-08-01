
provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "k8s-monitoring" {
  name                = var.monitoring_node_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.monitoring_dns_prefix
  node_resource_group = var.monitoring_node_rg_name

  default_node_pool {
    name           = var.monitoring_node_pool_name
    node_count     = var.monitoring_node_count
    vm_size        = var.monitoring_node_size
    vnet_subnet_id = var.monitor-sub
  }

  identity {
    type = "SystemAssigned"
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.rg_name} --overwrite-existing --name ${azurerm_kubernetes_cluster.k8s-monitoring.name}"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s-monitoring.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.k8s-monitoring.kube_config_raw
  sensitive = true
}

resource "null_resource" "execute_deployments" {
  depends_on = [azurerm_kubernetes_cluster.k8s-monitoring]

  provisioner "local-exec" {
    command     = "bash argocd.sh"
    working_dir = "${path.module}/"
  }
}

# locals {
#   monitoring_provision_files = [
#     var.monitoring_namespace_provision_file,
#     var.monitoring_storage_provision_file,
#     var.monitoring_grafanapvc_provision_file,
#     var.monitoring_prometheuspvc_provision_file,
#     var.monitoring_promdeploy_provision_file,
#     var.monitoring_promservice_provision_file,
#     var.monitoring_grafdeploy_provision_file,
#     var.monitoring_lb_provision_file
#   ]
# }

# resource "null_resource" "execute_deployments" {
#   depends_on = [azurerm_kubernetes_cluster.k8s-monitoring]

#   for_each = toset(local.monitoring_provision_files)

#   provisioner "local-exec" {
#     command = "${var.kubectl_command} -f ${each.value}"
#   }
# }