# Auto-fix SQL syntax issues in txAdmin deployment profiles
# This script monitors and fixes SQL files as they're created

Write-Host "🔧 Auto-fixing SQL syntax in txAdmin deployment profiles..." -ForegroundColor Yellow

# Function to fix a single SQL file
function Fix-SQLFile {
    param($filePath)
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Check if the file contains the problematic syntax
        if ($content -match "ADD COLUMN IF NOT EXISTS.*AFTER") {
            Write-Host "Fixing: $filePath" -ForegroundColor Green
            
            # Fix the problematic syntax for MySQL 8.0
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,", "ADD COLUMN ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,"
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;", "ADD COLUMN ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;"
            
            # Write the fixed content back
            Set-Content -Path $filePath -Value $content -NoNewline
            
            Write-Host "✅ Fixed: $filePath" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✅ Already fixed: $filePath" -ForegroundColor Cyan
            return $false
        }
    }
    return $false
}

# Find all qbx_core.sql files in txData
$sqlFiles = Get-ChildItem -Path "txData" -Name "qbx_core.sql" -Recurse | ForEach-Object { "txData\$_" }

$fixedCount = 0
$totalCount = $sqlFiles.Count

Write-Host "Found $totalCount SQL files to check..." -ForegroundColor Cyan

foreach ($file in $sqlFiles) {
    if (Fix-SQLFile $file) {
        $fixedCount++
    }
}

Write-Host "`n🎉 Auto-fix complete!" -ForegroundColor Green
Write-Host "Fixed $fixedCount out of $totalCount files" -ForegroundColor Cyan

if ($fixedCount -gt 0) {
    Write-Host "🚀 You can now retry your txAdmin deployment!" -ForegroundColor Yellow
} else {
    Write-Host "✅ All files are already fixed!" -ForegroundColor Green
}

Write-Host "`n💡 Run this script whenever you get the SQL error during deployment." -ForegroundColor Cyan
