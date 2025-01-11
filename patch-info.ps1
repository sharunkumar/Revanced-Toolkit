[CmdletBinding()]
param (
    [Parameter()] 
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            # same as $AppId = ""; TODO: dump app ids to a file on update maybe?
            [array] $validValues = (java -jar .\revanced\revanced-cli.jar list-versions .\revanced\revanced-patches.rvp | Where-Object { $_ -like "Package name:*" } | ForEach-Object { $_.Split(": ")[1] } | Sort-Object | Get-Unique)
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
    $PackageFilter = @("-f", $AppId)
}

if ($ListVersions) {
    return java -jar .\revanced\revanced-cli.jar list-versions $PackageFilter .\revanced\revanced-patches.rvp
}

if ($ListPatches) {
    return java -jar .\revanced\revanced-cli.jar list-patches --with-descriptions --index=false --with-options --with-packages --with-versions $PackageFilter --with-universal-patches=false .\revanced\revanced-patches.rvp
}

if ($AppId -eq "") {
    return java -jar .\revanced\revanced-cli.jar list-versions .\revanced\revanced-patches.rvp | Where-Object { $_ -like "Package name:*" } | ForEach-Object { $_.Split(": ")[1] } | Sort-Object | Get-Unique
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