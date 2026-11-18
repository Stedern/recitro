@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ensure-pixel8-ready.ps1"
exit /b %ERRORLEVEL%