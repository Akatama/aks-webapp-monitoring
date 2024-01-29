variable ClusterName {
  type = string
  description = "Name of the cluster we wil create"
  default = "aks-webapp-monitoring"
}

variable "ResourceGroupName" {
  type = string
  default = "aks-webapp-monitoring"
}

variable Location {
  type = string
  default = "Central US"
}

variable SkuTier {
  type = string
  description = "ier of the AKS you want to use. Valid options are Free, Standard and Premium. Free is default, it is good for testing, but it recommended to use fewer than 10 nodes, but it does support up to 1000. Standard and Premium are for Prod workloads and support up to 5000 nodes.'"
  default = "Free"
}

variable OSDiskSizeGB {
  type = number
  description = "isk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize."
  default = 100
}

variable NodeVMSize {
  type = string
  description = "The size of the Virtual Machine."
  default = "Standard_B2s"  
}

variable DefaultNodeCount {
  type = number
  description = "The number of nodes to start for the cluster."
  default = 3
}

# variable MaxNodeCount {
#   type = number
#   description = "The max number of nodes for the cluster to have"
#   default = 5
# }

variable KubernetesVersion {
  type = string
  description = "Version of Kubernetes your AKS will run. You will need to look beforehand with the Azure CLI to see which versions are support for your region"
  default = "1.28"
}

variable EnableAutoScaling {
  type = bool
  default = false
}

variable PublicNetworkAccess {
  type = bool
  description = "Whether or not public network access is enabled"
  default = true
}

# variable LinuxAdminUsername {
#   type = string
# }

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "3.84.0"
        }
    }
}

provider "azurerm" {
  features{}
  
}

resource "azurerm_resource_group" "resource_group" {
  name = var.ResourceGroupName
  location = var.Location
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [ azurerm_resource_group.resource_group ]
  name = var.ClusterName
  location = var.Location
  resource_group_name = var.ResourceGroupName
  sku_tier = var.SkuTier
  dns_prefix = var.ClusterName
  kubernetes_version = var.KubernetesVersion
  public_network_access_enabled = var.PublicNetworkAccess

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name = "controlplane"
    os_disk_size_gb = var.OSDiskSizeGB
    node_count = 1
    # If you want to enable autoscaling, you might want to set these
    # min_count = var.DefaultNodeCount
    # max_count = var.MaxNodeCount
    vm_size = var.NodeVMSize
    os_sku = "Ubuntu"
    type = "VirtualMachineScaleSets"
    # instead of allowing AKS to create the VNet and subnet, you can create it first and provide the subnet ID here
    # vnet_subnet_id = subnetID
    enable_auto_scaling = var.EnableAutoScaling
  }
  # If you want to SSH into your containers, you need to provide this at creation time
  # linux_profile {
  #   admin_username = var.LinuxAdminUsername
  #   ssh_key {
  #     key_data = file(var.AdminSSHKey)
  #   }
  # }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name = "agentpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  os_disk_size_gb = var.OSDiskSizeGB
  node_count = var.DefaultNodeCount
  # If you want to enable autoscaling, you might want to set these
  # min_count = var.DefaultNodeCount
  # max_count = var.MaxNodeCount
  vm_size = var.NodeVMSize
  os_type = "Linux"
  os_sku = "Ubuntu"
  # instead of allowing AKS to create the VNet and subnet, you can create it first and provide the subnet ID here
  # vnet_subnet_id = subnetID
  enable_auto_scaling = var.EnableAutoScaling
}