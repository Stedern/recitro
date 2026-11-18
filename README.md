# Recitro

Offline classroom recitation tracker for **Android** (emulator or phone).

## Flutter on this PC

Flutter **stable** is installed at:

`C:\Users\Jay\develop\flutter`

`C:\Users\Jay\develop\flutter\bin` has been added to your **user** `PATH`. Open a **new** terminal (or restart Cursor) so `flutter` is recognized everywhere.

Verify:

```powershell
flutter doctor
```

### Android

Android Studio is installed. SDK location:

`C:\Users\Jay\AppData\Local\Android\sdk`

User environment: `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and `flutter config --android-sdk` / `--jdk-dir` are set.

**Select a device and run**

You need an **Android device in the list** before Run works in the IDE:

1. **Emulator (recommended on this PC):**  
   ```powershell
   cd C:\Users\Jay\Projects\recitro
   .\scripts\start-pixel8-emulator.ps1 -Wait
   flutter run
   ```  
   This uses **Pixel 8 · API 37 · Google Play** with lighter RAM/CPU so it does not hang on ~8 GB RAM.  
   If adb stays `offline`, retry once with `.\scripts\start-pixel8-emulator.ps1 -WipeData -Wait` (factory-resets the AVD only).
2. **Emulator (Android Studio):** Use **Pixel 8** only — **not** `Medium_Phone_API_37.0`.  
   If you see `FATAL | Running multiple emulators with the same AVD`, run `.\scripts\stop-all-emulators.ps1` and start again with `.\scripts\start-pixel8-emulator.ps1 -Wait`.
3. **Physical phone:** USB cable + **USB debugging** on → allow PC when prompted.
4. Check: `flutter devices` — you should see an `android` / `emulator-####` line (not `offline`).

**Terminal (pick device interactively):**

```powershell
cd C:\Users\Jay\Projects\recitro
.\scripts\run.ps1
```

**Terminal (one command after emulator is running):**

```powershell
cd C:\Users\Jay\Projects\recitro
flutter devices
flutter run
```

If more than one device is connected, `flutter run` asks which to use. Or pass an id: `flutter run -d emulator-5554`.

**Cursor / VS Code:** **Run and Debug** (F5) → **Recitro (Pixel 8 emulator)** or **Recitro (Android)**. The project is set to **Android only** (no Chrome/Windows targets in launch configs).

Accept Android SDK licenses once if `flutter doctor` reports them: `flutter doctor --android-licenses`

Debug APK (after first build): `build\app\outputs\flutter-apk\app-debug.apk`

**`ADB exited with exit code 1` / `Broken pipe (32)` / `force-stop` timed out**

Usually **two emulators**, **Package Manager hung**, or **install while the AVD is restarting**:

1. Close every emulator except **one Pixel 8** (Device Manager → stop extras).
2. `.\scripts\ensure-pixel8-ready.ps1` (reboots once if `pm` is stuck).
3. `.\scripts\reset-android-app.ps1` then Run again.
4. Or one shot: `.\scripts\run-pixel8.ps1`

Streamed install can take **~20–90 seconds** on this AVD — do not spam Retry.

**Android Studio (Pixel 8 only):**

- Device dropdown → **sdk gphone64 x86 64 (emulator-5554)** (not Chrome/Windows).
- **Run → Edit Configurations →** your Flutter config → **Additional run args:**  
  `-d emulator-5554 --target-platform=android-x64`
- **Before every Run** (Android Studio does not wait for Package Manager):  
  ```powershell
  .\scripts\prepare-android-studio-run.ps1
  ```  
  Wait until you see **`Ready: emulator-5554`** (can take 1–3 min after emulator window opens). Then click **Run**.
- If install still fails: `.\scripts\install-android-studio-run.ps1`

**`device is still booting`:** adb sees the emulator before `pm` is up. Do **not** click Run as soon as the window appears — run `prepare-android-studio-run.ps1` first or wait for the home screen + another ~30s on slow boots.

Debug builds use the **x86_64** APK (`split-per-abi` + copy hook in `android/app/build.gradle.kts`).

**Blank / frozen emulator after Run (app “wala jud”)**

Android Studio often runs with **`--start-paused`**. The app is waiting on the debugger — press **Resume Program (F9)** or the green **▶** on the debug toolbar so the UI draws.

Or use **Tools → External Tools → Run Recitro on Pixel 8** (wait + run, no pause).

**Only one emulator (required)**

Your PC has ~7.5 GB RAM free — **never run two emulators**. In Device Manager use **Pixel 8** only; stop **Medium Phone** if it is running.  
Quick fix: `.\scripts\stop-all-emulators.ps1` then `.\scripts\start-pixel8-emulator.ps1 -Wait`.

**Run in Android Studio**

1. **File → Open** → `C:\Users\Jay\Projects\recitro` (the Flutter project root — not the `android` folder alone).  
   Default run config: **Recitro (Pixel 8)** (runs **Ensure Pixel 8 ready** before launch).
2. **Install the Flutter plugin** (required — without it you get `Unknown run configuration type FlutterRunConfigurationType`):
   - **File → Settings → Plugins** (on macOS: **Android Studio → Settings → Plugins**)
   - **Marketplace** → search **Flutter** → **Install** (this also installs **Dart**)
   - **Restart** Android Studio
3. **File → Settings → Languages & Frameworks → Flutter** → Flutter SDK path: `C:\Users\Jay\develop\flutter`
4. Create/start an emulator (**Device Manager**) or plug in a phone with USB debugging on.
5. **Device Manager** → start **Pixel 8** (or any AVD) so it appears in the device dropdown.
6. Open `lib/main.dart` → use the **device dropdown** next to the green **Run** button → pick the emulator or phone → **Run**.

**Without the plugin**, run from a terminal instead: `cd C:\Users\Jay\Projects\recitro` then `flutter run`.

First Gradle build can take 10–20 minutes while it downloads Gradle, NDK, and SDK pieces; later runs are much faster.

## Using Recitro

| Tab | What you do |
|-----|-------------|
| **Students** | Add, edit, and delete students (all data stays on device). |
| **Sessions** | Create a session (name, points per answer, **Recall if not answered** toggle). Open a session and tap **Call** for a random eligible student. Mark **Answered** (adds points) or **Not answered**. |

**Call rules**

- You must respond in the dialog before calling again.
- **Answered** students are not called again in that session.
- If **Recall if not answered** is off, students marked not answered cannot be called again.
- If recall is on, not-answered students can be picked again.

Data is stored locally in `recitro_data.json` under the app documents folder.