# Blocks until sysfs boot is done AND Package Manager answers (fixes "device is still booting").
param(
  [string]$DeviceId = "emulator-5554",
  [int]$TimeoutMinutes = 8
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$adb = Join-Path $sdk "platform-tools\adb.exe"
$env:ADB_INSTALL_TIMEOUT = "300"

function Test-PackageService {
  param([string]$Id)
  $text = (cmd /c "`"$adb`" -s $Id shell pm path android 2>nul") -join "`n"
  $text = $text.Trim()
  if ($text -match "package:") { return $true }
  return $false
}

Write-Host "Waiting for Pixel 8 ($DeviceId) — home screen + package service (up to ${TimeoutMinutes}m)..." -ForegroundColor Cyan

$ErrorActionPreference = "SilentlyContinue"
& $adb start-server | Out-Null
Start-Sleep -Seconds 2

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$lastPing = ""
while ((Get-Date) -lt $deadline) {
  $devices = (cmd /c "`"$adb`" devices 2>nul") | Out-String
  if ($devices -notmatch "(?m)^$([regex]::Escape($DeviceId))\s+device\s*$") {
    if ($lastPing -ne "nodevice") {
      Write-Host "  ADB: $DeviceId not in 'device' state yet (rebooting?)..." -ForegroundColor DarkGray
      $lastPing = "nodevice"
    }
    Start-Sleep -Seconds 4
    continue
  }

  $boot = (cmd /c "`"$adb`" -s $DeviceId shell getprop sys.boot_completed 2>nul") -join "`n"
  $boot = $boot.Trim()
  if ($boot -ne "1") {
    if ($lastPing -ne "boot") {
      Write-Host "  Booting (sys.boot_completed=$boot)..." -ForegroundColor DarkGray
      $lastPing = "boot"
    }
    Start-Sleep -Seconds 4
    continue
  }

  if (Test-PackageService -Id $DeviceId) {
    $api = (cmd /c "`"$adb`" -s $DeviceId shell getprop ro.build.version.sdk 2>nul") -join "`n"
    $api = $api.Trim()
    Write-Host "Ready: $DeviceId (API $api)" -ForegroundColor Green
    exit 0
  }

  if ($lastPing -ne "pm") {
    Write-Host "  sysfs boot done; waiting for Package Manager..." -ForegroundColor DarkGray
    $lastPing = "pm"
  }
  Start-Sleep -Seconds 4
}

Write-Host "Timed out. Cold start: .\scripts\start-pixel8-emulator.ps1 -Wait" -ForegroundColor Red
Write-Host "If it keeps failing: .\scripts\start-pixel8-emulator.ps1 -WipeData -Wait" -ForegroundColor Red
exit 1