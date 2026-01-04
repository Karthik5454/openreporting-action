// Main Bicep file for Azure Function App with Flex Consumption plan
targetScope = 'resourceGroup'

@description('The Azure region for all resources')
param location string = resourceGroup().location

@description('The environment name (e.g., dev, staging, prod)')
param environmentName string

@description('The name of the function app')
param functionAppName string

@description('Storage account name (optional, 3-24 chars, lowercase/numbers only)')
param storageAccountName string = ''

@description('Application Insights name (optional)')
param appInsightsName string = ''

@description('Log Analytics workspace name (optional)')
param logAnalyticsName string = ''

@description('Tags to apply to all resources')
param tags object = {}

// Storage Account
module storage 'modules/storage.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    environmentName: environmentName
    storageAccountName: storageAccountName
    tags: tags
  }
}

// Application Insights
module appInsights 'modules/app-insights.bicep' = {
  name: 'app-insights-deployment'
  params: {
    location: location
    environmentName: environmentName
    appInsightsName: appInsightsName
    logAnalyticsName: logAnalyticsName
    tags: tags
  }
}

// Function App with Flex Consumption plan
module functionApp 'modules/function-app.bicep' = {
  name: 'function-app-deployment'
  params: {
    location: location
    functionAppName: functionAppName
    storageAccountName: storage.outputs.storageAccountName
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    tags: tags
  }
}

// Outputs
output functionAppName string = functionApp.outputs.functionAppName
output functionAppHostName string = functionApp.outputs.functionAppHostName
output storageAccountName string = storage.outputs.storageAccountName
output appInsightsName string = appInsights.outputs.appInsightsName
