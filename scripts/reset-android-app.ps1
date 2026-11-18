# Fix "adb failed to install" / App failed to start — one target device, clean uninstall.
param(
  [string]$DeviceId = ""
)

$ErrorActionPreference = "Stop"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$adb = Join-Path $sdk "platform-tools\adb.exe"
$package = "com.recitro.recitro"

$devices = @((& $adb devices 2>$null) | Where-Object { $_ -match "^\S+\s+device\s*$" })
if ($devices.Count -eq 0) {
  & $adb kill-server 2>$null | Out-Null
  Start-Sleep 1
  & $adb start-server 2>$null | Out-Null
  $devices = @((& $adb devices 2>$null) | Where-Object { $_ -match "^\S+\s+device\s*$" })
}
if ($devices.Count -gt 1 -and -not $DeviceId) {
  Write-Host "Multiple Android devices — use only one emulator:" -ForegroundColor Yellow
  $devices | ForEach-Object { Write-Host "  $_" }
  Write-Host "Stop extras in Device Manager, or pass -DeviceId emulator-5554" -ForegroundColor Yellow
}

if (-not $DeviceId) {
  $line = ($devices | Select-Object -First 1)
  if ($line -match "^(\S+)") { $DeviceId = $Matches[1] }
}

if (-not $DeviceId) {
  Write-Error "No Android device in 'device' state. Start Pixel 8: .\scripts\start-pixel8-emulator.ps1 -Wait"
}

Write-Host "Target: $DeviceId" -ForegroundColor Cyan
$boot = & $adb -s $DeviceId shell getprop sys.boot_completed 2>$null
if ($boot -notmatch "1") {
  Write-Error "Android not finished booting (boot_completed=$boot). Wait for the home screen, then retry."
}
$p = Start-Process -FilePath $adb -ArgumentList @("-s", $DeviceId, "shell", "am", "force-stop", $package) `
  -NoNewWindow -PassThru
if (-not $p.WaitForExit(15000)) {
  try { $p.Kill() } catch { }
  Write-Host "force-stop timed out (emulator slow) — continuing with uninstall." -ForegroundColor Yellow
}
& $adb -s $DeviceId uninstall $package 2>$null
Write-Host "Uninstalled $package (if it was present). Run again: flutter run -d $DeviceId"