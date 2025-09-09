@echo off
REM Start server with watchdog
set HEALTH_URL=http://127.0.0.1:30121/health
set FX_DIR=%~dp0server

:loop
cd /d "%FX_DIR%"
start "FXServer" /b FXServer.exe +exec ../server_permanent.cfg

REM Wait for server to initialize
powershell -NoProfile -Command "Start-Sleep -Seconds 10"

:probe
for /l %%i in (1,1,3600) do (
  powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing %HEALTH_URL% -TimeoutSec 3; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
  if %ERRORLEVEL% NEQ 0 (
    echo [watchdog] health probe failed, attempting 2 more times
    powershell -NoProfile -Command "Start-Sleep -Seconds 5"
    powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing %HEALTH_URL% -TimeoutSec 3; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
    if %ERRORLEVEL% NEQ 0 (
      powershell -NoProfile -Command "Start-Sleep -Seconds 5"
      powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing %HEALTH_URL% -TimeoutSec 3; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"
      if %ERRORLEVEL% NEQ 0 (
        echo [watchdog] unhealthy - stopping server to trigger restart
        taskkill /fi "WINDOWTITLE eq FXServer" /f
        powershell -NoProfile -Command "Start-Sleep -Seconds 5"
        goto loop
      )
    )
  )
  powershell -NoProfile -Command "Start-Sleep -Seconds 5"
)

goto loop
