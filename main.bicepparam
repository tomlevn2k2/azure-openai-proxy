using './main.bicep'

param location = 'southeastasia'
param aiLocation = 'swedencentral'

param vnetName = 'vnet-openaiproxy'
param vnetAddressPrefix = '10.20.0.0/24'

param integrationSubnetName = 'snet-appsvcint'
param integrationSubnetPrefix = '10.20.0.0/28'

param privateEndpointSubnetName = 'snet-pe'
param privateEndpointSubnetPrefix = '10.20.0.16/28'

param privateDnsZoneName = 'privatelink.openai.azure.com'
param privateEndpointName = 'pep-openaiproxy-oai'

param appServicePlanName = 'asp-openaiproxy'
param webAppName = 'app-openaiproxy'
param aiAccountName = 'oai-openaiproxy'
param modelDeploymentName = 'gpt-5.4'
param modelName = 'gpt-5.4'
param modelVersion = '2026-03-05'
param modelDeploymentSkuName = 'GlobalStandard'
param modelDeploymentCapacity = 200
param modelVersionUpgradeOption = 'OnceNewDefaultVersionAvailable'
param automationAccountName = 'aa-openaiproxy'
param runbookName = 'runbook-openaiproxy'
param runbookContentUri = 'https://share.chatuii.com/260417-0001/files/260417-0001/ae9f0f4b-a122-41b6-927c-03d270ce2781.ps1'
param scheduleName = 'daily-scale-plan'
param scheduleFrequency = 'Hour'
param scheduleInterval = 1
param scheduleTimeZone = 'SE Asia Standard Time'
param pythonLinuxFxVersion = 'PYTHON|3.11'
param startupCommand = 'python3 -m gunicorn main:app --bind 0.0.0.0:$PORT'
param proxyApiKey = ''
param appInsightConnectionString = ''
