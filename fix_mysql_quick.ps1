# Quick fix for MySQL 8.0 syntax issues
Write-Host "🔧 Fixing MySQL 8.0 syntax issues..." -ForegroundColor Yellow

# Find all qbx_core.sql files in txData
$sqlFiles = Get-ChildItem -Path "txData" -Name "qbx_core.sql" -Recurse | ForEach-Object { "txData\$_" }

foreach ($file in $sqlFiles) {
    if (Test-Path $file) {
        Write-Host "Fixing: $file" -ForegroundColor Green
        
        $content = Get-Content $file -Raw
        
        # Fix the problematic syntax for MySQL 8.0
        $content = $content -replace "ADD COLUMN IF NOT EXISTS ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,", "ADD COLUMN ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,"
        $content = $content -replace "ADD COLUMN IF NOT EXISTS ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;", "ADD COLUMN ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;"
        
        # Write the fixed content back
        Set-Content -Path $file -Value $content -NoNewline
        
        Write-Host "✅ Fixed: $file" -ForegroundColor Green
    }
}

Write-Host "`n🎉 All SQL files fixed for MySQL 8.0!" -ForegroundColor Green
Write-Host "🚀 You can now retry your txAdmin deployment." -ForegroundColor Cyan
