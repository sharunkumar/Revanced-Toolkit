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

if ($AppId -ne "") {
    $PackageFilter = @("-f", $AppId)
}

if ($ListVersions) {
    return java -jar (Join-Path "." "revanced" "revanced-cli.jar") list-versions $PackageFilter (Join-Path "." "revanced" "revanced-patches.rvp")
}

if ($ListPatches) {
        return java -jar (Join-Path "." "revanced" "revanced-cli.jar") list-patches --with-descriptions --index=false --with-options --with-packages --with-versions $PackageFilter --with-universal-patches=false (Join-Path "." "revanced" "revanced-patches.rvp")
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
