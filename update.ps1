# load functions
. .\functions.ps1

Save-PatchesInfo "revanced\patches.old.txt"

Get-AssetFile "https://api.github.com/repos/revanced/revanced-cli/releases/latest" "*-all.jar" "revanced\revanced-cli.jar"
Get-AssetFile "https://api.github.com/repos/revanced/revanced-patches/releases/latest" "*.rvp" "revanced\revanced-patches.rvp"

Save-PatchesInfo "revanced\patches.new.txt"

delta "revanced\patches.old.txt" "revanced\patches.new.txt"