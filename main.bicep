@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

var appServiceAppName = 'ppsl-aks-${resourceNameSuffix}'
var appServicePlanName = 'ppsl-aks-plan'
var ppslStorageAccountName = 'ppslstorage${resourceNameSuffix}'

// Define the SKUs for each component based on the environment type.
var environmentConfigurationMap = {
  nonprod: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    ppslStorageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
  prod: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    ppslStorageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
  }
}
var ppslStorageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${ppslStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${ppslStorageAccount.listKeys().keys[0].value}'

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'ppslStorageAccountConnectionString'
          value: ppslStorageAccountConnectionString
        }
      ]
    }
  }
}

resource ppslStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: ppslStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: environmentConfigurationMap[environmentType].ppslStorageAccount.sku
}
