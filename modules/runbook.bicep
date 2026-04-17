param location string
param automationAccountName string
param runbookName string
param runbookContentUri string

resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' existing = {
  name: automationAccountName
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2024-10-23' = {
  parent: automationAccount
  name: runbookName
  location: location
  properties: {
    description: 'PowerShell 7.2 runbook published from a hosted script URL.'
    logProgress: false
    logVerbose: false
    publishContentLink: {
      uri: runbookContentUri
    }
    runbookType: 'PowerShell72'
  }
}

output id string = runbook.id
output name string = runbook.name
