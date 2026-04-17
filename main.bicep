targetScope = 'resourceGroup'

@allowed([
  'southeastasia'
])
param location string = 'southeastasia'

@allowed([
  'swedencentral'
])
param aiLocation string = 'swedencentral'

@minLength(2)
param vnetName string

param vnetAddressPrefix string

@minLength(1)
param integrationSubnetName string

param integrationSubnetPrefix string

@minLength(1)
param privateEndpointSubnetName string

param privateEndpointSubnetPrefix string

@minLength(1)
param privateDnsZoneName string = 'privatelink.openai.azure.com'

@minLength(2)
param privateEndpointName string

@minLength(1)
param appServicePlanName string

@minLength(2)
param webAppName string

@minLength(2)
param aiAccountName string

@minLength(1)
param modelDeploymentName string

@minLength(1)
param modelName string = 'gpt-5.4'

@minLength(1)
param modelVersion string = '2026-03-05'

@minLength(1)
param modelDeploymentSkuName string = 'GlobalStandard'

@minValue(1)
param modelDeploymentCapacity int = 200

@minLength(1)
param modelVersionUpgradeOption string = 'OnceNewDefaultVersionAvailable'

@minLength(6)
param automationAccountName string

@minLength(1)
param runbookName string

@minLength(1)
param runbookContentUri string

@minLength(1)
param scheduleName string

@minLength(1)
param scheduleFrequency string = 'Hour'

@minValue(1)
param scheduleInterval int = 1

@minLength(1)
param scheduleTimeZone string = 'UTC'

@minLength(1)
param scheduleStartTime string = dateTimeAdd(utcNow('o'), 'PT1H')

param pythonLinuxFxVersion string = 'PYTHON|3.11'
param startupCommand string = 'python3 -m gunicorn main:app --bind 0.0.0.0:$PORT'
param proxyApiKey string = ''
param appInsightConnectionString string = ''

var azureOpenAIBaseUrl = 'https://${aiAccountName}.openai.azure.com'
var cognitiveServicesOpenAIUserRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
)
var contributorRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
)

module vnet './modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    integrationSubnetName: integrationSubnetName
    integrationSubnetPrefix: integrationSubnetPrefix
    privateEndpointSubnetName: privateEndpointSubnetName
    privateEndpointSubnetPrefix: privateEndpointSubnetPrefix
  }
}

module appServicePlan './modules/appservice-plan.bicep' = {
  name: 'appservice-plan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webapp'
  params: {
    location: location
    webAppName: webAppName
    appServicePlanId: appServicePlan.outputs.id
    pythonLinuxFxVersion: pythonLinuxFxVersion
    startupCommand: startupCommand
    azureOpenAIBaseUrl: azureOpenAIBaseUrl
    proxyApiKey: proxyApiKey
    appInsightConnectionString: appInsightConnectionString
  }
}

module aiAccount './modules/ai-account.bicep' = {
  name: 'ai-account'
  params: {
    location: aiLocation
    aiAccountName: aiAccountName
  }
}

module aiDeployment './modules/ai-deployment.bicep' = {
  name: 'ai-deployment'
  params: {
    aiAccountName: aiAccount.outputs.name
    modelDeploymentName: modelDeploymentName
    modelName: modelName
    modelVersion: modelVersion
    modelDeploymentSkuName: modelDeploymentSkuName
    modelDeploymentCapacity: modelDeploymentCapacity
    modelVersionUpgradeOption: modelVersionUpgradeOption
  }
}

module privateDnsZone './modules/private-dns-zone.bicep' = {
  name: 'private-dns-zone'
  params: {
    privateDnsZoneName: privateDnsZoneName
    vnetId: vnet.outputs.id
    vnetName: vnet.outputs.name
  }
}

module privateEndpoint './modules/private-endpoint.bicep' = {
  name: 'private-endpoint'
  params: {
    location: location
    privateEndpointName: privateEndpointName
    subnetId: vnet.outputs.privateEndpointSubnetId
    targetResourceId: aiAccount.outputs.id
    privateDnsZoneId: privateDnsZone.outputs.id
  }
}

module webAppVnetIntegration './modules/webapp-vnet-integration.bicep' = {
  name: 'webapp-vnet-integration'
  params: {
    webAppName: webApp.outputs.name
    subnetResourceId: vnet.outputs.integrationSubnetId
  }
}

module automationAccount './modules/automation-account.bicep' = {
  name: 'automation-account'
  params: {
    location: location
    automationAccountName: automationAccountName
  }
}

module webAppAiRoleAssignment './modules/role-assignment.bicep' = {
  name: 'webapp-openai-user'
  params: {
    scopeResourceType: 'Microsoft.CognitiveServices/accounts'
    scopeResourceName: aiAccount.outputs.name
    principalId: webApp.outputs.principalId
    roleDefinitionId: cognitiveServicesOpenAIUserRoleDefinitionId
  }
}

module automationPlanRoleAssignment './modules/role-assignment.bicep' = {
  name: 'automation-plan-contributor'
  params: {
    scopeResourceType: 'Microsoft.Web/serverfarms'
    scopeResourceName: appServicePlan.outputs.name
    principalId: automationAccount.outputs.principalId
    roleDefinitionId: contributorRoleDefinitionId
  }
}

module automationWebAppRoleAssignment './modules/role-assignment.bicep' = {
  name: 'automation-webapp-contributor'
  params: {
    scopeResourceType: 'Microsoft.Web/sites'
    scopeResourceName: webApp.outputs.name
    principalId: automationAccount.outputs.principalId
    roleDefinitionId: contributorRoleDefinitionId
  }
}

module runbook './modules/runbook.bicep' = {
  name: 'runbook'
  params: {
    location: location
    automationAccountName: automationAccount.outputs.name
    runbookName: runbookName
    runbookContentUri: runbookContentUri
  }
}

module schedule './modules/schedule.bicep' = {
  name: 'schedule'
  params: {
    automationAccountName: automationAccount.outputs.name
    scheduleName: scheduleName
    scheduleFrequency: scheduleFrequency
    scheduleInterval: scheduleInterval
    scheduleTimeZone: scheduleTimeZone
    scheduleStartTime: scheduleStartTime
  }
}

module jobSchedule './modules/job-schedule.bicep' = {
  name: 'job-schedule'
  params: {
    automationAccountName: automationAccount.outputs.name
    runbookName: runbook.outputs.name
    scheduleName: schedule.outputs.name
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroup().name
    appServicePlanName: appServicePlan.outputs.name
  }
}

output webAppName string = webApp.outputs.name
output webAppDefaultHostname string = webApp.outputs.defaultHostname
output webAppPrincipalId string = webApp.outputs.principalId
output vnetResourceId string = vnet.outputs.id
output integrationSubnetResourceId string = vnet.outputs.integrationSubnetId
output privateEndpointResourceId string = privateEndpoint.outputs.id
output appServicePlanResourceId string = appServicePlan.outputs.id
output aiResourceName string = aiAccount.outputs.name
output aiBaseUrl string = azureOpenAIBaseUrl
output modelDeploymentName string = aiDeployment.outputs.name
output automationAccountName string = automationAccount.outputs.name
output automationAccountPrincipalId string = automationAccount.outputs.principalId
output runbookName string = runbook.outputs.name
output scheduleName string = schedule.outputs.name
output jobScheduleId string = jobSchedule.outputs.id
