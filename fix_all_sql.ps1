# Comprehensive SQL fix for all txAdmin deployment profiles
Write-Host "🔧 Fixing SQL syntax in ALL txAdmin deployment profiles..." -ForegroundColor Yellow

# Find all qbx_core.sql files in txData
$sqlFiles = Get-ChildItem -Path "txData" -Name "qbx_core.sql" -Recurse | ForEach-Object { "txData\$_" }

$fixedCount = 0
$totalCount = $sqlFiles.Count

Write-Host "Found $totalCount SQL files to check..." -ForegroundColor Cyan

foreach ($file in $sqlFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Check if the file contains the problematic syntax
        if ($content -match "ADD COLUMN IF NOT EXISTS.*AFTER") {
            Write-Host "Fixing: $file" -ForegroundColor Green
            
            # Fix the problematic syntax for MySQL 8.0
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,", "ADD COLUMN ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,"
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;", "ADD COLUMN ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;"
            
            # Write the fixed content back
            Set-Content -Path $file -Value $content -NoNewline
            
            Write-Host "✅ Fixed: $file" -ForegroundColor Green
            $fixedCount++
        } else {
            Write-Host "✅ Already fixed: $file" -ForegroundColor Cyan
        }
    }
}

Write-Host "`n🎉 SQL fix complete!" -ForegroundColor Green
Write-Host "Fixed $fixedCount out of $totalCount files" -ForegroundColor Cyan
Write-Host "🚀 You can now retry your txAdmin deployment!" -ForegroundColor Yellow
