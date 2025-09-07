# Watch for new txAdmin deployment profiles and auto-fix SQL
Write-Host "👀 Watching for new txAdmin deployment profiles..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop watching" -ForegroundColor Cyan

# Get initial count of deployment profiles
$initialProfiles = (Get-ChildItem -Path "txData" -Directory).Count
Write-Host "Currently monitoring $initialProfiles deployment profiles" -ForegroundColor Cyan

while ($true) {
    Start-Sleep -Seconds 5
    
    # Check for new deployment profiles
    $currentProfiles = (Get-ChildItem -Path "txData" -Directory).Count
    
    if ($currentProfiles -gt $initialProfiles) {
        Write-Host "`n🆕 New deployment profile detected!" -ForegroundColor Green
        
        # Run the auto-fix script
        & ".\auto_fix_sql.ps1"
        
        # Update the count
        $initialProfiles = $currentProfiles
        
        Write-Host "`n👀 Resuming watch..." -ForegroundColor Yellow
    }
}
