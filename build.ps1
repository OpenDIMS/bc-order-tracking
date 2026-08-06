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
# Progress bars use cursor-positioning escapes that can wedge pwsh on Linux
# when the console is a docker pseudo-tty nobody consumes (build hung mid
# symbol copy at ~0.2% CPU). Also keeps CI logs clean.
$ProgressPreference = 'SilentlyContinue'

$projectFolder = $PSScriptRoot
$appJsonPath   = Join-Path $projectFolder 'app.json'

if (-not (Test-Path $appJsonPath)) {
    throw "app.json not found at $appJsonPath"
}

Write-Host "==> Ensuring BcContainerHelper is installed"
# Pinned EXACTLY: 6.1.14 is the first version with the cross-platform
# Compile-AppInBcCompilerFolder cmdlet, and 6.1.15 regressed New-BcCompilerFolder
# on Linux (the ALLanguage.vsix is never extracted, so compile dies with
# "Cannot find path '.../compiler/extension/bin/alc.dll'"). Bump deliberately.
$requiredVersion = [Version]'6.1.14'
$available = Get-Module -ListAvailable -Name BcContainerHelper |
    Where-Object { $_.Version -eq $requiredVersion } |
    Select-Object -First 1
if (-not $available) {
    Write-Host "    Installing BcContainerHelper $requiredVersion"
    Install-Module -Name BcContainerHelper -RequiredVersion $requiredVersion -Force -AllowClobber -Scope CurrentUser -AcceptLicense
}
# Drop any other version that might already be loaded in this session, then load the pinned one.
Remove-Module BcContainerHelper -Force -ErrorAction SilentlyContinue
Import-Module BcContainerHelper -RequiredVersion $requiredVersion -Force
$loaded = Get-Module BcContainerHelper
Write-Host "    Using BcContainerHelper $($loaded.Version) from $($loaded.Path)"

# Resolve BC version
$appJson = Get-Content $appJsonPath -Raw | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($BcVersion)) {
    $BcVersion = ($appJson.application -split '\.')[0..1] -join '.'
}
Write-Host "==> Compiling against BC version $BcVersion"

New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null
$symbolsFolder = Join-Path $projectFolder '.alpackages'
New-Item -ItemType Directory -Force -Path $symbolsFolder | Out-Null

# BcContainerHelper renamed the compile cmdlet at least once. Try the known names in order,
# so the script keeps working across versions. Resolve BEFORE downloading platform artifacts
# (which takes ~6 minutes) so we fail fast on a name mismatch.
$compileCandidates = @(
    'Compile-AppInBcCompilerFolder',
    'Compile-AppWithBcCompilerFolder',
    'Compile-AppInCompilerFolder',
    'Compile-AppWithCompilerFolder'
)
$compileCmd = $null
foreach ($name in $compileCandidates) {
    if (Get-Command -Name $name -Module BcContainerHelper -ErrorAction SilentlyContinue) {
        $compileCmd = $name
        break
    }
}
if (-not $compileCmd) {
    Write-Host "==> Available compile/build cmdlets in BcContainerHelper $($loaded.Version):"
    Get-Command -Module BcContainerHelper |
        Where-Object { $_.Name -match '^(Compile|Build|Invoke|Run)-' } |
        ForEach-Object { Write-Host "    - $($_.Name)" }
    throw "No known compile cmdlet found in BcContainerHelper $($loaded.Version). See list above."
}
Write-Host "==> Using compile cmdlet: $compileCmd"

$artifactUrl = Get-BCArtifactUrl -type Sandbox -country w1 -version $BcVersion -select Latest
Write-Host "==> Using artifact URL: $artifactUrl"

# vsixFile 'latest' pulls the newest AL Language extension from the VS
# marketplace instead of the artifact's own vsix. Required on Linux/macOS for
# BC 22.0 artifacts: their bundled vsix ships only a Windows .NET-Framework
# alc.exe (no bin/linux/, no portable alc.dll), so compiles die with
# "Cannot find path '.../compiler/extension/bin/alc.dll'". Newer AL compilers
# compile older-runtime apps fine.
$compilerFolder = New-BcCompilerFolder -artifactUrl $artifactUrl -vsixFile 'latest'

try {
    $appFile = & $compileCmd `
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
