param clusterName string = 'aks-webapp-monitoring'

param location string = resourceGroup().location

@description('Tier of the AKS you want to use. Valid options are Free, Standard and Premium. Free is default, it is good for testing, but it recommended to use fewer than 10 nodes, but it does support up to 1000. Standard and Premium are for Prod workloads and support up to 5000 nodes.')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param skuTier string = 'Free'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 100

@description('The size of the Virtual Machine.')
param nodeVMSize string = 'Standard_B2s'

@description('The number of nodes to start for the cluster.')
@minValue(1)
@maxValue(50)
param defaultNodeCount int = 3

// @description('The max number of nodes for the cluster to have')
// @minValue(1)
// @maxValue(50)
// param maxNodeCount int = 5

@description('Version of Kubernetes your AKS will run. You will need to look beforehand with the Azure CLI to see which versions are support for your region')
param kubernetesVersion string = '1.28'

param enableAutoScaling bool = false

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

// param linuxAdminUsername string


resource aks 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku : {
    name : 'Base'
    tier: skuTier
  }
  properties: {
    dnsPrefix: clusterName
    kubernetesVersion: kubernetesVersion
    publicNetworkAccess: publicNetworkAccess
    agentPoolProfiles: [
      {
        name: 'controlplane'
        osDiskSizeGB: osDiskSizeGB
        count: 1
        // if you want to enable autoscaling, you might want to set these
        // minCount: defaultNodeCount
        // maxCount: maxNodeCount
        vmSize: nodeVMSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        // instead of allowing AKS to create the VNet and subnet, you can create it first and provide the subnet ID here
        // vnetSubnetID: vnetSubnetID
        enableAutoScaling: enableAutoScaling
      }, {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: defaultNodeCount
        // if you want to enable autoscaling, you might want to set these
        // minCount: defaultNodeCount
        // maxCount: maxNodeCount
        vmSize: nodeVMSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        type: 'VirtualMachineScaleSets'
        // instead of allowing AKS to create the VNet and subnet, you can create it first and provide the subnet ID here
        // vnetSubnetID: vnetSubnetID
        enableAutoScaling: enableAutoScaling
      }
    ]
    // if you want to SSH into yout containers, you need to provide this at creation time
    // linuxProfile: {
    //   adminUsername: linuxAdminUsername
    //   ssh: {
    //     publicKeys: [
    //       {
    //         keyData: sshKey
    //       }
    //     ]
    //   }
    // }
  }
}
