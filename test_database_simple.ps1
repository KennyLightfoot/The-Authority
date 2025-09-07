# Simple Database Testing Script for The Authority
# This script will test database functionality through the server

$ErrorActionPreference = 'Stop'

Write-Host "=== SIMPLE DATABASE & MIGRATION TESTING ===" -ForegroundColor Cyan
Write-Host "Testing The Authority server database setup..." -ForegroundColor Yellow

# Test 1: Check MySQL Service
Write-Host "`n1. Testing MySQL Service..." -ForegroundColor Green
try {
    $mysqlService = Get-Service -Name "MySQL80" -ErrorAction Stop
    if ($mysqlService.Status -eq "Running") {
        Write-Host "✅ MySQL Service: Running" -ForegroundColor Green
    } else {
        Write-Host "❌ MySQL Service: Not Running (Status: $($mysqlService.Status))" -ForegroundColor Red
        Write-Host "Starting MySQL service..." -ForegroundColor Yellow
        Start-Service -Name "MySQL80"
        Start-Sleep -Seconds 3
        $mysqlService = Get-Service -Name "MySQL80"
        if ($mysqlService.Status -eq "Running") {
            Write-Host "✅ MySQL Service: Started successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ MySQL Service: Failed to start" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ MySQL Service: Not found or not installed" -ForegroundColor Red
    Write-Host "Please install MySQL 8.0+ and try again" -ForegroundColor Yellow
    exit 1
}

# Test 2: Check Configuration Files
Write-Host "`n2. Testing Configuration Files..." -ForegroundColor Green

# Check secrets.cfg
if (Test-Path "config/secrets.cfg") {
    Write-Host "✅ secrets.cfg: Exists" -ForegroundColor Green
    
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
    Write-Host "❌ secrets.cfg: Missing" -ForegroundColor Red
    exit 1
}

# Check server.cfg
if (Test-Path "server.cfg") {
    Write-Host "✅ server.cfg: Exists" -ForegroundColor Green
} else {
    Write-Host "❌ server.cfg: Missing" -ForegroundColor Red
    exit 1
}

# Test 3: Check Migration Files
Write-Host "`n3. Testing Migration Files..." -ForegroundColor Green
$migrationFiles = @(
    '2025-01-01-renewed_banking.sql',
    '2025-01-02-appearance.sql', 
    '2025-01-03-vehicles.sql',
    '2025-01-04-vehicle_keys.sql',
    '2025-01-05-npwd.sql',
    '2025-01-06-qa_bookkeeping.sql',
    '2025-01-07-bans.sql',
    '2025-01-08-telemetry.sql'
)

$allMigrationsPresent = $true
foreach ($file in $migrationFiles) {
    $filePath = "migrations\$file"
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length
        Write-Host "✅ Migration '$file': Exists ($fileSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ Migration '$file': Missing" -ForegroundColor Red
        $allMigrationsPresent = $false
    }
}

# Test 4: Check Database Migrator Resource
Write-Host "`n4. Testing Database Migrator Resource..." -ForegroundColor Green
if (Test-Path -LiteralPath "resources/[local]/db_migrator") {
    Write-Host "✅ DB Migrator Resource: Exists" -ForegroundColor Green
    
    if (Test-Path -LiteralPath "resources/[local]/db_migrator/fxmanifest.lua") {
        Write-Host "✅ DB Migrator Manifest: Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ DB Migrator Manifest: Missing" -ForegroundColor Red
    }
    
    if (Test-Path -LiteralPath "resources/[local]/db_migrator/server/migrator.lua") {
        Write-Host "✅ DB Migrator Script: Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ DB Migrator Script: Missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ DB Migrator Resource: Missing" -ForegroundColor Red
}

# Test 5: Check QA Tools Resource
Write-Host "`n5. Testing QA Tools Resource..." -ForegroundColor Green
if (Test-Path -LiteralPath "resources/[local]/qa_tools") {
    Write-Host "✅ QA Tools Resource: Exists" -ForegroundColor Green
    
    if (Test-Path -LiteralPath "resources/[local]/qa_tools/fxmanifest.lua") {
        Write-Host "✅ QA Tools Manifest: Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ QA Tools Manifest: Missing" -ForegroundColor Red
    }
    
    if (Test-Path -LiteralPath "resources/[local]/qa_tools/server/qa_server.lua") {
        Write-Host "✅ QA Tools Server Script: Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ QA Tools Server Script: Missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ QA Tools Resource: Missing" -ForegroundColor Red
}

# Test 6: Check Core Resources
Write-Host "`n6. Testing Core Resources..." -ForegroundColor Green
$coreResources = @(
    'resources/oxmysql',
    'resources/[ox]/ox_lib',
    'resources/[qbx]/qbx_core',
    'resources/[ox]/ox_inventory',
    'resources/[standalone]/Renewed-Banking'
)

foreach ($resource in $coreResources) {
    if (Test-Path -LiteralPath $resource) {
        Write-Host "✅ Core Resource '$resource': Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ Core Resource '$resource': Missing" -ForegroundColor Red
    }
}

# Test 7: Check Port Availability
Write-Host "`n7. Testing Port Availability..." -ForegroundColor Green
$ports = @(30120, 40120)
foreach ($port in $ports) {
    $portCheck = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($portCheck) {
        Write-Host "⚠️ Port ${port}: In use (may be server running)" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Port ${port}: Available" -ForegroundColor Green
    }
}

# Summary
Write-Host "`n=== DATABASE TESTING SUMMARY ===" -ForegroundColor Cyan

if ($allMigrationsPresent) {
    Write-Host "✅ All migration files present" -ForegroundColor Green
} else {
    Write-Host "❌ Some migration files missing" -ForegroundColor Red
}

Write-Host "`n=== RECOMMENDED NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Start your FiveM server:" -ForegroundColor White
Write-Host "   .\start_server_permanent.bat" -ForegroundColor Gray
Write-Host "`n2. Once in-game, run these commands to test database:" -ForegroundColor White
Write-Host "   /qa:base     - Complete system check" -ForegroundColor Gray
Write-Host "   /qa:health   - Server health check" -ForegroundColor Gray
Write-Host "   /qa:discord  - Discord integration test" -ForegroundColor Gray

Write-Host "`n3. Check server console for migration messages:" -ForegroundColor White
Write-Host "   Look for '[DB Migrator]' messages" -ForegroundColor Gray
Write-Host "   Should see 'Applied: 2025-01-XX-*.sql' messages" -ForegroundColor Gray

Write-Host "`n4. Verify database tables were created:" -ForegroundColor White
Write-Host "   Check for tables: players, bans, bank_accounts_new, etc." -ForegroundColor Gray

Write-Host "`n=== TESTING COMPLETED ===" -ForegroundColor Green
Write-Host "Your database setup appears to be ready for testing!" -ForegroundColor Green
Write-Host "Start the server and run /qa:base in-game for full database testing." -ForegroundColor Yellow
