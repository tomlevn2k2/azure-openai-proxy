param automationAccountName string
param scheduleName string
param scheduleFrequency string
param scheduleInterval int
param scheduleTimeZone string
param scheduleStartTime string

resource automationAccount 'Microsoft.Automation/automationAccounts@2024-10-23' existing = {
  name: automationAccountName
}

resource schedule 'Microsoft.Automation/automationAccounts/schedules@2024-10-23' = {
  parent: automationAccount
  name: scheduleName
  properties: {
    description: 'Schedule created by Bicep. Attach it to the runbook after importing the final script.'
    frequency: scheduleFrequency
    interval: scheduleInterval
    startTime: scheduleStartTime
    timeZone: scheduleTimeZone
  }
}

output id string = schedule.id
output name string = schedule.name
