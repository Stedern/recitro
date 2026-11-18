# Start Pixel 8 (API 37, Google Play) with settings that work on ~8 GB host RAM.
# Usage: .\scripts\start-pixel8-emulator.ps1 [-WipeData] [-Wait]
param(
  [switch]$WipeData,
  [switch]$Wait
)

$ErrorActionPreference = "Stop"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$emulator = Join-Path $sdk "emulator\emulator.exe"
$adb = Join-Path $sdk "platform-tools\adb.exe"

if (-not (Test-Path $emulator)) {
  Write-Error "Android emulator not found at $emulator"
}

# One emulator at a time avoids adb showing duplicate/offline devices.
Get-Process emulator, qemu-system-x86_64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
& $adb kill-server | Out-Null
& $adb start-server | Out-Null

$args = @(
  "-avd", "Pixel_8",
  "-no-snapshot-load",
  "-no-boot-anim",
  "-memory", "3072",
  "-cores", "2",
  "-gpu", "angle_indirect"
)
if ($WipeData) { $args += "-wipe-data" }

Write-Host "Starting Pixel 8 (API 37, Google Play)..." -ForegroundColor Cyan
Start-Process -FilePath $emulator -ArgumentList $args -WindowStyle Normal | Out-Null

if (-not $Wait) { return }

Write-Host "Waiting for boot (up to 6 minutes on first cold boot)..." -ForegroundColor Cyan
$deadline = (Get-Date).AddMinutes(6)
do {
  $lines = & $adb devices 2>&1
  foreach ($line in $lines) {
    if ($line -match "^emulator-\d+\s+device$") {
      $id = ($line -split "\s+")[0]
      $boot = & $adb -s $id shell getprop sys.boot_completed 2>$null
      if ($boot -eq "1") {
        $api = & $adb -s $id shell getprop ro.build.version.sdk
        Write-Host "Ready: $id (API $api)" -ForegroundColor Green
        return $id
      }
    }
  }
  Start-Sleep -Seconds 5
} while ((Get-Date) -lt $deadline)

Write-Host "Emulator did not reach 'device' state. Close other apps to free RAM, then retry with -WipeData." -ForegroundColor Red
exit 1