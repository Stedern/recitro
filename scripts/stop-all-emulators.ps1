# Stop every Android emulator + qemu (fixes duplicate AVD / adb install failures).
$ErrorActionPreference = "SilentlyContinue"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$adb = Join-Path $sdk "platform-tools\adb.exe"

Get-Process emulator, qemu-system-x86_64, qemu-system-aarch64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
& $adb kill-server 2>$null | Out-Null
Start-Sleep -Seconds 1
& $adb start-server 2>$null | Out-Null

$left = @((& $adb devices 2>$null) | Where-Object { $_ -match "emulator" })
if ($left.Count -gt 0) {
  Write-Host "Waiting for ADB to release emulators..." -ForegroundColor DarkGray
  Start-Sleep -Seconds 3
}
Write-Host "All emulators stopped." -ForegroundColor Green