@echo off
echo ====================================================
echo   Resetting MySQL Root & Creating jwt_user Account
echo ====================================================
echo.

echo 1. Stopping MySQL service...
net stop MySQL80

echo 2. Executing password reset and user creation script...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --defaults-file="C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" --init-file="c:\Users\mahal\OneDrive\Dokumente\Projects\E-Commerce\reset.sql" --console

echo 3. Restarting MySQL service...
net start MySQL80

echo.
echo ====================================================
echo SUCCESS! MySQL root and jwt_user passwords reset to: Maha@123
echo ====================================================
pause
