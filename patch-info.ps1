[CmdletBinding()]
param (
    [Parameter()] 
    [ValidateScript(
        { $_ -in (Get-Content .\revanced\patches.json | ConvertFrom-Json | ForEach-Object { $_.compatiblePackages.name } | Sort-Object | Get-Unique) },
        ErrorMessage = 'invalid app id / app not compatible with revanced'
    )]
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            # This is the duplicated part of the code in the [ValidateScipt] attribute.
            [array] $validValues = (Get-Content .\revanced\patches.json | ConvertFrom-Json | ForEach-Object { $_.compatiblePackages.name } | Sort-Object | Get-Unique)
            $validValues -like "*$wordToComplete*"
        })] [string] $AppId,
    [Parameter()] [switch] $PlayStore,
    [Parameter()] [switch] $ApkMirror,
    [Parameter()] [switch] $ApkPure,
    [Parameter()] [switch] $Versions,
    [Parameter()] [switch] $VersionAgnostic,
    [Parameter()] [switch] $ListVersions,
    [Parameter()] [switch] $ListPatches,
    [Parameter()] [switch] $Raw
)

$PackageFilter = ""

if ($AppId -ne "") {
    $PackageFilter = @("-f", $AppId, "--with-universal-patches=false")
}

if ($ListVersions) {
    return java -jar .\revanced\revanced-cli.jar list-versions $PackageFilter .\revanced\revanced-patches.rvp
}

if ($ListPatches) {
    return java -jar .\revanced\revanced-cli.jar list-patches --with-descriptions --index=false --with-options --with-packages --with-versions $PackageFilter .\revanced\revanced-patches.rvp
}

if ($AppId -eq "") {
    return Get-Content .\revanced\patches.json | ConvertFrom-Json | ForEach-Object { $_.compatiblePackages.name } | Sort-Object | Get-Unique
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

$result = Get-Content .\revanced\patches.json | ConvertFrom-Json | Where-Object { $_.compatiblePackages.name -eq $AppId }

if ($VersionAgnostic) {
    if ($Raw) {
        return $result | Where-Object { $_.compatiblePackages.versions.length -eq 0 }
    }
    return $result | Where-Object { $_.compatiblePackages.versions.length -eq 0 } | Format-Table
}

if ($Versions) {
    return $result | ForEach-Object { $_.compatiblePackages.versions } | Sort-Object -Descending | Get-Unique
}

if ($Raw) {
    return $result
}

return $result | Format-Table


# default show help
# Get-Help $MyInvocation.MyCommand.Path