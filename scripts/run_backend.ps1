$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$backendDir = Join-Path $repoRoot "backend_fastapi"

if (-not (Test-Path $backendDir)) {
  throw "Backend folder not found: $backendDir"
}

& (Join-Path $PSScriptRoot "check_prereqs.ps1") -Quiet -CheckPython 1 -CheckFlutter 0

Push-Location $backendDir
try {
  if (-not (Test-Path ".venv")) {
    py -m venv .venv
  }

  .\.venv\Scripts\Activate.ps1
  python -m pip install --upgrade pip
  pip install -r requirements.txt

  # FastAPI app entrypoint: backend_fastapi/app/main.py -> app.main:app
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
} finally {
  Pop-Location
}

