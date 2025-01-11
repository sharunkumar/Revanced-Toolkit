# Revanced-Toolkit

A toolkit of PowerShell scripts to work with Revanced patches.

## Scripts

### update.ps1

This script updates the Revanced CLI, patches, and APK Editor to their latest versions.

#### Usage

```powershell
.\update.ps1
```

### patch.ps1

This script patches an APK or APKM file using the Revanced CLI.

#### Parameters

- `-AppName` (Mandatory): The name of the app to patch.
- `-Includes` (Optional): Patches to include.
- `-Excludes` (Optional): Patches to exclude.
- `-Install` (Optional): Install the patched APK using ADB.
- `-ForUser` (Optional): Specify the user for ADB installation.

#### Usage

```powershell
.\patch.ps1 -AppName "example" -Includes "patch1", "patch2" -Excludes "patch3" -Install -ForUser 0
```

### patch-info.ps1

This script provides information about available patches and versions.

#### Parameters

- `-AppId` (Optional): The app ID to filter patches.
- `-PlayStore` (Optional): Open the app in the Play Store.
- `-ApkMirror` (Optional): Search for the app on APKMirror.
- `-ApkPure` (Optional): Search for the app on APKPure.
- `-ListVersions` (Optional): List all versions.
- `-ListPatches` (Optional): List all patches.

#### Usage

```powershell
.\patch-info.ps1 -AppId "com.example.app" -ListPatches
```

## Notes

- Ensure you have Java installed and added to your PATH.
- Make sure ADB is installed and configured if you plan to use the `-Install` option.
