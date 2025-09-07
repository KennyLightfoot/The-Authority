# Start The Authority RP Server using original repository structure
Write-Host "Starting The Authority RP Server..." -ForegroundColor Cyan
Write-Host "Using original repository structure" -ForegroundColor Yellow
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
            Write-Host "Please check MySQL installation and try again." -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host "MySQL service not found!" -ForegroundColor Red
    Write-Host "Please install MySQL first." -ForegroundColor Yellow
    exit 1
}

# Stop any running server (non-interactive)
Write-Host "`nEnsuring no existing FXServer is running..." -ForegroundColor Yellow
Stop-Process -Name "FXServer" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "Previous FXServer processes stopped (if any)" -ForegroundColor Green

# Start the server (bootstrap txAdmin if needed)
Write-Host "`nStarting the server..." -ForegroundColor Yellow

if (Test-Path "server\FXServer.exe") {
    $txDataPath = Join-Path "server" "txData"
    if (-not (Test-Path $txDataPath)) {
        Write-Host "txAdmin not initialized yet. Launching FXServer to bootstrap txAdmin (no +exec)..." -ForegroundColor Yellow
        Start-Process -FilePath "server\FXServer.exe" -WindowStyle Normal
        Write-Host "txAdmin should now be available at http://localhost:40120 for onboarding." -ForegroundColor Green
        Write-Host "After completing onboarding, set the server.cfg path to: $(Get-Location)\server.cfg" -ForegroundColor Yellow
        exit 0
    }
    Write-Host "Launching server with server.cfg..." -ForegroundColor Green
    # License key should be set in config/secrets.cfg; do not hardcode in this script
    Start-Process -FilePath "server\FXServer.exe" -ArgumentList "+exec server.cfg" -WindowStyle Normal
    Write-Host "Server startup initiated" -ForegroundColor Green
} else {
    Write-Host "FXServer.exe not found in server directory!" -ForegroundColor Red
    Write-Host "Please ensure FiveM server is properly installed." -ForegroundColor Yellow
    exit 1
}

# Wait and provide instructions
Write-Host "`nServer startup complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 30-60 seconds for server to fully start" -ForegroundColor White
Write-Host "2. Open browser: http://localhost:40120" -ForegroundColor White
Write-Host "3. Login to txAdmin" -ForegroundColor White
Write-Host "4. Check server console for any errors" -ForegroundColor White

Write-Host "`nTips:" -ForegroundColor Cyan
Write-Host "- Server console will show startup progress" -ForegroundColor White
Write-Host "- Look for txAdmin in the console output" -ForegroundColor White
Write-Host "- Resources should load from the original repository structure" -ForegroundColor White

Write-Host "`nServer startup process complete!" -ForegroundColor Green
