param webAppName string
param subnetResourceId string

resource webApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: webAppName
}

resource webAppVnetIntegration 'Microsoft.Web/sites/networkConfig@2025-03-01' = {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetResourceId
    swiftSupported: true
  }
}

output id string = webAppVnetIntegration.id
