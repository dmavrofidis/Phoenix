$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$git = Get-Command git -ErrorAction Stop
$tracked = & $git.Source -C $repoRoot ls-files
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to enumerate tracked repository files.'
}

$forbidden = $tracked | Where-Object {
    $_ -match '(^|/)(key\.properties|\.env)$' -or
    $_ -match '\.(jks|keystore|p12|mobileprovision|cer)$' -or
    $_ -match '(^|/)AuthKey_[^/]+\.p8$' -or
    ($_ -match '(^|/)build/' -and $_ -ne 'hosting/phoenix-pwa/build/sites-vite-plugin.ts')
}
if ($forbidden) {
    throw "Sensitive or generated files are tracked:`n$($forbidden -join "`n")"
}

$manifest = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'mobile/android/app/src/main/AndroidManifest.xml')
if ($manifest -notmatch 'android:allowBackup="false"') {
    throw 'Android cloud backup must remain disabled.'
}
if ($manifest -notmatch 'android:usesCleartextTraffic="false"') {
    throw 'Android cleartext traffic must remain disabled.'
}

$releaseGradle = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'mobile/android/app/build.gradle.kts')
if ($releaseGradle -match 'signingConfigs\.getByName\("debug"\)') {
    throw 'Production release configuration must never fall back to debug signing.'
}

$iosProject = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'mobile/ios/Runner.xcodeproj/project.pbxproj')
if ($iosProject -match 'com\.example\.') {
    throw 'The iOS bundle identifier must never use a placeholder domain.'
}
if ($iosProject -notmatch 'PRODUCT_BUNDLE_IDENTIFIER = com\.phoenix\.fitness;') {
    throw 'The Phoenix iOS bundle identifier is missing.'
}

$iosInfo = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'mobile/ios/Runner/Info.plist')
if ($iosInfo -notmatch '<string>Phoenix</string>') {
    throw 'The iOS display name must remain Phoenix.'
}

$privacyManifest = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'mobile/ios/Runner/PrivacyInfo.xcprivacy')
if ($privacyManifest -match '<key>NSPrivacyTracking</key>\s*<true/>') {
    throw 'Phoenix must never enable iOS tracking.'
}

Write-Host 'Repository safety checks passed: no tracked secrets/builds, Android safeguards enforced, iOS identity fixed and tracking disabled.'
