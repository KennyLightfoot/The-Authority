@echo off
echo ========================================
echo The Authority - Database Setup
echo ========================================
echo.
echo This script will set up your MySQL database for The Authority server.
echo.
echo IMPORTANT: Make sure MySQL is installed and running!
echo.
echo Default MySQL root login will be used.
echo You'll be prompted for your MySQL root password.
echo.
pause
echo.
echo Running database setup...
mysql -u root -p < setup_database.sql
echo.
if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo SUCCESS: Database setup completed!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Update server.cfg with your MySQL credentials
    echo 2. Configure Discord bot settings
    echo 3. Add your FiveM license key
    echo 4. Start your server!
    echo.
) else (
    echo ========================================
    echo ERROR: Database setup failed!
    echo ========================================
    echo.
    echo Please check:
    echo 1. MySQL is installed and running
    echo 2. You entered the correct root password
    echo 3. You have sufficient privileges
    echo.
)
pause



