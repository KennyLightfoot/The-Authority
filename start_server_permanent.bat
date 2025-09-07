@echo off
echo Starting The Authority RP Server...
echo Using deployment profile: Qbox_BD27E6.base
echo.

cd /d "%~dp0"
cd server
FXServer.exe +set sv_licenseKey "cfxk_1MYEfKBZUmFiat4mhBwMn_4Y3kaA" +exec ../server_permanent.cfg

pause
