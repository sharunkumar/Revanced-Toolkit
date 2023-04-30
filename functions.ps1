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

if ($MyInvocation.ScriptName.Length -eq 0) {
    # The script is being executed as the main entry point
    Get-LogPatch (Get-Content .\revanced\patches.json | ConvertFrom-Json)
}
