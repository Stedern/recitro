# Run before Android Studio Flutter Run if install keeps failing (same adb session as Studio).
param([string]$DeviceId = "emulator-5554")

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$apk = Join-Path $root "build\app\outputs\flutter-apk\app-debug.apk"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$adb = Join-Path $sdk "platform-tools\adb.exe"

if (-not (Test-Path $apk)) {
  Write-Host "Build APK first (Run once or: flutter build apk --debug)." -ForegroundColor Yellow
  exit 0
}

& (Join-Path $root "scripts\reset-android-app.ps1") -DeviceId $DeviceId

Write-Host "Installing APK (may take 1-3 min on Pixel 8)..." -ForegroundColor Cyan
$result = & $adb -s $DeviceId install -r -t $apk 2>&1
Write-Host $result
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Install OK. You can Run/Debug in Studio (attach / hot reload)." -ForegroundColor Green