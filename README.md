# AssPOS Phone Updates

A minimal GitHub repository that powers the **in-app update check** of the
AssPOS Android app (Point of Sale).

The app checks this repository every time it starts (on the screen shown right
after the splash). If the published version is newer than the installed one, a
dialog appears automatically and lets the user download & install the new APK —
no update button needed.

---

## Repository layout

```
AssPOS-Phone-Updates/
├── version_phone.txt   # Current published app version (single line, e.g. 1.3.0)
├── README.md           # This file
├── publish_update.ps1  # Optional helper script for the release workflow
└── .gitignore          # Keeps the repo clean
```

### version_phone.txt

Plain text file containing exactly one line: the latest released app version.

```
1.3.0
```

The app reads it from:

```
https://raw.githubusercontent.com/<OWNER>/AssPOS-Phone-Updates/main/version_phone.txt
```

### GitHub Releases (APK hosting)

APK files are NOT committed to the repository. They are attached to
[GitHub Releases](https://docs.github.com/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

Each release must follow this naming so the app can build the download URL:

- **Tag / release name:** `v<version>` (e.g. `v1.3.1`)
- **Asset file name:** `AssPOS-Phone_v<version>.apk` (e.g. `AssPOS-Phone_v1.3.1.apk`)

The app downloads the APK from:

```
https://github.com/<OWNER>/AssPOS-Phone-Updates/releases/download/v<version>/AssPOS-Phone_v<version>.apk
```

---

## How the update flow works

1. App opens → splash screen → first screen (server selection).
2. The app fetches `version_phone.txt` from the `main` branch.
3. The version is compared to the installed app version
   (`AppConstants.version`).
4. If the repo version is **newer**:
   - A dialog appears automatically: *"توجد نسخة جديدة / يوجد تحديث جديد"*.
   - `تحديث الآن` → the app downloads the APK into its storage and launches the
     Android system installer (FileProvider + `REQUEST_INSTALL_PACKAGES`).
   - `لاحقاً` → nothing happens, the user continues normally.
5. If versions are equal (or fetch fails) nothing is shown.

Versions use dot-separated numbers (1.3.0, 1.3.1, 1.4.0 …). Semantic ordering
is applied, so `1.3.10` is newer than `1.3.9`.

---

## How to publish a new update (step by step)

> Replace `<OWNER>` below with your GitHub username or organization, and
> `<REPO>` with `AssPOS-Phone-Updates`.

### 1. Bump the app version

In `E:\AssPOS-Phone`:

| File                                  | Change                                   |
| ------------------------------------- | ---------------------------------------- |
| `lib/core/constants/app_constants.dart` | `version = '1.3.1'`                      |
| `android/app/build.gradle`            | `versionCode = 5`, `versionName = "1.3.1"` |
| `pubspec.yaml`                        | `version: 1.3.1+5`                       |

Build the release APK:

```bash
cd E:\AssPOS-Phone
flutter build apk --release
```

The output is:

```
E:\AssPOS-Phone\build\app\outputs\flutter-apk\app-release.apk
```

### 2. Update the version file

Set `/version_phone.txt` to the new version (e.g. `1.3.1`) and commit:

```bash
# from the repository folder
git add version_phone.txt
git commit -m "release v1.3.1"
git push
```

### 3. Publish the APK as a GitHub Release

1. Open the repository → **Releases** → **Create a new release**.
2. Tag: `v1.3.1` — Target: `main` — Title: `v1.3.1`.
3. Attach the APK file renamed to exactly `AssPOS-Phone_v1.3.1.apk`.
4. Write release notes (optional) and press **Publish release**.

That's it. The next time a device with an older version opens the app, the
update prompt appears automatically.

---

## Helper script (optional)

`publish_update.ps1` reminds you of the full flow and updates
`version_phone.txt` locally:

```powershell
cd C:\Users\XPRISTO\Desktop\AssPOS-Phone-Updates
.\publish_update.ps1 -NewVersion 1.3.1
```

It does **not** push (no GitHub CLI is installed) — it prints the exact git and
GitHub Release steps for you to run manually.

## Requirements & notes

- The APK is signed with the production keystore (`release-key.jks`) before
  release — the app will not update/install otherwise.
- On Android 8+, the device must allow "Install unknown apps" for this app; the
  app requests the system installer via `ACTION_VIEW` with the
  `REQUEST_INSTALL_PACKAGES` permission already declared.
- Repo must be **public** (or your private repo reachable from devices) and the
  `version_phone.txt` must exist on the `main` branch.