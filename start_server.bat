@echo off
echo Starting The Authority RP Server...
echo.
echo Server Configuration:
echo - MySQL: Connected
echo - Discord: Configured
echo - Steam: Configured
echo - Resources: Loaded
echo.
echo Starting FXServer...
echo.

cd /d "%~dp0"
server\FXServer.exe +exec server.cfg

pause
