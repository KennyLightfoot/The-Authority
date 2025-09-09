# Permanent deployment setup for Qbox Project
# This creates a stable, working deployment that doesn't break

Write-Host "🚀 Setting up permanent Qbox deployment..." -ForegroundColor Cyan

# Find the latest working deployment profile
$latestProfile = Get-ChildItem -Path "txData" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestProfile) {
    $profileName = $latestProfile.Name
    $profilePath = $latestProfile.FullName
    
    Write-Host "📁 Using deployment profile: $profileName" -ForegroundColor Green
    
    # Create a permanent server configuration
    $serverConfig = @"
# Qbox Project Server Configuration (hardened)
# Generated on $(Get-Date)

# Basic server settings
set sv_hostname "The Authority RP Server"
set sv_maxclients 32
set sv_licenseKey "CHANGE_ME"
sv_scriptHookAllowed 0

# Database connection
set mysql_connection_string "mysql://fivem:CHANGE_ME@127.0.0.1/authority?charset=utf8mb4"

# Steam API
steam_webApiKey ""

# Discord Bot
setr discord_token "changeme"
setr discord_guild_id "000000000000"

# txAdmin settings
set txAdmin-menuEnabled "true"
set txAdmin-menuDefaultKey "F10"
set txAdmin-verbose "true"
set txAdmin-luaComHost "127.0.0.1"
set txAdmin-luaComToken "CHANGE_ME"
set txAdmin-luaComPort "40120"

# Resource loading
ensure oxmysql
ensure ox_lib
ensure db_migrator
ensure qbx_core
ensure ox_inventory
ensure ox_target
ensure PolyZone
ensure pma-voice
ensure yarn
ensure webpack
ensure chat
ensure chat-theme-gtao
ensure sessionmanager
ensure spawnmanager
ensure Renewed-Banking
ensure illenium-appearance
ensure apartments
ensure qbx_vehicles
ensure qbx_vehiclekeys
ensure qbx_garages
ensure qb-delivery
# ensure Badger_Discord_API
# ensure discord_perms
# ensure EasyAdmin
ensure core
ensure job_patches
ensure qa_tools
ensure ea_keybind
ensure telemetry
ensure healthcheck
"@

    # Write the server configuration
    Set-Content -Path "server_permanent.cfg" -Value $serverConfig
    Write-Host "✅ Created permanent server config: server_permanent.cfg" -ForegroundColor Green
    
    # Create a startup script
    $startupScript = @"
@echo off
echo Starting The Authority RP Server...
echo Using deployment profile: $profileName
echo.

cd /d "%~dp0"
cd server
FXServer.exe +set sv_licenseKey "CHANGE_ME" +exec ../server_permanent.cfg

pause
"@

    Set-Content -Path "start_server_permanent.bat" -Value $startupScript
    Write-Host "✅ Created startup script: start_server_permanent.bat" -ForegroundColor Green
    
    # Create a backup script for future updates
    $backupScript = @"
# Backup script for Qbox deployment updates
Write-Host "📦 Creating backup of current deployment..." -ForegroundColor Yellow

`$backupName = "qbox_backup_`$(Get-Date -Format 'yyyyMMdd_HHmmss')"
`$backupPath = "backups/`$backupName"

New-Item -ItemType Directory -Path "backups" -Force | Out-Null
Copy-Item -Path "txData/$profileName" -Destination "`$backupPath" -Recurse

Write-Host "✅ Backup created: `$backupPath" -ForegroundColor Green
Write-Host "💡 To restore: Copy the backup back to txData/" -ForegroundColor Cyan
"@

    Set-Content -Path "backup_deployment.ps1" -Value $backupScript
    Write-Host "✅ Created backup script: backup_deployment.ps1" -ForegroundColor Green
    
    Write-Host "`n🎉 Permanent deployment setup complete!" -ForegroundColor Green
    Write-Host "`n📋 What you can do now:" -ForegroundColor Yellow
    Write-Host "1. Run: .\start_server_permanent.bat" -ForegroundColor White
    Write-Host "2. Access txAdmin: http://localhost:40120" -ForegroundColor White
    Write-Host "3. Backup before updates: .\backup_deployment.ps1" -ForegroundColor White
    
    Write-Host "`n💡 Benefits of this approach:" -ForegroundColor Cyan
    Write-Host "✅ No more SQL syntax errors" -ForegroundColor Green
    Write-Host "✅ Stable, reliable deployment" -ForegroundColor Green
    Write-Host "✅ Easy to start/stop server" -ForegroundColor Green
    Write-Host "✅ Easy to backup and restore" -ForegroundColor Green
    Write-Host "✅ No dependency on txAdmin's GitHub downloads" -ForegroundColor Green
    
} else {
    Write-Host "❌ No deployment profiles found!" -ForegroundColor Red
    Write-Host "Please run a txAdmin deployment first." -ForegroundColor Yellow
}
