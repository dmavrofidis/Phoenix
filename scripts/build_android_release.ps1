$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$mobileRoot = Join-Path $repoRoot 'mobile'
$keyProperties = Join-Path $mobileRoot 'android\key.properties'
$symbols = Join-Path $mobileRoot 'build\symbols'

if (-not (Test-Path -LiteralPath $keyProperties)) {
    throw 'Missing mobile/android/key.properties. Copy key.properties.example and use a private upload keystore.'
}
$signing = Get-Content -Raw -LiteralPath $keyProperties | ConvertFrom-StringData
$requiredSigningKeys = @('storePassword', 'keyPassword', 'keyAlias', 'storeFile')
foreach ($key in $requiredSigningKeys) {
    if ([string]::IsNullOrWhiteSpace($signing[$key]) -or $signing[$key] -eq 'CHANGE_ME') {
        throw "Android signing value '$key' is missing or still uses a placeholder."
    }
}
if (-not (Test-Path -LiteralPath $signing['storeFile'])) {
    throw "Android upload keystore was not found at the configured storeFile path."
}

Push-Location $mobileRoot
try {
    flutter pub get
    dart run build_runner build
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test
    flutter build appbundle --release --obfuscate --split-debug-info=$symbols
    flutter build apk --release --obfuscate --split-debug-info=$symbols

    $aab = Join-Path $mobileRoot 'build\app\outputs\bundle\release\app-release.aab'
    $apk = Join-Path $mobileRoot 'build\app\outputs\flutter-apk\app-release.apk'
    $checksums = @(
        "AAB $((Get-FileHash -Algorithm SHA256 -LiteralPath $aab).Hash.ToLowerInvariant())"
        "APK $((Get-FileHash -Algorithm SHA256 -LiteralPath $apk).Hash.ToLowerInvariant())"
    )
    $checksums | Set-Content -Encoding utf8 -LiteralPath (Join-Path $mobileRoot 'build\phoenix-release-sha256.txt')
}
finally {
    Pop-Location
}

Write-Host 'Release bundle: mobile/build/app/outputs/bundle/release/app-release.aab'
Write-Host 'Installable APK: mobile/build/app/outputs/flutter-apk/app-release.apk'
Write-Host 'Checksums: mobile/build/phoenix-release-sha256.txt'
Write-Host 'Private symbols: mobile/build/symbols'
