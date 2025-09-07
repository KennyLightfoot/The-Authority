# 🚀 The Authority RP Server - Startup Guide

## Quick Start (After PC Restart)

### 1. **Start MySQL Database**
```powershell
# Check if MySQL is running
Get-Service -Name "MySQL80"

# If not running, start it
Start-Service -Name "MySQL80"
```

### 2. **Start the Server**
```bash
# Double-click this file or run in PowerShell:
.\start_server_permanent.bat
```

### 3. **Access txAdmin**
- Open browser: `http://localhost:40120`
- Login with your txAdmin credentials

---

## Detailed Steps

### Step 1: Verify MySQL is Running
```powershell
# Check MySQL service status
Get-Service -Name "MySQL80"

# If status is "Stopped", start it:
Start-Service -Name "MySQL80"

# Verify it's running:
Get-Service -Name "MySQL80"
```

### Step 2: Start the Server
**Option A: Double-click**
- Double-click `start_server_permanent.bat`

**Option B: PowerShell**
```powershell
.\start_server_permanent.bat
```

**Option C: Manual (if needed)**
```powershell
cd server
.\FXServer.exe +set sv_licenseKey "cfxk_1MYEfKBZUmFiat4mhBwMn_4Y3kaA" +exec ../server_permanent.cfg
```

### Step 3: Verify Everything is Working
1. **Check server console** - Should show "Server started successfully"
2. **Open txAdmin** - Go to `http://localhost:40120`
3. **Test database connection** - Should show "Connected to database"

---

## Troubleshooting

### If MySQL Won't Start
```powershell
# Check what's using port 3306
netstat -ano | findstr :3306

# If something else is using it, stop it:
# (Look for the PID in the netstat output)
taskkill /PID [PID_NUMBER] /F
```

### If Server Won't Start
1. **Check if port 30120 is free:**
   ```powershell
   netstat -ano | findstr :30120
   ```

2. **Check server logs:**
   - Look in the console output for error messages
   - Common issues: License key, database connection, port conflicts

### If txAdmin Won't Load
1. **Check if server is running** (should see "txAdmin" in console)
2. **Try different browser** or clear cache
3. **Check firewall** - Make sure port 40120 is allowed

---

## Daily Operations

### Starting the Server
1. Start MySQL (if not running)
2. Run `.\start_server_permanent.bat`
3. Access txAdmin at `http://localhost:40120`

### Stopping the Server
- Press `Ctrl+C` in the server console
- Or close the command window

### Restarting the Server
1. Stop the server (Ctrl+C)
2. Wait 5 seconds
3. Start again with `.\start_server_permanent.bat`

---

## Backup & Updates

### Before Making Changes
```powershell
# Always backup first
.\backup_deployment.ps1
```

### After PC Restart
1. Start MySQL
2. Start server with `.\start_server_permanent.bat`
3. Access txAdmin

---

## File Locations

- **Server files:** `txData/Qbox_BD27E6.base/`
- **Config:** `server_permanent.cfg`
- **Startup script:** `start_server_permanent.bat`
- **Backup script:** `backup_deployment.ps1`
- **Database:** MySQL on localhost:3306

---

## Quick Reference Commands

```powershell
# Start MySQL
Start-Service -Name "MySQL80"

# Check MySQL status
Get-Service -Name "MySQL80"

# Start server
.\start_server_permanent.bat

# Backup deployment
.\backup_deployment.ps1

# Check what's using port 3306
netstat -ano | findstr :3306

# Check what's using port 30120
netstat -ano | findstr :30120
```

---

## Need Help?

If you run into issues:
1. Check this guide first
2. Look at the server console for error messages
3. Verify MySQL is running
4. Check if ports are free
5. Try restarting both MySQL and the server
