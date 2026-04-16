# 🚀 CineSmart Voice Chatbot - Quick Start Guide

## Prerequisites

- ✅ Python 3.9+ (Backend)
- ✅ Flutter 3.15+ (Frontend)
- ✅ Android SDK / iOS SDK / Web (for deployment)
- ✅ Git
- ✅ Visual Studio Code or Android Studio

---

## 1️⃣ Start Backend (FastAPI)

### Option A: Using Windows PowerShell Task (Recommended)

```powershell
cd c:\Projects\CineSmart-main
# Run the backend task from VS Code
# Terminal → Run Task → "CineSmart: Run Backend (FastAPI)"
```

### Option B: Manual Start

```bash
cd backend_fastapi

# Activate virtual environment
.venv\Scripts\Activate  # Windows
source .venv/bin/activate  # macOS/Linux

# Install dependencies (first time only)
pip install -r requirements.txt

# Seed the database with movies (first time)
python seed_movies.py

# Start the server
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected Output**:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

Navigate to: http://localhost:8000/docs (Swagger UI to test endpoints)

---

## 2️⃣ Start Frontend (Flutter)

### Option A: Using VS Code Task

```powershell
cd c:\Projects\CineSmart-main
# Terminal → Run Task → "CineSmart: Run App (Flutter)"
```

### Option B: Android Emulator

```bash
cd cinesmart_app

# List available devices
flutter devices

# Run on Android emulator
flutter run -d emulator-5554

# Or let Flutter auto-select a device
flutter run
```

### Option C: iOS Simulator

```bash
flutter run -d "iPhone 14"
```

### Option D: Web

```bash
flutter run -d web-server
# Opens at http://localhost:54323
```

---

## 3️⃣ Test Voice Features

### Test the Chatbot Flow:

1. **On Login Screen**:
   - Email: any valid email
   - Password: any password
   - Click Login

2. **After Login**:
   - Click on "Profile" or navigate to Chat screen
   - You should see the Chat Assistant screen

3. **Voice Input Test**:
   - Click the 🎤 mic button
   - Speak: "Show me movies"
   - App should recognize speech and send message
   - Bot responds with movie list

4. **Action Test**:
   - Speak: "Book Avatar for 3 seats"
   - Bot should say: "Opening seat selection page..."
   - App automatically navigates to seat selection
   - Seat screen should show:
     - Movie: "Avatar"
     - Requested seats: 3
     - Show time: 07:15 PM

5. **Text-to-Speech Test**:
   - Enable the TTS toggle (🔊)
   - Send any message
   - Bot's reply should be **spoken aloud**

---

## 4️⃣ Test via API

### Using Python Test Script:

```bash
# Automatic test suite
python test_chatbot_voice_api.py

# Interactive testing
python test_chatbot_voice_api.py --interactive
```

### Using cURL:

```bash
# Test 1: Show movies
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "show movies"}'

# Test 2: Book with action
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "book avatar 3 seats at 7:15 pm"}'

# Test 3: Multi-step with session
SESSION_ID=$(curl -s -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "book avatar"}' | jq -r '.session_id')

curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"3 seats\", \"session_id\": \"$SESSION_ID\"}"
```

### Using Swagger UI:

1. Open: http://localhost:8000/docs
2. Find `/chat` endpoint
3. Click "Try it out"
4. Enter message: `{"message": "Book Avatar 3 seats"}`
5. Click "Execute"
6. See response with action

---

## 5️⃣ Both Backend + Frontend (One Step)

### Using VS Code Task:

```powershell
cd c:\Projects\CineSmart-main
# Terminal → Run Task → "CineSmart: Run Both (Backend + App)"
```

This launches both services in parallel terminals.

---

## 📱 Android Emulator Networking

For Android emulator to reach backend on localhost:

- **Backend URL in code**: `http://10.0.2.2:8000`
- **Already configured** in `lib/services/api_service.dart`

If you get connection errors:
```dart
// Check this in api_service.dart
static const String baseUrl = 'http://10.0.2.2:8000'; // Android
// NOT: http://localhost:8000
```

---

## 🎯 Key Commands Reference

```bash
# Backend
cd backend_fastapi && python -m uvicorn app.main:app --reload

# Frontend
cd cinesmart_app && flutter run

# Test API
python test_chatbot_voice_api.py
python test_chatbot_voice_api.py --interactive

# Database
python backend_fastapi/seed_movies.py
```

---

## ✅ Verification Checklist

- [ ] Backend running on `http://localhost:8000`
- [ ] Swagger UI accessible at `/docs`
- [ ] Flutter app launches without errors
- [ ] Microphone permission requested and granted
- [ ] Voice input captures speech correctly
- [ ] Chat message sends to backend
- [ ] Bot response displays with reply text
- [ ] Seat page opens when action triggered
- [ ] TTS (text-to-speech) works (optional)

---

## 🚨 Troubleshooting

### Backend won't start
```bash
# Clear old processes
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 <PID>  # macOS/Linux
taskkill /PID <PID> /F  # Windows

# Try again
python -m uvicorn app.main:app --reload
```

### Flutter app crashes
```bash
# Clear cache
flutter clean
flutter pub get

# Rebuild
flutter run
```

### No microphone input
1. Check permissions: Settings → Apps → CineSmart → Permissions
2. Ensure microphone permission is **Allowed**
3. Test with text input first
4. Check `speech_to_text` logs in terminal

### Chat doesn't connect to backend
1. Verify backend is running: `http://localhost:8000`
2. Check Android emulator: Should use `http://10.0.2.2:8000`
3. Check firewall: Port 8000 should be open
4. Logs: Check console output for error details

### Movies not found
```bash
# Reseed database
cd backend_fastapi
python seed_movies.py

# Verify in Swagger UI
# GET /movies
```

---

## 📚 Documentation

- 📖 [Voice Chatbot Guide](VOICE_CHATBOT_GUIDE.md) - Detailed API & features
- 📖 [Backend Setup](README.md) - Backend configuration
- 📖 [Movie Management](MOVIE_MANAGEMENT.md) - Movie database management

---

## 🎬 Example Conversation

```
User: "Hi"
Bot: "Hi! Ask me about movies, show timings, or bookings."

User: "Show movies"
Bot: "Here are some movies you can book: Avatar, Avengers, Inception, ..."

User: "Book Avatar"
Bot: "How many seats would you like to book for Avatar?"

User: "Three seats"
Bot: "Opening seat selection page for 3 seats for Avatar."
[App navigates to Seat Selection Screen]

User: [Selects 3 Seats]
Bot: [Booking complete after user confirms]
```

---

## 🔐 Security Notes

- Backend CORS allows all origins (dev only, restrict in production)
- No authentication required for chat (add in production)
- Microphone only used with user permission
- Session IDs auto-generated and validated

---

## 🎉 You're All Set!

Start chatting with voice! 🎤

For detailed configuration and advanced usage, see [VOICE_CHATBOT_GUIDE.md](VOICE_CHATBOT_GUIDE.md).

---

**Need Help?**
- Check error messages in terminal
- Review backend logs
- Test API with Python script
- Check [VOICE_CHATBOT_GUIDE.md](VOICE_CHATBOT_GUIDE.md) for detailed troubleshooting
