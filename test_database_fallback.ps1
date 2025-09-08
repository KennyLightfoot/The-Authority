# Database Testing Script - Fallback Version (No MySQL CLI Required)
# This script tests database functionality using alternative methods

$ErrorActionPreference = 'Stop'

Write-Host "=== DATABASE TESTING (FALLBACK) ===" -ForegroundColor Cyan
Write-Host "Testing The Authority server database setup without MySQL CLI..." -ForegroundColor Yellow

# Test 1: Check if MySQL CLI is available
Write-Host "`n1. Checking MySQL CLI Availability..." -ForegroundColor Green
$mysqlAvailable = $false
try {
    $null = Get-Command mysql -ErrorAction Stop
    $mysqlAvailable = $true
    Write-Host "✅ MySQL CLI: Available" -ForegroundColor Green
} catch {
    Write-Host "⚠️ MySQL CLI: Not available (using fallback tests)" -ForegroundColor Yellow
}

# Test 2: Check secrets configuration
Write-Host "`n2. Testing Configuration Files..." -ForegroundColor Green
if (Test-Path "config/secrets.cfg") {
    Write-Host "✅ secrets.cfg: Found" -ForegroundColor Green
    
    $secretsContent = Get-Content "config/secrets.cfg" -Raw
    if ($secretsContent -match 'mysql://([^:]+):([^@]+)@([^/]+)/([^?]+)') {
        $username = $matches[1]
        $password = $matches[2]
        $dbHost = $matches[3]
        $database = $matches[4]
        Write-Host "✅ Database Config: Parsed successfully" -ForegroundColor Green
        Write-Host "  Connection: $username@$dbHost/$database" -ForegroundColor Gray
    } else {
        Write-Host "❌ Database Config: Could not parse connection string" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ secrets.cfg: Not found" -ForegroundColor Red
    exit 1
}

# Test 3: Check migration files
Write-Host "`n3. Testing Migration Files..." -ForegroundColor Green
$migrationFiles = @(
    '2025-01-01-renewed_banking.sql',
    '2025-01-02-appearance.sql', 
    '2025-01-03-vehicles.sql',
    '2025-01-04-vehicle_keys.sql',
    '2025-01-05-npwd.sql',
    '2025-01-06-qa_bookkeeping.sql',
    '2025-01-07-bans.sql',
    '2025-01-08-telemetry.sql',
    '2025-01-09-authority.sql'
)

$missingMigrations = @()
foreach ($file in $migrationFiles) {
    $filePath = "migrations\$file"
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length
        Write-Host "✅ Migration '$file': Exists ($fileSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ Migration '$file': Missing" -ForegroundColor Red
        $missingMigrations += $file
    }
}

# Test 4: Check authority system files
Write-Host "`n4. Testing Authority System Files..." -ForegroundColor Green
$authorityFiles = @(
    'resources/[qbx]/qbx_core/shared/events.lua',
    'resources/[qbx]/qbx_core/shared/config.lua',
    'resources/[qbx]/qbx_core/server/authority_standing.lua',
    'resources/[qbx]/qbx_core/server/heat_system.lua',
    'resources/[qbx]/qbx_core/server/onboarding.lua',
    'resources/[qbx]/qbx_core/client/authority_hud.lua',
    'resources/[qbx]/qbx_core/client/heat_effects.lua',
    'resources/[qbx]/qbx_core/client/onboarding_ui.lua',
    'resources/[standalone]/authority_season/fxmanifest.lua',
    'resources/[standalone]/authority_season/shared/config.lua',
    'resources/[standalone]/authority_season/client/season_ui.lua',
    'resources/[standalone]/authority_season/server/resistance_pass.lua',
    'resources/[standalone]/authority_season/server/season_events.lua'
)

$missingAuthorityFiles = @()
foreach ($file in $authorityFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Authority File '$file': Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ Authority File '$file': Missing" -ForegroundColor Red
        $missingAuthorityFiles += $file
    }
}

# Test 5: Check server configuration
Write-Host "`n5. Testing Server Configuration..." -ForegroundColor Green
if (Test-Path "server.cfg") {
    Write-Host "✅ server.cfg: Found" -ForegroundColor Green
    
    $serverCfg = Get-Content "server.cfg" -Raw
    
    # Check for authority_season in ensure list
    if ($serverCfg -match "ensure\s+authority_season") {
        Write-Host "✅ authority_season: Ensured in server.cfg" -ForegroundColor Green
    } else {
        Write-Host "⚠️ authority_season: Not found in server.cfg" -ForegroundColor Yellow
    }
    
    # Check for required dependencies
    $requiredDeps = @('oxmysql', 'ox_lib', 'qbx_core', 'PolyZone', 'pma-voice')
    foreach ($dep in $requiredDeps) {
        if ($serverCfg -match "ensure\s+$dep") {
            Write-Host "✅ Dependency '$dep': Ensured" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Dependency '$dep': Not found in server.cfg" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ server.cfg: Not found" -ForegroundColor Red
}

# Test 6: Check db_migrator configuration
Write-Host "`n6. Testing Database Migrator..." -ForegroundColor Green
$migratorPath = "resources/[local]/db_migrator/server/migrator.lua"
if (Test-Path $migratorPath) {
    Write-Host "✅ db_migrator: Found" -ForegroundColor Green
    
    $migratorContent = Get-Content $migratorPath -Raw
    if ($migratorContent -match "2025-01-09-authority.sql") {
        Write-Host "✅ Authority Migration: Registered in migrator" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Authority Migration: Not registered in migrator" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ db_migrator: Not found" -ForegroundColor Red
}

# Test 7: Validate Lua syntax (if luacheck available)
Write-Host "`n7. Testing Lua Syntax..." -ForegroundColor Green
try {
    $null = Get-Command luacheck -ErrorAction Stop
    Write-Host "✅ luacheck: Available" -ForegroundColor Green
    
    # Test authority files
    $authorityLuaFiles = Get-ChildItem -Path "resources/[qbx]/qbx_core" -Recurse -Filter "*.lua" | Where-Object { $_.Name -match "(authority|heat|onboarding)" }
    $authoritySeasonFiles = Get-ChildItem -Path "resources/[standalone]/authority_season" -Recurse -Filter "*.lua"
    
    $allFiles = @($authorityLuaFiles) + @($authoritySeasonFiles)
    
    if ($allFiles.Count -gt 0) {
        Write-Host "Running luacheck on authority files..." -ForegroundColor Gray
        luacheck $allFiles.FullName --std=lua54 --no-color | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Lua Syntax: All authority files valid" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Lua Syntax: Some issues found (see above)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "⚠️ luacheck: Not available (run scripts/install-lua.ps1)" -ForegroundColor Yellow
}

# Summary
Write-Host "`n=== FALLBACK TESTING SUMMARY ===" -ForegroundColor Cyan

if ($missingMigrations.Count -eq 0) {
    Write-Host "✅ All migration files present" -ForegroundColor Green
} else {
    Write-Host "⚠️ Missing migrations: $($missingMigrations -join ', ')" -ForegroundColor Yellow
}

if ($missingAuthorityFiles.Count -eq 0) {
    Write-Host "✅ All authority system files present" -ForegroundColor Green
} else {
    Write-Host "❌ Missing authority files: $($missingAuthorityFiles -join ', ')" -ForegroundColor Red
}

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
if ($mysqlAvailable) {
    Write-Host "1. Run .\test_database.ps1 for full database testing" -ForegroundColor White
} else {
    Write-Host "1. Install MySQL command line tools for full database testing" -ForegroundColor White
    Write-Host "   - Download from: https://dev.mysql.com/downloads/mysql/" -ForegroundColor Gray
    Write-Host "   - Or install via: winget install Oracle.MySQL" -ForegroundColor Gray
}
Write-Host "2. Start your FiveM server to run migrations automatically" -ForegroundColor White
Write-Host "3. Check server console for migration messages" -ForegroundColor White
Write-Host "4. Test authority system in-game with /start_onboarding and /auth_add commands" -ForegroundColor White

Write-Host "`nFallback testing completed!" -ForegroundColor Green

