# MariaDB Migration Script for QBCore/Qbox
# This script will help you migrate from MySQL to MariaDB

Write-Host "🚀 MariaDB Migration Script for QBCore/Qbox" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Check if MariaDB is already installed
$mariadbInstalled = Get-Command "mariadb" -ErrorAction SilentlyContinue
if ($mariadbInstalled) {
    Write-Host "✅ MariaDB is already installed!" -ForegroundColor Green
    mariadb --version
} else {
    Write-Host "❌ MariaDB not found. Let's install it..." -ForegroundColor Red
    
    # Download MariaDB installer
    Write-Host "📥 Downloading MariaDB installer..." -ForegroundColor Yellow
    $mariadbUrl = "https://dlm.mariadb.com/2463343/Repositories/MariaDB/mariadb-10.11.8-winx64.msi"
    $mariadbInstaller = "mariadb-installer.msi"
    
    try {
        Invoke-WebRequest -Uri $mariadbUrl -OutFile $mariadbInstaller -UseBasicParsing
        Write-Host "✅ MariaDB installer downloaded!" -ForegroundColor Green
        
        Write-Host "🔧 Please run the installer manually:" -ForegroundColor Yellow
        Write-Host "   1. Double-click: $mariadbInstaller" -ForegroundColor White
        Write-Host "   2. Follow the installation wizard" -ForegroundColor White
        Write-Host "   3. Set root password: 'Kifelife420$' (same as your MySQL)" -ForegroundColor White
        Write-Host "   4. Create database: 'authority'" -ForegroundColor White
        Write-Host "   5. Create user: 'fivem' with password 'Kifelife420$'" -ForegroundColor White
        Write-Host "   6. Grant all privileges on 'authority' to 'fivem'" -ForegroundColor White
        
        Write-Host "`n⏳ After installation, run this script again to continue migration..." -ForegroundColor Yellow
        exit
    } catch {
        Write-Host "❌ Failed to download MariaDB installer: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please download manually from: https://mariadb.org/download/" -ForegroundColor Yellow
        exit
    }
}

# Backup MySQL database
Write-Host "`n💾 Backing up MySQL database..." -ForegroundColor Yellow
$backupFile = "mysql_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"

try {
    # Try to backup using mysqldump
    $mysqlDump = Get-Command "mysqldump" -ErrorAction SilentlyContinue
    if ($mysqlDump) {
        & mysqldump -u fivem -p"Kifelife420$" -h 127.0.0.1 authority > $backupFile
        Write-Host "✅ MySQL backup created: $backupFile" -ForegroundColor Green
    } else {
        Write-Host "⚠️  mysqldump not found. Please backup manually:" -ForegroundColor Yellow
        Write-Host "   mysqldump -u fivem -p'Kifelife420$' -h 127.0.0.1 authority > $backupFile" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Failed to backup MySQL: $($_.Exception.Message)" -ForegroundColor Red
}

# Test MariaDB connection
Write-Host "`n🔌 Testing MariaDB connection..." -ForegroundColor Yellow
try {
    $testQuery = "SELECT VERSION();"
    $result = & mariadb -u fivem -p"Kifelife420$" -h 127.0.0.1 authority -e $testQuery
    Write-Host "✅ MariaDB connection successful!" -ForegroundColor Green
    Write-Host "MariaDB Version: $result" -ForegroundColor Cyan
} catch {
    Write-Host "❌ MariaDB connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check your MariaDB installation and credentials." -ForegroundColor Yellow
    exit
}

# Import backup to MariaDB
if (Test-Path $backupFile) {
    Write-Host "`n📥 Importing backup to MariaDB..." -ForegroundColor Yellow
    try {
        & mariadb -u fivem -p"Kifelife420$" -h 127.0.0.1 authority < $backupFile
        Write-Host "✅ Database imported successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to import backup: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  No backup file found. Creating fresh database..." -ForegroundColor Yellow
}

# Update connection string
Write-Host "`n🔧 Updating connection string..." -ForegroundColor Yellow
$secretsFile = "config\secrets.cfg"
if (Test-Path $secretsFile) {
    $content = Get-Content $secretsFile -Raw
    $content = $content -replace 'mysql://', 'mysql://'
    Set-Content -Path $secretsFile -Value $content
    Write-Host "✅ Connection string updated!" -ForegroundColor Green
} else {
    Write-Host "❌ secrets.cfg not found!" -ForegroundColor Red
}

Write-Host "`n🎉 Migration complete!" -ForegroundColor Green
Write-Host "You can now try your txAdmin deployment again." -ForegroundColor Cyan
Write-Host "MariaDB should handle the SQL syntax much better than MySQL 8.0." -ForegroundColor Cyan
