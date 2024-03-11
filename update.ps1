# load functions
. .\functions.ps1

# load the curent patches
$old_patches = Get-Content .\revanced\patches.json | ConvertFrom-Json

Get-AssetFile "https://api.github.com/repos/revanced/revanced-cli/releases/tags/v4.4.1" "*-all.jar" "revanced\revanced-cli.jar"
Get-AssetFile "https://api.github.com/repos/revanced/revanced-patches/releases/latest" "*.jar" "revanced\revanced-patches.jar"
Get-AssetFile "https://api.github.com/repos/revanced/revanced-patches/releases/latest" "*.json" "revanced\patches.json"
Get-AssetFile "https://api.github.com/repos/revanced/revanced-integrations/releases/latest" "*.apk" "revanced\integrations.apk"

# get the diff between patches
$new_patches = Get-Content .\revanced\patches.json | ConvertFrom-Json

Compare-Object -ReferenceObject (Get-LogPatch($old_patches)) -DifferenceObject (Get-LogPatch($new_patches)) | Sort-Object -Property @{Expression = "InputObject"; Descending = $false },
@{Expression = "SideIndicator"; Descending = $true } | ForEach-Object {
    # color red -> old, color green -> new
    if ($_.SideIndicator -eq "<=") {
        Write-Host $_.InputObject -ForegroundColor Red
    }
    else {
        Write-Host $_.InputObject -ForegroundColor Green
    }
}

# update options
. .\options.ps1
