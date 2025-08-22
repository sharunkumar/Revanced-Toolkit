#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            [array] $validValues = (Get-ChildItem -Path (Join-Path "." "apk") -Filter "*.apk*" | Where-Object { $_.Extension -in ".apk", ".apkm" } | ForEach-Object { $_.BaseName } | Where-Object { $_ -notlike "*-patched" })
            return $validValues -like "*$wordToComplete*"
        })] [string] $AppName,
    [Parameter()] [string[]] $Includes = @(),
    [Parameter()] [string[]] $Excludes = @(),
    [Parameter()] [string[]] $Options = @(),
    [Parameter()] [string[]] $Enable = @(),
    [Parameter()] [switch] $Install,
    [Parameter()] [int] $ForUser = 0
)

if (-not (Test-Path (Join-Path "." "revanced" "revanced.keystore"))) {
    Write-Host -ForegroundColor Red "Keystore not found. Please run .\setup.ps1 to create it."
    Exit 1
}

if (Test-Path (Join-Path "." "apk" "$AppName.apkm")) {
    Write-Output "Apkm detected, converting to apk"
    java -jar (Join-Path "." "revanced" "apkeditor.jar") m -f -i (Join-Path "." "apk" "$AppName.apkm") -o (Join-Path "." "apk" "$AppName.apk")
}

if (-not (Test-Path (Join-Path "." "apk" "$AppName.apk"))) {
    Write-Host -ForegroundColor Red "Not Found: $(Join-Path "." "apk" "$AppName.apk")"
    Exit 1
}

$includesParam = ($Includes | ForEach-Object { "--include=$_" })
$excludesParam = ($Excludes | ForEach-Object { "--exclude=$_" })
$keystoreParam = ("--keystore-entry-alias=alias", "--keystore-entry-password=ReVanced", "--keystore-password=ReVanced")
$optionsParam = ($Options | ForEach-Object { "-O$_" })
$enableParam = ($Options | ForEach-Object { "--enable=$_" })

java -jar (Join-Path "." "revanced" "revanced-cli.jar") patch `
    --out (Join-Path "." "apk" "$AppName-patched.apk") `
    --patches (Join-Path "." "revanced" "revanced-patches.rvp") `
    --keystore (Join-Path "." "revanced" "revanced.keystore") `
    --temporary-files-path (Join-Path $env:TEMP "Revanced") $keystoreParam $enableParam $optionsParam $includesParam $excludesParam `
(Join-Path "." "apk" "$AppName.apk")

if ($LASTEXITCODE -ne 0) {
    Write-Host -ForegroundColor Red "Patch Failed. Exit Code: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

if ($Install) {
    adb install --user $ForUser (Join-Path "." "apk" "$AppName-patched.apk")
}
