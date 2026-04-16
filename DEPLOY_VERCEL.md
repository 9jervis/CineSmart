# Deploy CineSmart On Vercel

This project should be deployed as **two Vercel projects**:
1. Backend API (FastAPI)
2. Frontend (Flutter Web)

## 1) Deploy Backend (FastAPI)

Use folder: `backend_fastapi`

### Vercel Dashboard
- Add New Project
- Import this repo
- Set **Root Directory** to `backend_fastapi`
- Framework Preset: `Other`
- Build Command: leave empty
- Output Directory: leave empty
- Deploy

This uses:
- `backend_fastapi/api/index.py`
- `backend_fastapi/vercel.json`

After deploy, copy backend URL, for example:
- `https://cinesmart-api.vercel.app`

Test endpoint:
- `https://cinesmart-api.vercel.app/docs`

## 2) Deploy Frontend (Flutter Web)

Use folder: `cinesmart_app`

### Vercel Dashboard
- Add New Project
- Import this repo again
- Set **Root Directory** to `cinesmart_app`
- Framework Preset: `Other`
- Build Command:

```bash
git clone https://github.com/flutter/flutter.git --depth 1 -b stable ../flutter-sdk && ../flutter-sdk/bin/flutter config --enable-web && ../flutter-sdk/bin/flutter pub get && ../flutter-sdk/bin/flutter build web --release --dart-define=API_BASE_URL=https://YOUR-BACKEND-URL
```

- Output Directory: `build/web`
- Install Command: leave empty
- Deploy

Replace `https://YOUR-BACKEND-URL` with your backend Vercel URL from step 1.

This frontend deploy uses:
- `cinesmart_app/vercel.json` (SPA rewrite)

## 3) Redeploy Frontend On Backend URL Change

If backend URL changes, redeploy frontend with updated:
- `--dart-define=API_BASE_URL=...`

## 4) Important Production Notes

- Current backend uses SQLite (`cinesmart.db`).
- Vercel serverless filesystem is ephemeral, so DB writes are not persistent across function instances.
- For production bookings/auth data, move to hosted DB (Neon, Supabase Postgres, PlanetScale, etc.) and update SQLAlchemy config.

## 5) Optional CLI Deploy

If using Vercel CLI:

```bash
npm i -g vercel
```

Backend:

```bash
cd backend_fastapi
vercel
vercel --prod
```

Frontend:

```bash
cd cinesmart_app
vercel
vercel --prod
```
