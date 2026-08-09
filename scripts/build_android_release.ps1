$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$mobileRoot = Join-Path $repoRoot 'mobile'
$keyProperties = Join-Path $mobileRoot 'android\key.properties'
$symbols = Join-Path $mobileRoot 'build\symbols'

if (-not (Test-Path -LiteralPath $keyProperties)) {
    throw 'Missing mobile/android/key.properties. Copy key.properties.example and use a private upload keystore.'
}

Push-Location $mobileRoot
try {
    flutter pub get
    dart run build_runner build
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test
    flutter build appbundle --release --obfuscate --split-debug-info=$symbols
}
finally {
    Pop-Location
}

Write-Host 'Release bundle: mobile/build/app/outputs/bundle/release/app-release.aab'
Write-Host 'Private symbols: mobile/build/symbols'
