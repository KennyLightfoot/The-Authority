param(
    [switch]$VerboseOutput
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host "[verify_admin] $msg" -ForegroundColor Cyan }
function Write-Ok($msg){ Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Set-Location $Root

Write-Info "Root: $Root"

$cfgPath = Join-Path $Root 'server.cfg'
if (-not (Test-Path $cfgPath)) { Write-Err "server.cfg not found"; exit 1 }

$cfg = Get-Content -LiteralPath $cfgPath -Raw

# Ensure resource is ensured
if ($cfg -match "(?im)^\s*ensure\s+qbx_admin\s*$") { Write-Ok 'server.cfg ensures qbx_admin' } else { Write-Err 'server.cfg missing: ensure qbx_admin'; $missingEnsure=$true }

# Check ACE permissions present
$requiredAce = @(
    'qbxadmin.money','qbxadmin.job','qbxadmin.gang','qbxadmin.info','qbxadmin.heal','qbxadmin.revive'
)
$aceMissing = @()
foreach($k in $requiredAce){ if($cfg -notmatch [regex]::Escape("add_ace group.admin $k allow")){ $aceMissing += $k } }
if($aceMissing.Count -eq 0){ Write-Ok 'ACE permissions present for group.admin' } else { Write-Warn ("Missing ACE for: " + ($aceMissing -join ', ')) }

# Check webhooks (optional)
if ($cfg -match 'set\s+qbx_admin_webhook\s+"https?://') { Write-Ok 'Default webhook configured' } else { Write-Warn 'Default webhook not configured (ok to skip)'}

# Validate resource files exist
$resDir = Join-Path $Root 'resources\[admin]\qbx_admin'
$files = 'fxmanifest.lua','config.lua','server.lua','client.lua'
foreach($f in $files){
    $p = Join-Path $resDir $f
    if(Test-Path -LiteralPath $p){ Write-Ok "Found: $f" } else { Write-Err "Missing: $f"; $missing=$true }
}

# Quick sanity checks within files
${fxPath} = Join-Path $resDir 'fxmanifest.lua'
if (Test-Path -LiteralPath ${fxPath}) {
    $fx = Get-Content -LiteralPath ${fxPath} -Raw
} else {
    $fx = ''
}
if($fx -match '@ox_lib/init.lua'){ Write-Ok 'fxmanifest includes @ox_lib/init.lua' } else { Write-Warn 'fxmanifest missing @ox_lib/init.lua' }
if($fx -match "dependencies\s*{[\s\S]*qbx_core[\s\S]*ox_lib"){ Write-Ok 'fxmanifest dependencies ok' } else { Write-Warn 'fxmanifest dependencies missing qbx_core/ox_lib' }

$cfgLuaPath = Join-Path $resDir 'config.lua'
if (Test-Path -LiteralPath $cfgLuaPath) { $cfgLua = Get-Content -LiteralPath $cfgLuaPath -Raw } else { $cfgLua = '' }
if($cfgLua -match 'Config\.Webhooks\s*=\s*{[\s\S]*default'){ Write-Ok 'config.lua has lowercase webhook keys' } else { Write-Warn 'config.lua webhook keys may be outdated' }

if($missingEnsure -or $missing){ exit 2 }

Write-Info 'Verification complete.'
exit 0


