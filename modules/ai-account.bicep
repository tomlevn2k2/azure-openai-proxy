param location string
param aiAccountName string

resource aiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: aiAccountName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: aiAccountName
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
  }
}

output id string = aiAccount.id
output name string = aiAccount.name
