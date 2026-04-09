# CineSmart (Flutter + FastAPI)

This repo contains:
- `cinesmart_app/` — Flutter mobile app
- `backend_fastapi/` — FastAPI backend (runs on port 8000)

## Prerequisites (Windows)

- Flutter SDK installed and `flutter` available in your PATH
- Python 3.11+ (recommended) with `py` launcher

## Run (recommended)

From repo root in PowerShell:

```powershell
.\scripts\dev.ps1
```

Or run them separately:

```powershell
.\scripts\run_backend.ps1
.\scripts\run_app.ps1
```

## Flutter not found?

If you see: `flutter : The term 'flutter' is not recognized...`

- Download Flutter SDK and extract (example: `C:\src\flutter`)
- Add to User PATH: `C:\src\flutter\bin`
- Restart your terminal (or restart Cursor)
- Verify: `flutter --version`

## API base URL note

The app uses `http://10.0.2.2:8000` (Android emulator -> host machine).
If you run on a real phone, set the base URL to your PC's LAN IP (example: `http://192.168.1.50:8000`).

