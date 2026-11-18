@echo off
setlocal
cd /d "%~dp0.."
set ADB_INSTALL_TIMEOUT=300
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ensure-pixel8-ready.ps1"
if errorlevel 1 exit /b 1
"C:\Users\Jay\develop\flutter\bin\flutter.bat" %*
exit /b %ERRORLEVEL%