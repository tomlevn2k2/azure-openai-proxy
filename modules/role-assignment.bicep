@allowed([
  'Microsoft.CognitiveServices/accounts'
  'Microsoft.Web/serverfarms'
  'Microsoft.Web/sites'
])
param scopeResourceType string

param scopeResourceName string
param principalId string
param roleDefinitionId string

var scopeResourceId = resourceId(scopeResourceType, scopeResourceName)
var roleAssignmentName = guid(scopeResourceId, principalId, roleDefinitionId)

resource aiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (scopeResourceType == 'Microsoft.CognitiveServices/accounts') {
  name: scopeResourceName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' existing = if (scopeResourceType == 'Microsoft.Web/serverfarms') {
  name: scopeResourceName
}

resource webApp 'Microsoft.Web/sites@2025-03-01' existing = if (scopeResourceType == 'Microsoft.Web/sites') {
  name: scopeResourceName
}

resource aiAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (scopeResourceType == 'Microsoft.CognitiveServices/accounts') {
  name: roleAssignmentName
  scope: aiAccount
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}

resource appServicePlanRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (scopeResourceType == 'Microsoft.Web/serverfarms') {
  name: roleAssignmentName
  scope: appServicePlan
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}

resource webAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (scopeResourceType == 'Microsoft.Web/sites') {
  name: roleAssignmentName
  scope: webApp
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}

output name string = roleAssignmentName
