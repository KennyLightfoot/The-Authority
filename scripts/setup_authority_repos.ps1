param(
    [string]$BaseResourcesDir = 'C:\fivem-server\resources'
)

$ErrorActionPreference = 'Stop'

function Write-Info([string]$Message) {
    Write-Host ("[INFO] {0}" -f $Message)
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Upsert-Repo([string]$RepoUrl, [string]$DestPath) {
    if (Test-Path -LiteralPath (Join-Path $DestPath '.git')) {
        Write-Info ("Updating repo in {0}" -f $DestPath)
        git -C $DestPath fetch --all --quiet
        git -C $DestPath reset --hard origin/HEAD --quiet
    } elseif (Test-Path -LiteralPath $DestPath) {
        Write-Warning ("Skipping non-git folder: {0}" -f $DestPath)
    } else {
        Write-Info ("Cloning {0} -> {1}" -f $RepoUrl, $DestPath)
        git clone --depth 1 $RepoUrl $DestPath | Out-Null
    }
}

function Upsert-RepoWithFallback([string[]]$RepoUrls, [string]$DestPath) {
    foreach ($repo in $RepoUrls) {
        try {
            Upsert-Repo $repo $DestPath
            if (Test-Path -LiteralPath $DestPath) { return }
        } catch {
            Write-Warning ("Failed cloning {0}: {1}" -f $repo, $_.Exception.Message)
        }
    }
}

# Determine resources directory, fallback to current workspace resources
if (-not (Test-Path -LiteralPath $BaseResourcesDir)) {
    $workspaceResources = Join-Path $PSScriptRoot '..' | Resolve-Path | ForEach-Object { $_.Path }
    $workspaceResources = Join-Path $workspaceResources 'resources'
    if (-not (Test-Path -LiteralPath $workspaceResources)) {
        throw "Resources directory not found at '$BaseResourcesDir' or '$workspaceResources'"
    }
    $BaseResourcesDir = $workspaceResources
}

Write-Info ("Using resources path: {0}" -f $BaseResourcesDir)

# Create category folders
$categories = @('[core]', '[system]', '[banking]', '[appearance]', '[qbx]', '[standalone]', '[jobs]')
foreach ($cat in $categories) {
    Ensure-Directory (Join-Path $BaseResourcesDir $cat)
}

# Core dependencies
Upsert-Repo 'https://github.com/overextended/ox_lib.git'            (Join-Path $BaseResourcesDir '[core]/ox_lib')
Upsert-Repo 'https://github.com/overextended/ox_inventory.git'      (Join-Path $BaseResourcesDir '[core]/ox_inventory')
Upsert-Repo 'https://github.com/overextended/ox_target.git'         (Join-Path $BaseResourcesDir '[core]/ox_target')
Upsert-Repo 'https://github.com/mkafrin/PolyZone.git'               (Join-Path $BaseResourcesDir '[core]/PolyZone')
Upsert-Repo 'https://github.com/AvarianKnight/pma-voice.git'        (Join-Path $BaseResourcesDir '[core]/pma-voice')
Upsert-Repo 'https://github.com/overextended/oxmysql.git'           (Join-Path $BaseResourcesDir '[system]/oxmysql')
Upsert-Repo 'https://github.com/Renewed-Scripts/Renewed-Banking.git' (Join-Path $BaseResourcesDir '[banking]/Renewed-Banking')
Upsert-Repo 'https://github.com/iLLeniumStudios/illenium-appearance.git' (Join-Path $BaseResourcesDir '[appearance]/illenium-appearance')
Upsert-Repo 'https://github.com/Qbox-project/qbx_core.git'          (Join-Path $BaseResourcesDir '[qbx]/qbx_core')
Upsert-Repo 'https://github.com/Qbox-project/qbx_management.git'    (Join-Path $BaseResourcesDir '[qbx]/qbx_management')
Upsert-Repo 'https://github.com/Qbox-project/qbx_smallresources.git' (Join-Path $BaseResourcesDir '[qbx]/qbx_smallresources')
Upsert-Repo 'https://github.com/Qbox-project/qbx_garages.git'       (Join-Path $BaseResourcesDir '[qbx]/qbx_garages')
Upsert-Repo 'https://github.com/Qbox-project/qbx_vehiclekeys.git'   (Join-Path $BaseResourcesDir '[qbx]/qbx_vehiclekeys')

# Phone
Upsert-RepoWithFallback @('https://github.com/project-error/npwd.git','https://github.com/npwd-community/npwd.git') (Join-Path $BaseResourcesDir '[standalone]/npwd')
Upsert-Repo 'https://github.com/citizenfx/screenshot-basic.git'     (Join-Path $BaseResourcesDir '[standalone]/screenshot-basic')

# PD/EMS
Upsert-Repo 'https://github.com/Qbox-project/qbx_policejob.git'     (Join-Path $BaseResourcesDir '[qbx]/qbx_policejob')
Upsert-Repo 'https://github.com/Qbox-project/qbx_ambulancejob.git'  (Join-Path $BaseResourcesDir '[qbx]/qbx_ambulancejob')

# World systems
Upsert-Repo 'https://github.com/Qbox-project/qbx_houses.git'        (Join-Path $BaseResourcesDir '[qbx]/qbx_houses')
Upsert-Repo 'https://github.com/qbcore-framework/qb-fuel.git'       (Join-Path $BaseResourcesDir '[standalone]/qb-fuel')
Upsert-Repo 'https://github.com/qbcore-framework/qb-weathersync.git' (Join-Path $BaseResourcesDir '[standalone]/qb-weathersync')

# Jobs
Upsert-Repo 'https://github.com/qbcore-framework/qb-busjob.git'     (Join-Path $BaseResourcesDir '[jobs]/qb-busjob')
Upsert-Repo 'https://github.com/jimathy/jim-mining.git'             (Join-Path $BaseResourcesDir '[jobs]/jim-mining')
Upsert-Repo 'https://github.com/jimathy/jim-mechanic.git'           (Join-Path $BaseResourcesDir '[jobs]/jim-mechanic')
## Optional alternative recycle job repos are often private or renamed; skipping by default

# Optional engagement
## qbx_gangs repo frequently private/archived; skipping by default
Upsert-Repo 'https://github.com/qbcore-framework/qb-casino.git'     (Join-Path $BaseResourcesDir '[standalone]/qb-casino')

# Build NPWD web
$npwdWeb = Join-Path $BaseResourcesDir '[standalone]/npwd/web'
if (Test-Path -LiteralPath $npwdWeb) {
    Push-Location $npwdWeb
    if (Get-Command pnpm -ErrorAction SilentlyContinue) {
        Write-Info 'Installing NPWD web dependencies with pnpm...'
        pnpm install --frozen-lockfile --prefer-offline
        Write-Info 'Building NPWD web...'
        pnpm build
    } else {
        Write-Warning 'pnpm not found in PATH. Skipping NPWD build.'
    }
    Pop-Location
} else {
    Write-Info 'NPWD web directory not found, skipping build.'
}

Write-Info 'All repositories up to date.'

