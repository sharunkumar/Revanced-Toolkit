# load the curent patches
$old_patches = Get-Content .\revanced\patches.json | ConvertFrom-Json
# $patch_names = $old_patches | ForEach-Object { $_.name }


# get latest release for https://github.com/revanced/revanced-cli
$cli = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest"

# get latest release for https://github.com/revanced/revanced-patches
$patches = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest"

# get latest release for https://github.com/revanced/revanced-integrations
$integrations = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"

function Get-LatestAsset($release, $name_filter) {
    $asset = $release.assets | Where-Object { $_.name -like $name_filter }
    if ($asset) {
        return @{
            url  = $asset.browser_download_url
            name = $asset.name
        }
    }
    return $null
}

# get latest asset for revanced-cli
Get-LatestAsset $cli "*-all.jar" | ForEach-Object {
    Invoke-WebRequest -Uri $_.url -OutFile "revanced\revanced-cli.jar"
}

# get latest asset for revanced-patches
Get-LatestAsset $patches "*.jar" | ForEach-Object {
    Invoke-WebRequest -Uri $_.url -OutFile "revanced\revanced-patches.jar"
}

# get latest asset for patches.json
Get-LatestAsset $patches "*.json" | ForEach-Object {
    Invoke-WebRequest -Uri $_.url -OutFile "revanced\patches.json"
}

# get latest asset for revanced-integrations
Get-LatestAsset $integrations "*.apk" | ForEach-Object {
    Invoke-WebRequest -Uri $_.url -OutFile "revanced\integrations.apk"
}

# get the diff between patches
$new_patches = Get-Content .\revanced\patches.json | ConvertFrom-Json

function Get-LogPatch($patches) {
    return $patches | ForEach-Object {
        $me = $_
        
        return $_.compatiblePackages | ForEach-Object {
            $package = $_
            return ($package.name) + ": " + $me.name + " " + ($package.versions | Sort-Object -Descending | Select-Object -First 1)
        }
    } | Sort-Object
}

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