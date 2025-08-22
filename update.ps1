#!/usr/bin/env pwsh
# load functions
. (Join-Path "." "functions.ps1")

Save-PatchesInfo (Join-Path "revanced" "patches.old.txt")

Get-AssetFile "https://api.github.com/repos/revanced/revanced-cli/releases/latest" "*-all.jar" (Join-Path "revanced" "revanced-cli.jar")
Get-AssetFile "https://api.github.com/repos/revanced/revanced-patches/releases/latest" "*.rvp" (Join-Path "revanced" "revanced-patches.rvp")
Get-AssetFile "https://api.github.com/repos/REAndroid/APKEditor/releases/latest" "*.jar" (Join-Path "revanced" "apkeditor.jar")

Save-PatchesInfo (Join-Path "revanced" "patches.new.txt")

delta (Join-Path "revanced" "patches.old.txt") (Join-Path "revanced" "patches.new.txt")
