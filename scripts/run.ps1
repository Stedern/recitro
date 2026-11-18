# Run Recitro on Android only (emulator or USB phone).
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$flutterBin = "C:\Users\Jay\develop\flutter\bin"
$sdk = "C:\Users\Jay\AppData\Local\Android\sdk"
$env:Path = "$flutterBin;$sdk\platform-tools;$sdk\emulator;" + $env:Path
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk

function Get-AndroidDevices {
  $json = flutter devices --machine 2>$null | ConvertFrom-Json
  if (-not $json) { return @() }
  return @($json | Where-Object {
      $_.targetPlatform -match '^android' -or $_.id -match '^emulator-' -or $_.id -match '^[0-9A-F]+$'
    })
}

Write-Host "`n=== Android emulators ===" -ForegroundColor Cyan
flutter emulators
Write-Host ""

$emulators = @(
  @{ Id = "1"; Name = "Launch Pixel 8 (API 37, tuned for this PC)" },
  @{ Id = "2"; Name = "Launch Medium Phone API 37" },
  @{ Id = "3"; Name = "Skip — use a device already running" }
)

foreach ($e in $emulators) {
  Write-Host "  [$($e.Id)] $($e.Name)"
}
$pick = Read-Host "Start emulator? Enter 1, 2, or 3"
if ($pick -eq "1") { & (Join-Path $root "scripts\start-pixel8-emulator.ps1") -Wait }
elseif ($pick -eq "2") {
  flutter emulators --launch Medium_Phone_API_37.0
  Start-Sleep -Seconds 8
}

Write-Host "`nWaiting for an Android device..." -ForegroundColor Cyan
$deadline = (Get-Date).AddMinutes(3)
do {
  $android = Get-AndroidDevices
  if ($android.Count -gt 0) { break }
  Start-Sleep -Seconds 3
} while ((Get-Date) -lt $deadline)

$android = Get-AndroidDevices
if ($android.Count -eq 0) {
  Write-Host "No Android device found. Start Pixel 8 in Device Manager or use option 1 above." -ForegroundColor Red
  exit 1
}
if ($android.Count -gt 1) {
  Write-Host "Warning: $($android.Count) Android devices — installs often fail. Close extra emulators." -ForegroundColor Yellow
}

Write-Host "`n=== Android targets ===" -ForegroundColor Cyan
$i = 0
$options = @()
foreach ($d in $android) {
  $i++
  Write-Host "  [$i] $($d.name) ($($d.id))"
  $options += $d.id
}

$choice = Read-Host "Select device (default 1)"
if ($choice -eq "") { $choice = "1" }
$idx = [int]$choice - 1
if ($idx -lt 0 -or $idx -ge $options.Count) {
  Write-Host "Invalid choice." -ForegroundColor Red
  exit 1
}

flutter run -d $options[$idx]