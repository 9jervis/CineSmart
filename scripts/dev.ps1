$ErrorActionPreference = "Stop"

Write-Host "Starting CineSmart (backend + app)." -ForegroundColor Cyan
Write-Host "Note: this will open the backend in a new window; keep it running."

$repoRoot = Split-Path -Parent $PSScriptRoot

# Require both for the combined dev script
& (Join-Path $repoRoot "scripts\check_prereqs.ps1")

# Start backend in a separate PowerShell window
Start-Process powershell -WorkingDirectory $repoRoot -ArgumentList @(
  "-NoExit",
  "-ExecutionPolicy", "Bypass",
  "-File", (Join-Path $repoRoot "scripts\run_backend.ps1")
)

# Run app in current window
& (Join-Path $repoRoot "scripts\run_app.ps1")

