# Complete server startup script
# This handles everything needed to start the server

Write-Host "🚀 Starting The Authority RP Server..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Step 1: Check and start MySQL
Write-Host "`n1️⃣ Checking MySQL database..." -ForegroundColor Yellow
$mysqlService = Get-Service -Name "MySQL80" -ErrorAction SilentlyContinue

if ($mysqlService) {
    if ($mysqlService.Status -eq "Running") {
        Write-Host "✅ MySQL is already running" -ForegroundColor Green
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

# Step 2: Check if server is already running
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

# Step 3: Check ports
Write-Host "`n3️⃣ Checking server ports..." -ForegroundColor Yellow
$port30120 = netstat -ano | findstr :30120
$port40120 = netstat -ano | findstr :40120

if ($port30120) {
    Write-Host "⚠️  Port 30120 is in use. This might cause issues." -ForegroundColor Yellow
}

if ($port40120) {
    Write-Host "⚠️  Port 40120 is in use. txAdmin might not work properly." -ForegroundColor Yellow
}

# Step 4: Start the server
Write-Host "`n4️⃣ Starting the server..." -ForegroundColor Yellow

if (Test-Path "start_server_permanent.bat") {
    Write-Host "🚀 Launching server..." -ForegroundColor Green
    Start-Process -FilePath "start_server_permanent.bat" -WindowStyle Normal
    Write-Host "✅ Server startup initiated" -ForegroundColor Green
} else {
    Write-Host "❌ start_server_permanent.bat not found!" -ForegroundColor Red
    Write-Host "Please run setup_permanent_deployment.ps1 first." -ForegroundColor Yellow
    exit 1
}

# Step 5: Wait and provide instructions
Write-Host "`n5️⃣ Server startup complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 30-60 seconds for server to fully start" -ForegroundColor White
Write-Host "2. Open browser: http://localhost:40120" -ForegroundColor White
Write-Host "3. Login to txAdmin" -ForegroundColor White
Write-Host "4. Check server console for any errors" -ForegroundColor White

Write-Host "`n💡 Tips:" -ForegroundColor Cyan
Write-Host "• Server console will show startup progress" -ForegroundColor White
Write-Host "• Look for 'txAdmin' in the console output" -ForegroundColor White
Write-Host "• If issues occur, check the troubleshooting guide" -ForegroundColor White

Write-Host "`n🎉 Server startup process complete!" -ForegroundColor Green
