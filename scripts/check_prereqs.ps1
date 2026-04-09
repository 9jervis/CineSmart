param(
  [switch]$Quiet,
  [int]$CheckPython = 1,
  [int]$CheckFlutter = 1
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$msg) {
  if (-not $Quiet) { Write-Host $msg }
}

function Test-Command([string]$name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Require-Command([string]$name, [string]$hint) {
  if (-not (Test-Command $name)) {
    Write-Host ""
    Write-Host "Missing prerequisite: '$name' not found in PATH." -ForegroundColor Red
    Write-Host $hint
    throw "Missing prerequisite: $name"
  }
}

Write-Info "Checking prerequisites..."

$doPython = ($CheckPython -ne 0)
$doFlutter = ($CheckFlutter -ne 0)

if ($doPython) {
  # Python (backend)
  if (Test-Command "py") {
    Write-Info ("- Python launcher: OK (" + (& py -V 2>$null) + ")")
  } elseif (Test-Command "python") {
    Write-Info ("- Python: OK (" + (& python -V 2>$null) + ")")
  } else {
    Write-Host ""
    Write-Host "Missing prerequisite: Python not found." -ForegroundColor Red
    Write-Host "Install Python 3.11+ and ensure it's on PATH (or install the Python Launcher 'py')."
    throw "Missing prerequisite: python"
  }
}

if ($doFlutter) {
  # Flutter (frontend)
  if (Test-Command "flutter") {
    Write-Info ("- Flutter: OK (" + (& flutter --version | Select-Object -First 1) + ")")
  } else {
    Write-Host ""
    Write-Host "Missing prerequisite: Flutter not found in PATH." -ForegroundColor Red
    Write-Host "Fix:"
    Write-Host "1) Download Flutter SDK and extract (example: C:\src\flutter)"
    Write-Host "2) Add to User PATH: C:\src\flutter\bin"
    Write-Host "3) Close/reopen your terminal (or restart Cursor)"
    Write-Host ""
    Write-Host "Then verify with: flutter --version"
    throw "Missing prerequisite: flutter"
  }
}

Write-Info "All prerequisites look OK."

