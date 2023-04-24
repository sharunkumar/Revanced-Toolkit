function Get-LogPatch($patches) {
    return $patches | ForEach-Object {
        $me = $_
        
        return $_.compatiblePackages | ForEach-Object {
            $package = $_
            return ($package.name -split "\." | Select-Object -Last 1) + ": " + $me.name + " " + ($package.versions | Sort-Object -Descending | Select-Object -First 1)
        }
    } | Sort-Object
}

$p1 = Get-Content .\revanced\patches-old.json | ConvertFrom-Json
$p2 = Get-Content .\revanced\patches.json | ConvertFrom-Json

Compare-Object -ReferenceObject (Get-LogPatch($p1)) -DifferenceObject (Get-LogPatch($p2)) | Sort-Object -Property @{Expression = "InputObject"; Descending = $false },
@{Expression = "SideIndicator"; Descending = $true } | ForEach-Object {
    # color red -> old, color green -> new
    if ($_.SideIndicator -eq "<=") {
        Write-Host $_.InputObject -ForegroundColor Red
    }
    else {
        Write-Host $_.InputObject -ForegroundColor Green
    }
}