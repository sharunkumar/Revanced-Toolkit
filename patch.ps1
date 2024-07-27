[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateScript(
        { $_ -in (Get-ChildItem -Path .\apk\ -Filter "*.apk" | ForEach-Object { $_.BaseName } | Where-Object { $_ -notlike "*-patched" }) },
        ErrorMessage = 'invalid app name. make sure the apk in in the .\apk folder'
    )]
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            # This is the duplicated part of the code in the [ValidateScipt] attribute.
            [array] $validValues = (Get-ChildItem -Path .\apk\ -Filter "*.apk" | ForEach-Object { $_.BaseName } | Where-Object { $_ -notlike "*-patched" })
            $validValues -like "*$wordToComplete*"
        })] [string] $AppName,
    [Parameter()] [string[]] $Includes = @(),
    [Parameter()] [string[]] $Excludes = @(),
    [Parameter()] [switch] $Install,
    [Parameter()] [int] $ForUser = 0
)

$includesParam = ($Includes | ForEach-Object { "--include=$_" })
$excludesParam = ($Excludes | ForEach-Object { "--exclude=$_" })
$keystoreParam = ("--keystore-entry-alias=alias", "--keystore-entry-password=ReVanced", "--keystore-password=ReVanced")

java.exe -jar .\revanced\revanced-cli.jar patch --out ".\apk\$AppName-patched.apk" --patch-bundle .\revanced\revanced-patches.jar --merge .\revanced\integrations.apk --keystore .\revanced\revanced.keystore --temporary-files-path "$env:TEMP\Revanced" $keystoreParam $includesParam $excludesParam ".\apk\$AppName.apk"

if ($LASTEXITCODE -ne 0) {
    Write-Host -ForegroundColor Red "Patch Failed. Exit Code: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

if ($Install) {
    adb.exe install --user $ForUser ".\apk\$AppName-patched.apk"
}