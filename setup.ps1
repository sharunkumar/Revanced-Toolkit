#!/usr/bin/env pwsh
[CmdletBinding()]
param ()

$keystorePath = (Join-Path "." "revanced" "revanced.keystore")
if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at $keystorePath"
    Exit 0
}

Write-Host "Creating keystore..."
try {
    Get-Command keytool -ErrorAction Stop | Out-Null
}
catch {
    Write-Host -ForegroundColor Red "'keytool' not found. Please make sure you have a JDK installed and 'keytool' is in your PATH."
    Exit 1
}

# The -dname parameter provides the details non-interactively.
keytool -genkeypair -v -keystore $keystorePath -alias "alias" -keypass "ReVanced" -storepass "ReVanced" -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=ReVanced, OU=ReVanced, O=ReVanced, L=ReVanced, S=ReVanced, C=RV"

if ($LASTEXITCODE -eq 0) {
    Write-Host -ForegroundColor Green "Keystore created successfully at $keystorePath"
} else {
    Write-Host -ForegroundColor Red "Failed to create keystore. Exit Code: $LASTEXITCODE"
    Exit $LASTEXITCODE
}