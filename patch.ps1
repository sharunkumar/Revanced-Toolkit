[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)] [ValidateSet("youtube", "tiktok", "kik", "twitter", "memegenerator", "backdrops")] [string] $AppName,
    [Parameter()] [string[]] $Includes = @(),
    [Parameter()] [string[]] $Excludes = @()
)

$includesParam = ($Includes | ForEach-Object { "--include=$_" })
$excludesParam = ($Excludes | ForEach-Object { "--exclude=$_" })

java.exe -jar .\revanced\revanced-cli.jar -a ".\apk\$AppName.apk" -c -o ".\apk\$AppName-patched.apk" -b .\revanced\revanced-patches.jar -m .\revanced\integrations.apk --keystore .\revanced\revanced.keystore --temp-dir="$env:TEMP\Revanced" $includesParam $excludesParam
