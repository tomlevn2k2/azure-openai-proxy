param location string
param webAppName string
param appServicePlanId string
param azureOpenAIBaseUrl string
param proxyApiKey string = ''
param appInsightConnectionString string = ''
param pythonLinuxFxVersion string = 'PYTHON|3.11'
param startupCommand string = 'python3 -m gunicorn main:app --bind 0.0.0.0:$PORT'

resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      linuxFxVersion: pythonLinuxFxVersion
      appCommandLine: startupCommand
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

resource appSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    AZURE_OPENAI_BASE_URL: azureOpenAIBaseUrl
    PROXY_API_KEY: proxyApiKey
    APP_INSIGHTS_CONNECTION_STRING: appInsightConnectionString
    SCM_DO_BUILD_DURING_DEPLOYMENT: '1'
  }
}

output name string = webApp.name
output id string = webApp.id
output defaultHostname string = webApp.properties.defaultHostName
output principalId string = webApp.identity.principalId!
