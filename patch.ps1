[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            [array] $validValues = (Get-ChildItem -Path .\apk\ -Filter "*.apk*" | Where-Object { $_.Extension -in ".apk", ".apkm" } | ForEach-Object { $_.BaseName } | Where-Object { $_ -notlike "*-patched" })
            return $validValues -like "*$wordToComplete*"
        })] [string] $AppName,
    [Parameter()] [string[]] $Includes = @(),
    [Parameter()] [string[]] $Excludes = @(),
    [Parameter()] [switch] $Install,
    [Parameter()] [int] $ForUser = 0
)

if (Test-Path ".\apk\$AppName.apkm") {
    Write-Output "Apkm detected, converting to apk"
    Remove-Item ".\apk\$AppName.apk" -ErrorAction SilentlyContinue
    java -jar .\revanced\apkeditor.jar m -i ".\apk\$AppName.apkm" -o ".\apk\$AppName.apk"
}

if (-not (Test-Path ".\apk\$AppName.apk")) {
    Write-Host -ForegroundColor Red "Not Found: .\apk\$AppName.apk"
    Exit 1
}

$includesParam = ($Includes | ForEach-Object { "--include=$_" })
$excludesParam = ($Excludes | ForEach-Object { "--exclude=$_" })
$keystoreParam = ("--keystore-entry-alias=alias", "--keystore-entry-password=ReVanced", "--keystore-password=ReVanced")

java -jar .\revanced\revanced-cli.jar patch `
    --out ".\apk\$AppName-patched.apk" `
    --patches .\revanced\revanced-patches.rvp `
    --keystore .\revanced\revanced.keystore `
    --temporary-files-path "$env:TEMP\Revanced" $keystoreParam $includesParam $excludesParam `
    ".\apk\$AppName.apk"

if ($LASTEXITCODE -ne 0) {
    Write-Host -ForegroundColor Red "Patch Failed. Exit Code: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

if ($Install) {
    adb install --user $ForUser ".\apk\$AppName-patched.apk"
}