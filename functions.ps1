#!/usr/bin/env pwsh
function Get-AssetFile($url, $pattern, $fileName) {
    $release = Invoke-RestMethod -Uri $url
    Get-LatestAsset $release $pattern | ForEach-Object {
        Invoke-WebRequest -Uri $_.url -OutFile $fileName
    }
}

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

function Get-LogPatch($patches) {
    return $patches | ForEach-Object {
        $me = $_
        
        return $_.compatiblePackages | ForEach-Object {
            $package = $_
            return ($package.name) + ": " + $me.name + " " + ($package.versions | Sort-Object -Descending | Select-Object -First 1)
        }
    } | Sort-Object
}

function Save-PatchesInfo($fileName) {
    java -jar .\revanced\revanced-cli.jar list-patches --with-descriptions --index=false --with-options=false --with-packages --with-versions --with-universal-patches .\revanced\revanced-patches.rvp > $fileName
}
