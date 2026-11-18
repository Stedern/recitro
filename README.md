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
2. **Emulator (Android Studio):** Device Manager → ▶ **Pixel 8** — close extra emulator windows if more than one is open.
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

**`ADB exited with exit code 1` / install failed**

Usually **two emulators** (e.g. `5554` + `5556`) or a **stuck install** on a slow AVD:

1. Close every emulator except one Pixel 8 window (Device Manager → stop extras).
2. `.\scripts\reset-android-app.ps1` then `flutter run -d emulator-5554` (use the id from `flutter devices`).
3. Prefer `.\scripts\start-pixel8-emulator.ps1 -Wait` before Run — it stops other emulators first.

Streamed install on this PC can take **1–2 minutes**; wait once before retrying.

**Android Studio Run fails at install:** Only one Pixel 8 emulator should run. If it still fails, run **Tools → External Tools → Reset Recitro on Android** (or `.\scripts\reset-android-app.ps1`), then Run again. Debug builds use the smaller **x86_64** APK (`split-per-abi` in `android/gradle.properties`).

**Run in Android Studio**

1. **File → Open** → `C:\Users\Jay\Projects\recitro` (the Flutter project root — not the `android` folder alone).
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