param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$AppServicePlanName
)

$ErrorActionPreference = 'Stop'

# Optional but recommended in Automation
Disable-AzContextAutosave -Scope Process

# Authenticate with the Automation Account managed identity
Connect-AzAccount -Identity | Out-Null

# Set subscription context
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# Change App Service Plan to Basic B1
Set-AzAppServicePlan `
    -ResourceGroupName $ResourceGroupName `
    -Name $AppServicePlanName `
    -Tier Basic `
    -WorkerSize Small

Write-Output "App Service Plan '$AppServicePlanName' in resource group '$ResourceGroupName' was updated to Basic B1."

# Resolve the App Service Plan resource ID
$plan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName
$planId = $plan.Id.Trim().ToLower()

if (-not $planId) {
    throw "Unable to resolve app service plan id for $AppServicePlanName in $ResourceGroupName."
}

Write-Output "App Service Plan ID '$planId'"

# Collect all web apps that sit on this plan
$apps = Get-AzWebApp -AppServicePlan $plan

if (-not $apps) {
    Write-Output "No web apps found on plan $AppServicePlanName."
    return
}

foreach ($app in $apps) {
    Write-Output "Enabling AlwaysOn = '$($app.Name)'..."
    Set-AzWebApp `
        -ResourceGroupName $ResourceGroupName `
        -Name $app.Name `
        -AlwaysOn $true | Out-Null
}
