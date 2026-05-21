<#
.SYNOPSIS
    Compile the OpenDIMS Business Central extension to a .app file.

.DESCRIPTION
    Cross-platform PowerShell build script. Runs on Windows, Linux and macOS
    via PowerShell 7 (pwsh). Uses BcContainerHelper's compiler-folder mode,
    which downloads only the bare AL compiler and platform symbols from
    Microsoft's BC artifacts CDN — no Docker, no Windows container required.

.PARAMETER OutputFolder
    Directory where the compiled .app is placed. Defaults to ./out next to this script.

.PARAMETER BcVersion
    BC platform version to compile against (e.g. "22.0"). Defaults to the
    major.minor from app.json.

.EXAMPLE
    pwsh -File ./build.ps1
    pwsh -File ./build.ps1 -BcVersion 23.0 -OutputFolder /tmp/bc-out
#>
[CmdletBinding()]
param(
    [string]$OutputFolder = (Join-Path $PSScriptRoot 'out'),
    [string]$BcVersion = ''
)

$ErrorActionPreference = 'Stop'

$projectFolder = $PSScriptRoot
$appJsonPath   = Join-Path $projectFolder 'app.json'

if (-not (Test-Path $appJsonPath)) {
    throw "app.json not found at $appJsonPath"
}

Write-Host "==> Ensuring BcContainerHelper is installed"
if (-not (Get-Module -ListAvailable -Name BcContainerHelper)) {
    Install-Module -Name BcContainerHelper -Force -AllowClobber -Scope CurrentUser -AcceptLicense
}
Import-Module BcContainerHelper

# Resolve BC version
$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($BcVersion)) {
    $BcVersion = ($appJson.application -split '\.')[0..1] -join '.'
}
Write-Host "==> Compiling against BC version $BcVersion"

New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
$symbolsFolder = Join-Path $projectFolder '.alpackages'
New-Item -ItemType Directory -Force -Path $symbolsFolder | Out-Null

$artifactUrl = Get-BCArtifactUrl -type Sandbox -country w1 -version $BcVersion -select Latest
Write-Host "==> Using artifact URL: $artifactUrl"

$compilerFolder = New-BcCompilerFolder -artifactUrl $artifactUrl
try {
    $appFile = Compile-AppInBcCompilerFolder `
        -compilerFolder $compilerFolder `
        -appProjectFolder $projectFolder `
        -appOutputFolder $OutputFolder `
        -appSymbolsFolder $symbolsFolder

    if (-not $appFile -or -not (Test-Path $appFile)) {
        throw "Compilation did not produce a .app file"
    }

    $finalPath = Join-Path $OutputFolder 'opendims-bc-extension.app'
    Copy-Item -Path $appFile -Destination $finalPath -Force
    Write-Host "==> Built $finalPath"
} finally {
    Remove-BcCompilerFolder -compilerFolder $compilerFolder
}
