param automationAccountName string
param runbookName string
param scheduleName string
param subscriptionId string
param resourceGroupName string
param appServicePlanName string

resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' existing = {
  name: automationAccountName
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2024-10-23' = {
  parent: automationAccount
  name: guid(automationAccountName, runbookName, scheduleName)
  properties: {
    runbook: {
      name: runbookName
    }
    schedule: {
      name: scheduleName
    }
    parameters: {
      SubscriptionId: subscriptionId
      ResourceGroupName: resourceGroupName
      AppServicePlanName: appServicePlanName
    }
  }
}

output id string = jobSchedule.id
