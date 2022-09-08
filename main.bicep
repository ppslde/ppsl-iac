@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

// @description('The type of environment. This must be nonprod or prod.')
// @allowed([
//   'nonprod'
//   'prod'
// ])
// param environmentType string

// @description('A unique suffix to add to resource names that need to be globally unique.')
// @maxLength(13)
// param resourceNameSuffix string = uniqueString(resourceGroup().id)

param resourcePrefix string = 'aksbicep1'

module aks './aks-cluster.bicep' = {
  name: '${resourcePrefix}cluster'
  scope: resourceGroup()
  params: {
    location: location
    clusterName: resourcePrefix
  }
}
