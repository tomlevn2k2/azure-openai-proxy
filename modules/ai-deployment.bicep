param aiAccountName string
param modelDeploymentName string
param modelName string
param modelVersion string
param modelDeploymentSkuName string
param modelDeploymentCapacity int
param modelVersionUpgradeOption string

resource aiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: aiAccountName
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiAccount
  name: modelDeploymentName
  sku: {
    name: modelDeploymentSkuName
    capacity: modelDeploymentCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
    versionUpgradeOption: modelVersionUpgradeOption
  }
}

output id string = modelDeployment.id
output name string = modelDeployment.name
