// Storage Account module for Azure Function App
@description('The Azure region for the storage account')
param location string

@description('The environment name')
param environmentName string

@description('Tags to apply to the storage account')
param tags object = {}

@description('Storage account name (optional). If not provided, will be auto-generated. Must be 3-24 chars, lowercase letters and numbers only')
param storageAccountName string = ''

var actualStorageAccountName = !empty(storageAccountName) ? storageAccountName : 'st${uniqueString(resourceGroup().id, environmentName)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: actualStorageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Blob service with container for function deployments
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource deploymentContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  parent: blobService
  name: 'deployments'
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output deploymentContainerName string = deploymentContainer.name
