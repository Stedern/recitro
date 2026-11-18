# Android Studio — always Pixel 8, no install errors

## One-time setup

1. **Device toolbar:** `sdk gphone64 x86 64 (emulator-5554)` only — not Medium Phone, not Windows/Chrome.
2. **Run configuration:** **Recitro (Pixel 8)** (default).  
   If missing: duplicate `main.dart` → **Additional run args:** `--device-id=emulator-5554`
3. **Before launch:** add **External Tool → Ensure Pixel 8 ready** (see `.idea/tools/External Tools.xml`).

Gradle now runs `ensure-pixel8-ready.ps1` after every debug build (even UP-TO-DATE) so `Can't find service: package` is avoided.

## Every Run

1. Do **not** start a second emulator from Device Manager.
2. Click **Run**. If blank screen: **F9 (Resume)** — Studio uses `--start-paused`.
3. If it still fails: terminal `.\scripts\stop-all-emulators.ps1` then `.\scripts\start-pixel8-emulator.ps1 -Wait`, then Run again.

## Terminal alternative

```powershell
cd C:\Users\Jay\Projects\recitro
.\scripts\run-pixel8.ps1
```