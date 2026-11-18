# One Pixel 8 emulator only — stop extras, start if needed, wait for Package Manager.
param(
  [string]$DeviceId = "emulator-5554",
  [int]$TimeoutMinutes = 8
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$adb = Join-Path $sdk "platform-tools\adb.exe"
$env:ADB_INSTALL_TIMEOUT = "300"

& $adb start-server 2>$null | Out-Null

$ready = @((& $adb devices 2>$null) | Where-Object { $_ -match "^\S+\s+device\s*$" })
$emulators = @($ready | Where-Object { $_ -match "^emulator-" })

if ($emulators.Count -gt 1) {
  Write-Host "Detected $($emulators.Count) emulators (causes install failure). Stopping all..." -ForegroundColor Yellow
  $emulators | ForEach-Object { Write-Host "  $_" }
  & (Join-Path $here "stop-all-emulators.ps1")
  $ready = @()
}

if ($ready.Count -eq 0) {
  Write-Host "Starting Pixel 8 only (do not open Medium_Phone from Device Manager)." -ForegroundColor Cyan
  & (Join-Path $here "start-pixel8-emulator.ps1") -Wait
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  $DeviceId = "emulator-5554"
} elseif ($emulators.Count -eq 1) {
  if ($emulators[0] -match "^(\S+)") { $DeviceId = $Matches[1] }
}

& (Join-Path $here "wait-android-boot.ps1") -DeviceId $DeviceId -TimeoutMinutes $TimeoutMinutes
exit $LASTEXITCODE