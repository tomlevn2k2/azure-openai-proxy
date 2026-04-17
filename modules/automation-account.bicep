param location string
param automationAccountName string

resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output id string = automationAccount.id
output name string = automationAccount.name
output principalId string = automationAccount.identity.principalId!
