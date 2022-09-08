param location string
param clusterName string

param nodeCount int = 2
param vmSize string = 'Standard_B2s'

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: '${clusterName}ap1'
        count: nodeCount
        maxCount: 2
        minCount: 1
        vmSize: vmSize
        mode: 'System'
      }
    ]
  }
}
