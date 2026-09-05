# Helper script for publishing a new AssPOS phone update.
#
# It updates version_phone.txt locally and prints the exact steps required to
# push the file and publish the APK as a GitHub Release. It does NOT push or
# upload anything by itself.

param(
    [string]$NewVersion = "",
    [string]$ApkSource = "E:\AssPOS-Phone\build\app\outputs\flutter-apk\app-release.apk"
)

$ErrorActionPreference = "Stop"

## The GitHub username/organization that owns the repository.
$Owner = "DevDzT1"
$Repo = "AssPOS-Phone-Updates"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile = Join-Path $RepoDir "version_phone.txt"

$current = ""
if (Test-Path $VersionFile) {
    $current = (Get-Content $VersionFile -Raw).Trim()
}

if ([string]::IsNullOrWhiteSpace($NewVersion)) {
    Write-Host ""
    Write-Host "Current version in version_phone.txt: '$current'"
    $NewVersion = Read-Host "Enter the NEW app version (e.g. 1.3.1)"
}
$NewVersion = $NewVersion.Trim()
if ([string]::IsNullOrWhiteSpace($NewVersion)) {
    throw "No version provided. Aborting."
}

## 1) Bump the local version file (staged for git).
[System.IO.File]::WriteAllText($VersionFile, $NewVersion, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ""
Write-Host "[OK] version_phone.txt updated to: $NewVersion"

## 2) Check the built APK exists.
if (-not (Test-Path $ApkSource)) {
    Write-Host ""
    Write-Host "[WARN] APK not found at: $ApkSource"
    Write-Host "       Build it first from E:\AssPOS-Phone :"
    Write-Host "         flutter build apk --release"
} else {
    $apkSize = [math]::Round((Get-Item $ApkSource).Length / 1MB, 1)
    Write-Host "[OK] APK found: $ApkSource ($apkSize MB)"
}

## 3) Print the manual steps.
$downloadUrl = "https://github.com/$Owner/$Repo/releases/download/v$NewVersion/AssPOS-Phone_v$NewVersion.apk"

Write-Host ""
Write-Host "============================================================"
Write-Host " NEXT STEPS (run them manually):"
Write-Host "============================================================"
Write-Host ""
Write-Host " 1. Commit and push the version file:"
Write-Host "      cd `"$RepoDir`""
Write-Host "      git add version_phone.txt"
Write-Host "      git commit -m `"release v$NewVersion`""
Write-Host "      git push"
Write-Host ""
Write-Host " 2. Make sure the APK is freshly built and rename it to exactly:"
Write-Host "      AssPOS-Phone_v$NewVersion.apk"
Write-Host ""
Write-Host " 3. Create a GitHub Release on github.com/$Owner/$Repo :"
Write-Host "      Tag    : v$NewVersion"
Write-Host "      Title  : v$NewVersion"
Write-Host "      Attach : AssPOS-Phone_v$NewVersion.apk"
Write-Host ""
Write-Host " 4. Devices will download it from:"
Write-Host "      $downloadUrl"
Write-Host "============================================================"
Write-Host ""