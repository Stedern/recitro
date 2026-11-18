# Start Pixel 8 (API 37, Google Play) with settings that work on ~8 GB host RAM.
# Usage: .\scripts\start-pixel8-emulator.ps1 [-WipeData] [-Wait]
param(
  [switch]$WipeData,
  [switch]$Wait,
  [switch]$KeepIfReady,
  [string]$DeviceId = "emulator-5554"
)

$ErrorActionPreference = "Stop"
$sdk = if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "$env:LOCALAPPDATA\Android\sdk" }
$emulator = Join-Path $sdk "emulator\emulator.exe"
$adb = Join-Path $sdk "platform-tools\adb.exe"

if (-not (Test-Path $emulator)) {
  Write-Error "Android emulator not found at $emulator"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($KeepIfReady) {
  & $adb start-server 2>$null | Out-Null
  $state = (& $adb devices 2>$null) | Where-Object { $_ -match "^$DeviceId\s+device\s*$" }
  if ($state) {
    $waitScript = Join-Path $scriptDir "wait-android-boot.ps1"
    & $waitScript -DeviceId $DeviceId -TimeoutMinutes 2
    if ($LASTEXITCODE -eq 0) {
      if (-not $Wait) { return $DeviceId }
      return $DeviceId
    }
    Write-Host "Pixel 8 was not fully ready — cold restarting AVD..." -ForegroundColor Yellow
  }
}

& (Join-Path $scriptDir "stop-all-emulators.ps1")

$args = @(
  "-avd", "Pixel_8",
  "-no-snapshot-load",
  "-no-boot-anim",
  "-memory", "2048",
  "-cores", "2",
  "-gpu", "swiftshader_indirect"
)
if ($WipeData) { $args += "-wipe-data" }

Write-Host "Starting Pixel 8 (API 37, Google Play)..." -ForegroundColor Cyan
Start-Process -FilePath $emulator -ArgumentList $args -WindowStyle Normal | Out-Null
Start-Sleep -Seconds 8

if (-not $Wait) { return }

& (Join-Path $scriptDir "wait-android-boot.ps1") -DeviceId $DeviceId -TimeoutMinutes 8
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
return $DeviceId