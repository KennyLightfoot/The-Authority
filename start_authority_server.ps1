# Start The Authority RP Server using original repository structure
Write-Host "🚀 Starting The Authority RP Server..." -ForegroundColor Cyan
Write-Host "Using original repository structure" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

# Check if MySQL is running
Write-Host "`n1️⃣ Checking MySQL database..." -ForegroundColor Yellow
$mysqlService = Get-Service -Name "MySQL80" -ErrorAction SilentlyContinue

if ($mysqlService) {
    if ($mysqlService.Status -eq "Running") {
        Write-Host "✅ MySQL is running" -ForegroundColor Green
    } else {
        Write-Host "🔄 Starting MySQL..." -ForegroundColor Yellow
        Start-Service -Name "MySQL80"
        Start-Sleep -Seconds 3
        
        if ((Get-Service -Name "MySQL80").Status -eq "Running") {
            Write-Host "✅ MySQL started successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to start MySQL!" -ForegroundColor Red
            Write-Host "Please check MySQL installation and try again." -ForegroundColor Yellow
            exit 1
        }
    }
} else {
    Write-Host "❌ MySQL service not found!" -ForegroundColor Red
    Write-Host "Please install MySQL first." -ForegroundColor Yellow
    exit 1
}

# Check if server is already running
Write-Host "`n2️⃣ Checking if server is already running..." -ForegroundColor Yellow
$serverProcess = Get-Process -Name "FXServer" -ErrorAction SilentlyContinue

if ($serverProcess) {
    Write-Host "⚠️  Server is already running (PID: $($serverProcess.Id))" -ForegroundColor Yellow
    Write-Host "Do you want to stop it and restart? (y/n)" -ForegroundColor Cyan
    $response = Read-Host
    
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "🔄 Stopping existing server..." -ForegroundColor Yellow
        Stop-Process -Name "FXServer" -Force
        Start-Sleep -Seconds 2
        Write-Host "✅ Server stopped" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Keeping existing server running" -ForegroundColor Cyan
        Write-Host "Access txAdmin at: http://localhost:40120" -ForegroundColor Green
        exit 0
    }
}

# Start the server
Write-Host "`n3️⃣ Starting the server..." -ForegroundColor Yellow

if (Test-Path "server\FXServer.exe") {
    Write-Host "🚀 Launching server..." -ForegroundColor Green
    Start-Process -FilePath "server\FXServer.exe" -ArgumentList "+set sv_licenseKey `"cfxk_1MYEfKBZUmFiat4mhBwMn_4Y3kaA`" +exec server.cfg" -WindowStyle Normal
    Write-Host "✅ Server startup initiated" -ForegroundColor Green
} else {
    Write-Host "❌ FXServer.exe not found in server directory!" -ForegroundColor Red
    Write-Host "Please ensure FiveM server is properly installed." -ForegroundColor Yellow
    exit 1
}

# Wait and provide instructions
Write-Host "`n4️⃣ Server startup complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 30-60 seconds for server to fully start" -ForegroundColor White
Write-Host "2. Open browser: http://localhost:40120" -ForegroundColor White
Write-Host "3. Login to txAdmin" -ForegroundColor White
Write-Host "4. Check server console for any errors" -ForegroundColor White

Write-Host "`n💡 Tips:" -ForegroundColor Cyan
Write-Host "• Server console will show startup progress" -ForegroundColor White
Write-Host "• Look for 'txAdmin' in the console output" -ForegroundColor White
Write-Host "• Resources should load from the original repository structure" -ForegroundColor White

Write-Host "`n🎉 Server startup process complete!" -ForegroundColor Green
