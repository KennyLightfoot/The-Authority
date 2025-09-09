# Test The Authority RP Server without Discord integration
Write-Host "Testing server without Discord integration..." -ForegroundColor Cyan
Write-Host "This will help isolate the 'awaiting scripts' issue" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

# Check if MySQL is running
Write-Host "`nChecking MySQL database..." -ForegroundColor Yellow
$mysqlService = Get-Service -Name "MySQL80" -ErrorAction SilentlyContinue

if ($mysqlService) {
    if ($mysqlService.Status -eq "Running") {
        Write-Host "MySQL is running" -ForegroundColor Green
    } else {
        Write-Host "Starting MySQL..." -ForegroundColor Yellow
        Start-Service -Name "MySQL80"
        Start-Sleep -Seconds 3
        
        if ((Get-Service -Name "MySQL80").Status -eq "Running") {
            Write-Host "MySQL started successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to start MySQL!" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "MySQL service not found!" -ForegroundColor Red
    exit 1
}

# Stop any running server
Write-Host "`nStopping any existing FXServer processes..." -ForegroundColor Yellow
Stop-Process -Name "FXServer" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start the server with test config
Write-Host "`nStarting server with test configuration (no Discord)..." -ForegroundColor Yellow

if (Test-Path "server\FXServer.exe") {
    Write-Host "Launching server with server_test.cfg..." -ForegroundColor Green
    Start-Process -FilePath "server\FXServer.exe" -ArgumentList "+exec server_test.cfg" -WindowStyle Normal
    Write-Host "Server startup initiated" -ForegroundColor Green
} else {
    Write-Host "FXServer.exe not found in server directory!" -ForegroundColor Red
    exit 1
}

Write-Host "`nTest server started!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 30-60 seconds for server to fully start" -ForegroundColor White
Write-Host "2. Connect to the server in FiveM" -ForegroundColor White
Write-Host "3. Check if 'awaiting scripts' issue is resolved" -ForegroundColor White
Write-Host "4. If resolved, the issue was Discord-related" -ForegroundColor White
Write-Host "5. If not resolved, the issue is elsewhere" -ForegroundColor White

