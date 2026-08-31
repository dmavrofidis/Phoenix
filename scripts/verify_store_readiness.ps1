$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$errors = [System.Collections.Generic.List[string]]::new()

function Require-Match {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Pattern,
        [Parameter(Mandatory)] [string] $Message
    )

    $content = Get-Content -Raw -LiteralPath $Path
    if ($content -notmatch $Pattern) {
        $errors.Add($Message)
    }
}

function Get-PngInfo {
    param([Parameter(Mandatory)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        $errors.Add("Missing store image: $Path")
        return $null
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $signature = @(137, 80, 78, 71, 13, 10, 26, 10)
    if ($bytes.Length -lt 26) {
        $errors.Add("Invalid PNG file: $Path")
        return $null
    }
    for ($index = 0; $index -lt $signature.Count; $index++) {
        if ($bytes[$index] -ne $signature[$index]) {
            $errors.Add("Invalid PNG signature: $Path")
            return $null
        }
    }

    $width = ([int]$bytes[16] -shl 24) -bor
        ([int]$bytes[17] -shl 16) -bor
        ([int]$bytes[18] -shl 8) -bor
        [int]$bytes[19]
    $height = ([int]$bytes[20] -shl 24) -bor
        ([int]$bytes[21] -shl 16) -bor
        ([int]$bytes[22] -shl 8) -bor
        [int]$bytes[23]

    [pscustomobject]@{
        Width = $width
        Height = $height
        ColorType = [int]$bytes[25]
    }
}

$pubspec = Join-Path $repoRoot 'mobile/pubspec.yaml'
$pubspecContent = Get-Content -Raw -LiteralPath $pubspec
$versionMatch = [regex]::Match(
    $pubspecContent,
    '(?m)^version:\s*(?<name>\d+\.\d+\.\d+)\+(?<build>\d+)\s*$'
)
if (-not $versionMatch.Success) {
    $errors.Add('mobile/pubspec.yaml must contain a semantic version and positive build number.')
}

$androidGradle = Join-Path $repoRoot 'mobile/android/app/build.gradle.kts'
Require-Match $androidGradle 'namespace\s*=\s*"com\.phoenix\.fitness"' 'Android namespace is not com.phoenix.fitness.'
Require-Match $androidGradle 'applicationId\s*=\s*"com\.phoenix\.fitness"' 'Android application ID is not com.phoenix.fitness.'
Require-Match $androidGradle 'compileSdk\s*=\s*36' 'Android compile SDK must remain API 36 for the 2026 release.'
Require-Match $androidGradle 'targetSdk\s*=\s*36' 'Android target SDK must remain API 36 for the 2026 Play submission.'
Require-Match $androidGradle 'minSdk\s*=\s*24' 'Android minimum SDK must remain explicit and supported.'

$androidManifest = Join-Path $repoRoot 'mobile/android/app/src/main/AndroidManifest.xml'
Require-Match $androidManifest 'android:allowBackup="false"' 'Android backup must remain disabled.'
Require-Match $androidManifest 'android:usesCleartextTraffic="false"' 'Android cleartext traffic must remain disabled.'
Require-Match $androidManifest 'android\.permission\.CAMERA' 'Android camera permission is missing.'

$iosProject = Join-Path $repoRoot 'mobile/ios/Runner.xcodeproj/project.pbxproj'
Require-Match $iosProject 'PRODUCT_BUNDLE_IDENTIFIER = com\.phoenix\.fitness;' 'The iOS bundle identifier is missing.'
Require-Match $iosProject 'IPHONEOS_DEPLOYMENT_TARGET = 13\.0;' 'The documented iOS 13 deployment target is missing.'

$iosInfo = Join-Path $repoRoot 'mobile/ios/Runner/Info.plist'
Require-Match $iosInfo '<key>NSCameraUsageDescription</key>' 'The iOS camera disclosure is missing.'
Require-Match $iosInfo '<key>NSPhotoLibraryUsageDescription</key>' 'The iOS photo-library disclosure is missing.'
Require-Match $iosInfo 'never uploaded by Phoenix' 'The iOS permission copy must explain the local-only boundary.'

$privacyManifest = Join-Path $repoRoot 'mobile/ios/Runner/PrivacyInfo.xcprivacy'
Require-Match $privacyManifest '<key>NSPrivacyTracking</key>\s*<false/>' 'The iOS privacy manifest must explicitly disable tracking.'
Require-Match $privacyManifest '<key>NSPrivacyCollectedDataTypes</key>\s*<array/>' 'The iOS privacy manifest must match the no-collection release.'

$privacyUrl = 'https://phoenix-fitness-local.d-mavrofidis.chatgpt.site/privacy'
$supportUrl = 'https://phoenix-fitness-local.d-mavrofidis.chatgpt.site/support'
$storeListing = Join-Path $repoRoot 'docs/STORE_LISTING_PACKAGE.md'
$experiencePage = Join-Path $repoRoot 'mobile/lib/src/experience_settings_page.dart'
Require-Match $storeListing ([regex]::Escape($privacyUrl)) 'The store listing is missing the public privacy-policy URL.'
Require-Match $storeListing ([regex]::Escape($supportUrl)) 'The store listing is missing the public support URL.'
Require-Match $experiencePage ([regex]::Escape($privacyUrl)) 'The app must expose the privacy policy from its settings.'
Require-Match $experiencePage ([regex]::Escape($supportUrl)) 'The app must expose support from its settings.'

$imageSpecs = @(
    @('docs/store-assets/icon/phoenix-store-icon-1024.png', 1024, 1024, $true),
    @('docs/store-assets/icon/phoenix-feature-graphic-1024x500.png', 1024, 500, $false),
    @('docs/store-assets/screenshots/final/01-today-1290x2796.png', 1290, 2796, $false),
    @('docs/store-assets/screenshots/final/02-weekly-plan-1290x2796.png', 1290, 2796, $false),
    @('docs/store-assets/screenshots/final/03-active-workout-1290x2796.png', 1290, 2796, $false),
    @('docs/store-assets/screenshots/final/04-nutrition-1290x2796.png', 1290, 2796, $false),
    @('docs/store-assets/screenshots/final/05-tools-1290x2796.png', 1290, 2796, $false)
)

foreach ($spec in $imageSpecs) {
    $path = Join-Path $repoRoot $spec[0]
    $info = Get-PngInfo $path
    if ($null -eq $info) {
        continue
    }
    if ($info.Width -ne $spec[1] -or $info.Height -ne $spec[2]) {
        $errors.Add("Unexpected dimensions for $($spec[0]): $($info.Width)x$($info.Height).")
    }
    if ($spec[3] -and $info.ColorType -in @(4, 6)) {
        $errors.Add('The 1024px store icon must not contain an alpha channel.')
    }
}

if ($errors.Count -gt 0) {
    throw "Store readiness checks failed:`n- $($errors -join "`n- ")"
}

$version = if ($versionMatch.Success) {
    "$($versionMatch.Groups['name'].Value) ($($versionMatch.Groups['build'].Value))"
} else {
    'unknown'
}
Write-Host "Store readiness checks passed for Phoenix ${version}: API 36, platform privacy, public links and seven visual assets verified."
