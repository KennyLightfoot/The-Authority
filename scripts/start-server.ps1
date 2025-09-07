param(
    [string]$Cfg = 'server.cfg',
    [string]$FXServerPath = $null
)

$ErrorActionPreference = 'Stop'

Write-Host "==> Running sanity checks" -ForegroundColor Cyan
& "$PSScriptRoot/sanity-check.ps1"

Write-Host "==> Locating FXServer" -ForegroundColor Cyan
if (-not $FXServerPath) {
    # Try typical locations
    $candidates = @(
        "$PSScriptRoot/../tmp/cfx-server-data-master/run.cmd",
        "$PSScriptRoot/../tmp/cfx-server-data-master/FXServer.exe",
        "$PSScriptRoot/../FiveM-Server/FXServer.exe",
        "$env:LOCALAPPDATA/FiveM/FXServer.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { $FXServerPath = $c; break } }
}

if (-not $FXServerPath) {
    Write-Host "FXServer not found. Please specify -FXServerPath pointing to FXServer.exe (or run.cmd)." -ForegroundColor Red
    exit 1
}

Write-Host "Using FXServer: $FXServerPath" -ForegroundColor Green

if ($FXServerPath.ToLower().EndsWith('run.cmd')) {
    & $FXServerPath + " +exec $Cfg"
} else {
    & $FXServerPath + " +exec $Cfg"
}


