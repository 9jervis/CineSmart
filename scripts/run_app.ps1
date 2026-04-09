$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $repoRoot "cinesmart_app"

if (-not (Test-Path $appDir)) {
  throw "Flutter app folder not found: $appDir"
}

& (Join-Path $PSScriptRoot "check_prereqs.ps1") -Quiet -CheckPython 0 -CheckFlutter 1

Push-Location $appDir
try {
  flutter pub get
  flutter doctor
  flutter run
} finally {
  Pop-Location
}

