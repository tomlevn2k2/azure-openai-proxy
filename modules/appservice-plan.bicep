param location string
param appServicePlanName string

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
