# Same target as Android Studio: Pixel 8 (emulator-5554), Android only.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Set-Location $root
$env:ADB_INSTALL_TIMEOUT = "300"

& (Join-Path $root "scripts\ensure-pixel8-ready.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Starting Flutter on emulator-5554..." -ForegroundColor Cyan
& "C:\Users\Jay\develop\flutter\bin\flutter.bat" run -d emulator-5554 @args