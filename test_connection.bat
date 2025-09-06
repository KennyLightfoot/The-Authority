@echo off
echo ========================================
echo The Authority RP - Connection Test
echo ========================================
echo.

echo Testing server connectivity...
echo.

echo 1. Testing if server is listening on port 30120...
netstat -an | findstr ":30120"
echo.

echo 2. Testing local connection...
telnet 127.0.0.1 30120
echo.

echo 3. Your IP addresses:
ipconfig | findstr "IPv4"
echo.

echo 4. Firewall status:
netsh advfirewall show currentprofile
echo.

echo ========================================
echo Connection Test Complete
echo ========================================
echo.
echo To connect to your server:
echo 1. Open FiveM
echo 2. Press F8 to open console
echo 3. Type: connect 127.0.0.1:30120
echo 4. Or use your local IP address shown above
echo.
pause

