#!/usr/bin/env pwsh
function Compare-AppVersions($v1, $v2) {
    $v1Clean = ($v1 -replace '-.*$', '') -replace '[^0-9.]', ''
    $v2Clean = ($v2 -replace '-.*$', '') -replace '[^0-9.]', ''
    
    $parts1 = $v1Clean.Split('.') | ForEach-Object { if ($_ -match '^\d+$') { [int]$_ } else { 0 } }
    $parts2 = $v2Clean.Split('.') | ForEach-Object { if ($_ -match '^\d+$') { [int]$_ } else { 0 } }
    
    $maxLen = [Math]::Max($parts1.Count, $parts2.Count)
    
    for ($i = 0; $i -lt $maxLen; $i++) {
        $p1 = if ($i -lt $parts1.Count) { $parts1[$i] } else { 0 }
        $p2 = if ($i -lt $parts2.Count) { $parts2[$i] } else { 0 }
        
        if ($p1 -lt $p2) { return -1 }
        if ($p1 -gt $p2) { return 1 }
    }
    return 0
}

function Get-LatestVersion($versions) {
    if ($null -eq $versions -or $versions.Count -eq 0) { return $null }
    $latest = $versions[0]
    foreach ($v in $versions) {
        if ((Compare-AppVersions $v $latest) -gt 0) { $latest = $v }
    }
    return $latest
}

function Parse-PatchesTxt($filePath) {
    $packageVersions = @{}
    $currentPackage = $null
    
    $lines = Get-Content $filePath
    foreach ($line in $lines) {
        if ($line -match '^\s*Package name:\s*(.+)$') {
            $currentPackage = $matches[1].Trim()
            if (-not $packageVersions.ContainsKey($currentPackage)) {
                $packageVersions[$currentPackage] = @()
            }
        }
        elseif ($line -match '^\s*Compatible versions:$') {
        }
        elseif ($currentPackage -and $line -match '^\s{2,}([\d.]+(-[a-zA-Z0-9.]+)?)\s*$') {
            $version = $matches[1].Trim()
            if ($version -and $packageVersions[$currentPackage] -notcontains $version) {
                $packageVersions[$currentPackage] += $version
            }
        }
        elseif ($line -match '^Name:\s') {
            $currentPackage = $null
        }
    }
    
    return $packageVersions
}

Write-Host "=== Patch Update Check ===" -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptPath) { $scriptPath = "." }
$patchesTxt = Join-Path $scriptPath "revanced" "patches.new.txt"

if (-not (Test-Path $patchesTxt)) {
    Write-Host "ERROR: patches.new.txt not found at $patchesTxt" -ForegroundColor Red
    Write-Host "Run update.ps1 first to generate it" -ForegroundColor Yellow
    exit 1
}

$adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adb) {
    Write-Host "ERROR: adb not found in PATH" -ForegroundColor Red
    exit 1
}

$devices = adb devices 2>$null | Select-Object -Skip 1 | ForEach-Object { $_.Trim() -replace '\s+.*$', '' } | Where-Object { $_ -ne '' }
if ($devices.Count -eq 0) {
    Write-Host "ERROR: No Android device connected" -ForegroundColor Red
    exit 1
}

Write-Host "Device connected: $($devices.Count) device(s) found" -ForegroundColor Green

$packageVersions = Parse-PatchesTxt $patchesTxt

$withVersions = ($packageVersions.Values | Where-Object { $_.Count -gt 0 }).Count
Write-Host "Found $($packageVersions.Count) apps with patches ($withVersions with version info)" -ForegroundColor Gray

$revancedPackages = @{}
$revancedRaw = adb shell "pm list packages" 2>$null | Out-String
$revancedRaw -split "`n" | ForEach-Object {
    if ($_ -match 'package:(.+)$') {
        $pkg = $matches[1].Trim()
        if ($pkg -like 'app.revanced.*') {
            $original = $pkg -replace '^app\.revanced\.android\.', 'com.google.android.'
            $revancedPackages[$original] = $pkg
        }
    }
}
Write-Host "Found $($revancedPackages.Count) ReVanced variants on device" -ForegroundColor Gray
Write-Host ""

$outdated = 0
$checked = 0
$results = @()

foreach ($pkgName in $packageVersions.Keys | Sort-Object) {
    $supportedVersions = $packageVersions[$pkgName]
    $latestSupported = Get-LatestVersion $supportedVersions
    
    $output = $null
    
    if ($revancedPackages.ContainsKey($pkgName)) {
        $checkPkg = $revancedPackages[$pkgName]
        $raw = adb shell "dumpsys package $checkPkg" 2>$null | Out-String
        $match = $raw -split "`n" | Select-String "versionName=" | ForEach-Object {
            $_ -replace '.*versionName=([^\s]+).*', '$1'
        }
        if ($match) {
            $output = $match.Trim()
        }
    }
    
    if (-not $output) {
        $raw = adb shell "dumpsys package $pkgName" 2>$null | Out-String
        $match = $raw -split "`n" | Select-String "versionName=" | ForEach-Object {
            $_ -replace '.*versionName=([^\s]+).*', '$1'
        }
        if ($match) {
            $output = $match.Trim()
        }
    }
    
    if (-not $output) {
        continue
    }
    
    if ($revancedPackages.ContainsKey($pkgName)) {
        $checkPkg = $revancedPackages[$pkgName]
    } else {
        $checkPkg = $pkgName
    }
    $raw = adb shell "dumpsys package $checkPkg" 2>$null | Out-String
    if ($raw -match "installerPackageName=(?!null)\S+") {
        continue
    }
    
    $installedVersion = $output
    $checked++
    
    if ($supportedVersions.Count -eq 0) {
        $results += [PSCustomObject]@{
            Package = $pkgName
            Installed = $installedVersion
            Supported = "Unknown"
            Status = "?"
        }
    }
    else {
        $comparison = Compare-AppVersions $installedVersion $latestSupported
        
        if ($comparison -lt 0) {
            $results += [PSCustomObject]@{
                Package = $pkgName
                Installed = $installedVersion
                Supported = $latestSupported
                Status = "OUTDATED"
            }
            $outdated++
        }
        elseif ($comparison -eq 0) {
            $results += [PSCustomObject]@{
                Package = $pkgName
                Installed = $installedVersion
                Supported = $latestSupported
                Status = "OK"
            }
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "No patched apps found on device" -ForegroundColor Yellow
    exit 0
}

$maxPkgLen = ($results.Package | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
$maxInstLen = ($results.Installed | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
$maxSuppLen = ($results.Supported | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

$header = "  Package" + (" " * ([Math]::Max(0, $maxPkgLen - 7))) + "  Installed" + (" " * ([Math]::Max(0, $maxInstLen - 9))) + "  Supported"
Write-Host $header
Write-Host ("-" * [Math]::Max($header.Length, 70))

foreach ($r in $results) {
    $pkgPad = " " * (2 + $maxPkgLen - $r.Package.Length)
    $instPad = " " * (2 + $maxInstLen - $r.Installed.Length)
    
    $color = switch ($r.Status) {
        "OUTDATED" { "Red" }
        "OK" { "Green" }
        default { "Yellow" }
    }
    
    $line = "[$($r.Status)]  $($r.Package)$pkgPad  $($r.Installed)$instPad  $($r.Supported)"
    Write-Host $line -ForegroundColor $color
}

Write-Host ""
Write-Host ("-" * 40)
if ($outdated -gt 0) {
    Write-Host "$outdated of $checked apps are outdated" -ForegroundColor Yellow
} elseif ($checked -gt 0) {
    Write-Host "All $checked checked apps are up to date" -ForegroundColor Green
}
