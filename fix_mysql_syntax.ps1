# Quick fix for MySQL 8.0 syntax issues
# This creates a MySQL-compatible version of the SQL file

Write-Host "🔧 Creating MySQL 8.0 compatible SQL file..." -ForegroundColor Yellow

# Find the latest deployment profile
$latestProfile = Get-ChildItem -Path "txData" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestProfile) {
    $sqlFile = Join-Path $latestProfile.FullName "resources\[qbx]\qbx_core\qbx_core.sql"
    
    if (Test-Path $sqlFile) {
        Write-Host "📁 Found SQL file: $sqlFile" -ForegroundColor Cyan
        
        $content = Get-Content $sqlFile -Raw
        
        # Fix the problematic syntax for MySQL 8.0
        $content = $content -replace "ADD COLUMN IF NOT EXISTS `last_logged_out` timestamp NULL DEFAULT NULL AFTER `last_updated`,", "ADD COLUMN `last_logged_out` timestamp NULL DEFAULT NULL AFTER `last_updated`,"
        $content = $content -replace "ADD COLUMN IF NOT EXISTS `userId` INT UNSIGNED DEFAULT NULL AFTER `id`;", "ADD COLUMN `userId` INT UNSIGNED DEFAULT NULL AFTER `id`;"
        
        # Write the fixed content back
        Set-Content -Path $sqlFile -Value $content -NoNewline
        
        Write-Host "✅ SQL file fixed for MySQL 8.0!" -ForegroundColor Green
        Write-Host "🎯 You can now retry your txAdmin deployment." -ForegroundColor Cyan
    } else {
        Write-Host "❌ SQL file not found in latest profile" -ForegroundColor Red
    }
} else {
    Write-Host "❌ No deployment profiles found" -ForegroundColor Red
}

Write-Host "`n💡 For a permanent solution, consider migrating to MariaDB:" -ForegroundColor Yellow
Write-Host "   Run: .\migrate_to_mariadb.ps1" -ForegroundColor White
