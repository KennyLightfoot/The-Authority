# PowerShell script to automatically fix SQL syntax errors in txAdmin deployment profiles
# Run this script whenever you get the SQL error during deployment

Write-Host "🔧 Fixing SQL syntax errors in txAdmin deployment profiles..." -ForegroundColor Yellow

# Find all qbx_core.sql files in txData that have the problematic syntax
$sqlFiles = Get-ChildItem -Path "txData" -Name "qbx_core.sql" -Recurse | ForEach-Object { "txData\$_" }

foreach ($file in $sqlFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Check if the file contains the problematic syntax
        if ($content -match "ADD COLUMN IF NOT EXISTS.*AFTER") {
            Write-Host "Fixing: $file" -ForegroundColor Green
            
            # Fix the first problematic line
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,", "ADD COLUMN ``last_logged_out`` timestamp NULL DEFAULT NULL AFTER ``last_updated``,"
            
            # Fix the second problematic line
            $content = $content -replace "ADD COLUMN IF NOT EXISTS ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;", "ADD COLUMN ``userId`` INT UNSIGNED DEFAULT NULL AFTER ``id``;"
            
            # Write the fixed content back
            Set-Content -Path $file -Value $content -NoNewline
            
            Write-Host "✅ Fixed: $file" -ForegroundColor Green
        } else {
            Write-Host "✅ Already fixed: $file" -ForegroundColor Cyan
        }
    }
}

Write-Host "🎉 SQL fix complete! You can now retry your deployment." -ForegroundColor Green
Write-Host "💡 Tip: Run this script whenever you get the SQL error during deployment." -ForegroundColor Yellow
