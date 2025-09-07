# Database & Migration Testing Script for The Authority
# This script will test all database functionality

$ErrorActionPreference = 'Stop'

Write-Host "=== DATABASE & MIGRATION TESTING ===" -ForegroundColor Cyan
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

# Test 2: Test Database Connection
Write-Host "`n2. Testing Database Connection..." -ForegroundColor Green
try {
    # Read connection string from secrets.cfg
    $secretsContent = Get-Content "config/secrets.cfg" -Raw
    if ($secretsContent -match 'mysql://([^:]+):([^@]+)@([^/]+)/([^?]+)') {
        $username = $matches[1]
        $password = $matches[2]
        $dbHost = $matches[3]
        $database = $matches[4]
        
        Write-Host "Connection details: $username@$dbHost/$database" -ForegroundColor Gray
        
        # Test connection using mysql command line
        $connectionTest = mysql -u $username -p$password -h $dbHost -e "SELECT 1 as test;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Database Connection: Successful" -ForegroundColor Green
        } else {
            Write-Host "❌ Database Connection: Failed" -ForegroundColor Red
            Write-Host "Error: $connectionTest" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Could not parse connection string from config/secrets.cfg" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Database Connection: Error - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Check Database Exists
Write-Host "`n3. Testing Database Existence..." -ForegroundColor Green
try {
        $dbCheck = mysql -u $username -p$password -h $dbHost -e "SHOW DATABASES LIKE '$database';" 2>&1
    if ($dbCheck -match $database) {
        Write-Host "✅ Database '$database': Exists" -ForegroundColor Green
    } else {
        Write-Host "❌ Database '$database': Does not exist" -ForegroundColor Red
        Write-Host "Creating database..." -ForegroundColor Yellow
        mysql -u $username -p$password -h $dbHost -e "CREATE DATABASE IF NOT EXISTS $database;" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Database '$database': Created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Database '$database': Failed to create" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Database Check: Error - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Check Core Tables
Write-Host "`n4. Testing Core Tables..." -ForegroundColor Green
$coreTables = @('players', 'bans', 'player_groups', 'db_migrations')
$missingTables = @()

foreach ($table in $coreTables) {
    try {
        $tableCheck = mysql -u $username -p$password -h $dbHost -D $database -e "SHOW TABLES LIKE '$table';" 2>&1
        if ($tableCheck -match $table) {
            Write-Host "✅ Table '$table': Exists" -ForegroundColor Green
        } else {
            Write-Host "❌ Table '$table': Missing" -ForegroundColor Red
            $missingTables += $table
        }
    } catch {
        Write-Host "❌ Table '$table': Error checking - $($_.Exception.Message)" -ForegroundColor Red
        $missingTables += $table
    }
}

# Test 5: Check Migration Status
Write-Host "`n5. Testing Migration Status..." -ForegroundColor Green
try {
    $migrationCheck = mysql -u $username -p$password -h $dbHost -D $database -e "SELECT filename, applied_at FROM db_migrations ORDER BY applied_at;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Migration Table: Accessible" -ForegroundColor Green
        if ($migrationCheck -match "filename") {
            Write-Host "Applied Migrations:" -ForegroundColor Gray
            $migrationCheck | ForEach-Object { 
                if ($_ -match "(\d{4}-\d{2}-\d{2}-[^\s]+)") {
                    Write-Host "  ✅ $($matches[1])" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "⚠️ No migrations applied yet" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Migration Table: Not accessible" -ForegroundColor Red
        Write-Host "Error: $migrationCheck" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Migration Check: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Check Banking Tables
Write-Host "`n6. Testing Banking System Tables..." -ForegroundColor Green
$bankingTables = @('bank_accounts_new', 'bank_accounts', 'bank_statements', 'player_transactions')
foreach ($table in $bankingTables) {
    try {
        $tableCheck = mysql -u $username -p$password -h $dbHost -D $database -e "SHOW TABLES LIKE '$table';" 2>&1
        if ($tableCheck -match $table) {
            Write-Host "✅ Banking Table '$table': Exists" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Banking Table '$table': Missing (will be created by migration)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Banking Table '$table': Error checking" -ForegroundColor Red
    }
}

# Test 7: Check Vehicle Tables
Write-Host "`n7. Testing Vehicle System Tables..." -ForegroundColor Green
$vehicleTables = @('player_vehicles', 'vehicle_categories')
foreach ($table in $vehicleTables) {
    try {
        $tableCheck = mysql -u $username -p$password -h $dbHost -D $database -e "SHOW TABLES LIKE '$table';" 2>&1
        if ($tableCheck -match $table) {
            Write-Host "✅ Vehicle Table '$table': Exists" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Vehicle Table '$table': Missing (will be created by migration)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Vehicle Table '$table': Error checking" -ForegroundColor Red
    }
}

# Test 8: Check Appearance Tables
Write-Host "`n8. Testing Appearance System Tables..." -ForegroundColor Green
$appearanceTables = @('playerskins', 'player_outfits')
foreach ($table in $appearanceTables) {
    try {
        $tableCheck = mysql -u $username -p$password -h $dbHost -D $database -e "SHOW TABLES LIKE '$table';" 2>&1
        if ($tableCheck -match $table) {
            Write-Host "✅ Appearance Table '$table': Exists" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Appearance Table '$table': Missing (will be created by migration)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Appearance Table '$table': Error checking" -ForegroundColor Red
    }
}

# Test 9: Test Database Performance
Write-Host "`n9. Testing Database Performance..." -ForegroundColor Green
try {
    $startTime = Get-Date
    $perfTest = mysql -u $username -p$password -h $dbHost -D $database -e "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = '$database';" 2>&1
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database Performance: Query completed in $([math]::Round($duration, 2))ms" -ForegroundColor Green
        if ($perfTest -match "(\d+)") {
            Write-Host "  Tables in database: $($matches[1])" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ Database Performance: Query failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Database Performance: Error - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 10: Check Migration Files
Write-Host "`n10. Testing Migration Files..." -ForegroundColor Green
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

foreach ($file in $migrationFiles) {
    $filePath = "migrations\$file"
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length
        Write-Host "✅ Migration File '$file': Exists ($fileSize bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ Migration File '$file': Missing" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n=== DATABASE TESTING SUMMARY ===" -ForegroundColor Cyan
if ($missingTables.Count -eq 0) {
    Write-Host "✅ All core tables present" -ForegroundColor Green
} else {
    Write-Host "⚠️ Missing core tables: $($missingTables -join ', ')" -ForegroundColor Yellow
    Write-Host "These will be created when you run the server for the first time" -ForegroundColor Gray
}

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Start your FiveM server to run migrations automatically" -ForegroundColor White
Write-Host "2. Run /qa:base in-game to test database connection" -ForegroundColor White
Write-Host "3. Check server console for migration messages" -ForegroundColor White
Write-Host "4. Verify all tables are created after server startup" -ForegroundColor White

Write-Host "`nDatabase testing completed!" -ForegroundColor Green
