// Application Insights module
@description('The Azure region for Application Insights')
param location string

@description('The environment name')
param environmentName string

@description('Tags to apply to Application Insights')
param tags object = {}

@description('Application Insights name (optional). If not provided, will be auto-generated')
param appInsightsName string = ''

@description('Log Analytics workspace name (optional). If not provided, will be auto-generated')
param logAnalyticsName string = ''

var actualAppInsightsName = !empty(appInsightsName) ? appInsightsName : 'appi-${environmentName}-${uniqueString(resourceGroup().id)}'
var actualLogAnalyticsName = !empty(logAnalyticsName) ? logAnalyticsName : 'log-${environmentName}-${uniqueString(resourceGroup().id)}'

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: actualLogAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: actualAppInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output appInsightsName string = appInsights.name
output appInsightsId string = appInsights.id
output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
