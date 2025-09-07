$ErrorActionPreference = 'Stop'

function Test-File($path){ if (-not (Test-Path $path)) { throw "Missing: $path" } }

Write-Host "==> Sanity checks" -ForegroundColor Cyan

Test-File 'server.cfg'
Test-File 'config/secrets.cfg'

Write-Host "Checking required resources..." -ForegroundColor Cyan
$required = @(
    'resources/oxmysql',
    'resources/[standalone]/EasyAdmin',
    'resources/[standalone]/Badger_Discord_API',
    'resources/[ox]/ox_lib'
)
$missing = @()
foreach ($r in $required) { if (-not (Test-Path $r)) { $missing += $r } }
if ($missing.Count -gt 0) {
    Write-Host "Missing resources:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 2
} else {
    Write-Host "All required resources present." -ForegroundColor Green
}

Write-Host "Validating secrets placeholders replaced..." -ForegroundColor Cyan
$secrets = Get-Content 'config/secrets.cfg' -Raw
if ($secrets -match 'YOUR_') {
    Write-Host "Secrets contain placeholders. Update config/secrets.cfg before production." -ForegroundColor Yellow
}

Write-Host "==> Sanity OK" -ForegroundColor Green


