using './main.bicep'

param location = 'eastus'
param environmentName = 'prod'
param functionAppName = 'a208790-openai-reporting'
param storageAccountName = 'a208790stopenairpt'  // 3-24 chars, lowercase/numbers only
param appInsightsName = 'a208790-openai-reporting-app-insghts'
param logAnalyticsName = 'a208790-openai-reporting-log'
param tags = {
  Environment: 'Production'
  Project: 'OpenAI Reporting'
  ManagedBy: 'Bicep'
}
