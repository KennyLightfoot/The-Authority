@echo off
echo Starting The Authority RP Server...
echo Using original repository structure
echo.

cd /d "%~dp0"
server\FXServer.exe +set sv_licenseKey "cfxk_1MYEfKBZUmFiat4mhBwMn_4Y3kaA" +exec server.cfg

pause
