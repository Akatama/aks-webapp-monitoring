param clusterName string = 'nflCluster'

param location string = resourceGroup().location

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param nodeCount int = 3

@description('The size of the Virtual Machine.')
param nodeVMSize string = 'standard_d2s_v3'

@description('Tier of the AKS you want to use. Valid options are Free, Standard and Premium. Free is default, it is good for testing, but it recommended to use fewer than 10 nodes, but it does support up to 1000. Standard and Premium are for Prod workloads and support up to 5000 nodes.')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param skuTier string = 'Free'

@description('Version of Kubernetes your AKS will run. You will need to look beforehand with the Azure CLI to see which versions are support for your region')
param kubernetesVersion string = '1.28'

param linuxAdminUsername string


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
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: nodeCount
        vmSize: nodeVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}
