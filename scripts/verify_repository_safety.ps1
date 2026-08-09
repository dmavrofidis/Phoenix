$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$git = Get-Command git -ErrorAction Stop
$tracked = & $git.Source -C $repoRoot ls-files
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to enumerate tracked repository files.'
}

$forbidden = $tracked | Where-Object {
    $_ -match '(^|/)(key\.properties|\.env)$' -or
    $_ -match '\.(jks|keystore)$' -or
    $_ -match '(^|/)build/'
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

Write-Host 'Repository safety checks passed: no tracked secrets/builds, backups disabled, cleartext disabled, release signing enforced.'
