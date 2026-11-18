# Run this in Android Studio Terminal immediately before the green Run button.
# Flutter installs before Package Manager is up → "device is still booting".
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $here "ensure-pixel8-ready.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "You can Run / Debug in Android Studio now." -ForegroundColor Green
Write-Host "Blank screen after Run? Studio uses --start-paused: press Resume (F9) in the debugger toolbar." -ForegroundColor Yellow