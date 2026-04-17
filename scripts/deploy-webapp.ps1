param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$WebAppName,

    [string]$PackagePath,

    [string]$PackageUrl,

    [string]$SubscriptionId
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$paramFile = Join-Path $projectDir 'main.bicepparam'
$templateFile = Join-Path $projectDir 'main.bicep'
$defaultPackagePath = Join-Path $projectDir 'openai-responses-api.zip'
$resourceGroupLocation = 'southeastasia'

function Get-BicepParamValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$ParamName
    )

    $pattern = "^\s*param\s+${ParamName}\s*=\s*'([^']+)'\s*$"
    foreach ($line in Get-Content -Path $FilePath) {
        if ($line -match $pattern) {
            return $Matches[1]
        }
    }

    throw "Unable to resolve parameter '$ParamName' from $FilePath."
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI 'az' is required."
}

if (-not (Test-Path -Path $paramFile)) {
    throw "Parameter file not found: $paramFile"
}

if (-not (Test-Path -Path $templateFile)) {
    throw "Template file not found: $templateFile"
}

if ([string]::IsNullOrWhiteSpace($WebAppName)) {
    $WebAppName = Get-BicepParamValue -FilePath $paramFile -ParamName 'webAppName'
}

if (-not [string]::IsNullOrWhiteSpace($SubscriptionId)) {
    az account set --subscription $SubscriptionId | Out-Null
}

az account show | Out-Null

az group create `
    --name $ResourceGroupName `
    --location $resourceGroupLocation `
    --output table

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $templateFile `
    --parameters $paramFile `
    --output table

if ([string]::IsNullOrWhiteSpace($PackagePath) -and [string]::IsNullOrWhiteSpace($PackageUrl)) {
    $PackagePath = $defaultPackagePath
}

if (-not [string]::IsNullOrWhiteSpace($PackagePath) -and -not [string]::IsNullOrWhiteSpace($PackageUrl)) {
    throw "Specify either PackagePath or PackageUrl, not both."
}

if (-not [string]::IsNullOrWhiteSpace($PackagePath)) {
    if (-not (Test-Path -Path $PackagePath)) {
        throw "Package file not found: $PackagePath"
    }

    az webapp deploy `
        --resource-group $ResourceGroupName `
        --name $WebAppName `
        --src-path $PackagePath `
        --type zip `
        --clean true `
        --restart true `
        --track-status true `
        --output table
}
else {
    az webapp deploy `
        --resource-group $ResourceGroupName `
        --name $WebAppName `
        --src-url $PackageUrl `
        --type zip `
        --restart true `
        --async true `
        --output table
}

$defaultHostName = az webapp show `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --query defaultHostName `
    --output tsv

Write-Host "Infrastructure and app deployment completed for resource group '$ResourceGroupName'."
Write-Host "App URL: https://$defaultHostName"
