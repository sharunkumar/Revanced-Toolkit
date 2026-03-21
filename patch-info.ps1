#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    [Parameter()] 
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            # same as $AppId -eq ""
            [array] $validValues = (Get-Content (Join-Path "." "revanced" "patches.new.txt") | Where-Object { $_ -like "*Package name:*" } | Sort-Object | Get-Unique | ForEach-Object { $_.split(": ")[1] })
            $validValues -like "*$wordToComplete*"
        })] [string] $AppId,
    [Parameter()] [switch] $PlayStore,
    [Parameter()] [switch] $ApkMirror,
    [Parameter()] [switch] $ApkPure,
    [Parameter()] [switch] $ListVersions,
    [Parameter()] [switch] $ListPatches
)

$PackageFilter = ""

$PatchesArgs = @("--bypass-verification", "-p", (Join-Path "." "revanced" "revanced-patches.rvp"))

if ($AppId -ne "") {
    if($ListVersions) {
        $PackageFilter = @("--filter-package-names", $AppId)
    } elseif ($ListPatches) {
        $PackageFilter = @("--filter-package-name", $AppId)
    }
}

if ($ListVersions) {
    return java -jar (Join-Path "." "revanced" "revanced-cli.jar") list-versions $PackageFilter $PatchesArgs
}

if ($ListPatches) {
    return java -jar (Join-Path "." "revanced" "revanced-cli.jar") list-patches --descriptions --index=false --options --packages --versions $PackageFilter --universal-patches=false $PatchesArgs
}

if ($AppId -eq "") {
    if ($AppId -eq "") {
        return Get-Content (Join-Path "." "revanced" "patches.new.txt") | Where-Object { $_ -like "*Package name:*" } | Sort-Object | Get-Unique | ForEach-Object { $_.split(": ")[1] }
    }
}

if ($PlayStore) {
    return Start-Process "https://play.google.com/store/apps/details?id=$AppId"
}

if ($ApkMirror) {
    return Start-Process "https://www.apkmirror.com/?post_type=app_release&searchtype=apk&s=$AppId"
}

if ($ApkPure) {
    return Start-Process "https://apkpure.com/search?q=$AppId"
}
