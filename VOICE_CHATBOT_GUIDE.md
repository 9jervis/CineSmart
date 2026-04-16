# 🎬 CineSmart Voice-Enabled AI Chatbot Guide

## Overview

This guide covers the implementation of a voice-enabled AI chatbot assistant for the CineSmart movie booking application. The system features:

- **Voice-to-Text**: Real-time speech recognition
- **Text-to-Speech**: Bot responses spoken back to user
- **Smart Intent Detection**: Understands user intent for movie booking
- **Automatic Navigation**: Triggers app actions (seat booking, movie details, etc.)
- **Session Management**: Maintains conversation context

## System Architecture

### Backend (FastAPI)

**Endpoint**: `POST /chat`

**Request**:
```json
{
  "message": "Book Avatar 3 seats",
  "session_id": "abc123-def456"  // Optional, session tracking
}
```

**Response**:
```json
{
  "reply": "Opening seat selection page for 3 seats for Avatar.",
  "session_id": "abc123-def456",
  "action": "open_seat_page",
  "expecting": null,
  "data": {
    "movie_id": 1,
    "movie": "Avatar",
    "genre": "Sci-Fi",
    "rating": 8.5,
    "duration": 192,
    "image_url": "...",
    "seats": 3,
    "show_time": "07:15 PM",
    "subtitle": "AI Assistant booking flow"
  }
}
```

### Frontend (Flutter)

**Main Components**:
1. `ChatScreen` - Voice input, messaging UI, text-to-speech
2. `SeatSelectionScreen` - Auto-populated with chatbot parameters
3. `AppRoutes` - GetX routing with parameter passing

## Setup Instructions

### 1. Backend Setup

The backend is already implemented in `backend_fastapi/app/routes/chat.py`.

**Service files**:
- `app/services/voice_chat_service.py` - Intent detection logic
- `app/services/chat_session_store.py` - Session management

**Key features**:
- Intent extraction using regex patterns
- Movie matching from database
- Context-aware responses (awaiting_seat_count, awaiting_movie_for_details)
- Auto-navigation parameters

**To run the backend**:
```bash
cd backend_fastapi
source .venv/Scripts/Activate  # Windows: .venv\Scripts\Activate
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Frontend Setup

**Dependencies** (already in pubspec.yaml):
- `speech_to_text: ^7.3.0` - Voice input
- `flutter_tts: ^4.2.3` - Text-to-speech
- `permission_handler: ^12.0.1` - Runtime permissions
- `get: ^4.6.5` - Routing & state management

**Chat Screen Features**:
- `_toggleMic()` - Start/stop voice recording
- `_send()` - Send message & handle response
- `_handleAction()` - Execute chatbot actions
- `_openSeatBookingPage()` - Navigate to seat selection with data
- `_initializeTts()` - Configure text-to-speech

**To run the app**:
```powershell
# Android Emulator
flutter run -d emulator-5554

# iOS Simulator
flutter run -d "iPhone 14"

# Web
flutter run -d web-server
```

## User Interaction Flow

### Example: "Book Avatar 3 Seats"

```
User Voice Input (Mic):
  "Book Avatar three seats"
    ↓
Text Recognition:
  "book avatar three seats"
    ↓
Chatbot Processing:
  - Detects: "book" + "avatar" + "3 seats"
  - Finds: Movie "Avatar" in database
  - Extracts: seat_count = 3
    ↓
Chatbot Response:
  {
    "reply": "Opening seat selection page for 3 seats for Avatar",
    "action": "open_seat_page",
    "data": {
      "movie_id": 1,
      "movie": "Avatar",
      "seats": 3,
      ...
    }
  }
    ↓
Chat Screen Actions:
  1. Displays reply message
  2. Speaks reply (if TTS enabled)
  3. Detects action = "open_seat_page"
  4. Extracts parameters from data
    ↓
Navigation:
  Get.toNamed('/seat-booking', arguments: {
    'itemId': 1,
    'itemTitle': 'Avatar',
    'itemSubtitle': 'AI Assistant booking',
    'initialShowTime': '07:15 PM',
    'requestedSeats': 3
  })
    ↓
Seat Selection Screen:
  - Pre-fills: 3 seats requested
  - Shows: Movie "Avatar" details
  - Allows: User to select 3 specific seats
  - Confirms: Booking with selected seats
```

## Intent Detective - Supported Commands

### 1. Show Movies
```
User: "Show movies" / "List movies" / "What movies are playing?"
Response: Lists available movies
```

### 2. Movie Details
```
User: "Tell me about Avatar" / "Movie details for Avatar"
Response: Opens movie details screen
```

### 3. Show Timings
```
User: "What times for Avatar?" / "Show timings"
Response: Lists available show times
```

### 4. Book Movie (Multi-step)
```
Step 1:
User: "Book Avatar"
Bot: "How many seats would you like to book for Avatar?"
State: awaiting_seat_count

Step 2:
User: "3 seats"
Bot: "Opening seat selection page for 3 seats for Avatar"
Action: open_seat_page
```

### 5. Book with Everything
```
User: "Book 3 seats for Avatar at 7:15 PM"
Bot: "Opening seat selection page for 3 seats for Avatar"
Action: open_seat_page (immediate)
```

## Configuration

### Voice Recognition Settings
```dart
// In ChatScreen._toggleMic()
await _speech.listen(
  onResult: (res) { ... },
  listenMode: stt.ListenMode.dictation,  // Continuous recognition
  partialResults: true,  // Show intermediate results
);
```

### Text-to-Speech Settings
```dart
// In ChatScreen._initializeTts()
await _tts.setLanguage('en-US');
await _tts.setSpeechRate(0.8);  // 0.5 - 1.0 (slower to normal)
await _tts.setPitch(1.0);  // 0.5 - 2.0
```

### Backend Configuration
```python
# In app\services\voice_chat_service.py
SHOW_TIMES = [
    "10:15 AM",
    "01:30 PM", 
    "04:00 PM",
    "07:15 PM",
    "10:30 PM",
]

# Seat limits
_extract_seat_count():  # Returns 1-10 only
```

## Testing Guide

### Prerequisites
- ✅ Backend running on `http://localhost:8000` (or `http://10.0.2.2:8000` for Android)
- ✅ Movies seeded in database
- ✅ Microphone permission granted
- ✅ Flutter app running on device/emulator

### Test Case 1: Voice Input → Chat Message
1. Launch app, navigate to Chat screen
2. Click 🎤 mic icon
3. Speak: "Show movies"
4. App should display voice text in input field
5. Press Send or wait for auto-send
6. Bot responds with movie list

**Expected**: Text appears in input, send triggers response

### Test Case 2: Action Trigger → Navigation
1. Chat screen active
2. Speak: "Book Avatar"
3. App should show: "How many seats would you like to book for Avatar?"
4. Speak: "3 seats"
5. **ACTION**: App automatically navigates to Seat Selection screen

**Expected**: Seat screen opens with:
- Movie title: "Avatar"
- Requested seats: 3
- Show time: "07:15 PM"

### Test Case 3: Voice Response (TTS)
1. Chat screen active
2. Enable TTS toggle (🔊)
3. Send any message
4. Bot should:
   - Display text response
   - **Speak** the response audibly

**Expected**: Hear bot voice speaking the reply

### Test Case 4: Multi-step Conversation
1. Send: "Book Avatar 3 seats at 7:15 PM"
2. Bot should immediately say: "Opening seat selection page..."
3. Navigate to Seat screen
4. Select 3 seats manually
5. Confirm booking

**Expected**: All steps complete without re-prompting for seat count

### Test Case 5: Session Context
1. Send: "Book Avatar"
2. Bot: "How many seats?" (awaiting_seat_count state)
3. Send: "Actually, show me movies first"
4. Bot: "Here are some movies..."
5. Send: "Okay, book Avatar for 3 seats"
6. Bot: Opens seat page for 3 seats (remembers movie context)

**Expected**: Bot maintains context across messages

### Test Case 6: Error Handling
1. Stop backend server
2. Send message from chat
3. App should show: "Sorry, I couldn't reach the server..."

**Expected**: Graceful error message displayed

### Test Case 7: Text Input Alternative
1. Disable microphone or skip voice
2. Type: "Book Avengers 2 tickets"
3. Press Send
4. Bot should respond: "Opening seat selection page for 2 seats for Avengers"

**Expected**: Text input works identically to voice

## API Endpoints

### Chat Endpoint
```
POST /chat
Content-Type: application/json

Request:
{
  "message": "Book Avatar",
  "session_id": "optional-session-id"
}

Response:
{
  "reply": "How many seats would you like to book for Avatar?",
  "session_id": "session-id-123",
  "action": null,
  "expecting": "seat_count",
  "data": {}
}
```

### Related Endpoints Used
- `GET /movies` - List all movies
- `GET /movies/{id}/booked-seats` - Get booked seats for a movie
- `POST /bookings` - Create a booking
- `GET /movies/search?query=...` - Search movies

## Troubleshooting

### Issue: Microphone not working
**Solution**:
- Check `AndroidManifest.xml` has `RECORD_AUDIO` permission
- Grant microphone permission when prompted
- Test with text input first

### Issue: Speech recognition gives wrong results
**Solution**:
- Speak clearly and slowly
- Bot uses fuzzy matching, so close results still work
- Check bot logs for matched movie/intent

### Issue: Navigation doesn't happen after action
**Solution**:
- Ensure GetX routes are registered in `app_routes.dart`
- Check action string in bot response (e.g., "open_seat_page")
- Verify parameters are passed correctly in `_handleAction()`

### Issue: TTS not speaking
**Solution**:
- Enable TTS toggle in chat screen
- Check device volume is not muted
- Ensure `_initializeTts()` completes without errors
- Test with `await _tts.speak("Test")`

### Issue: Session ID not persisting
**Solution**:
- Backend stores session for 24 hours by default
- Check `chat_session_store.py` TTL settings
- Verify session_id included in requests

### Issue: Movie not found
**Solution**:
- Check movies are seeded: `python backend_fastapi/seed_movies.py`
- Use voice to speak exact movie title
- Try text input with variations: "Avatar", "AVATAR", "avatar"
- Bot does fuzzy matching on keywords

## Code Examples

### Extending with New Action
```dart
// In ChatScreen._handleAction()
case 'open_custom_page':
  _openCustomPage(data);
  break;

void _openCustomPage(Map<String, dynamic> data) {
  Get.toNamed('/custom-page', arguments: data);
}
```

### Adding New Intent Detection
```python
# In app/services/voice_chat_service.py
def get_chat_result(db, message, session):
    text = _normalize_text(message)
    
    # Add new intent
    if any(phrase in text for phrase in ["custom intent", "keyword"]):
        return {
            "reply": "Custom response",
            "action": "custom_action",
            "data": {...}
        }
```

### Custom Session Data
```python
# Store custom data in session
session["custom_field"] = "value"
store.set_state(session_id, **session)

# Retrieve in next message
custom_value = session.get("custom_field")
```

## Performance Considerations

1. **Speech Recognition**: ~1-2 seconds per spoken phrase
2. **Bot Response**: ~500ms average (depends on DB queries)
3. **Navigation**: ~300ms (GetX routing speed)
4. **TTS**: ~1-2 seconds to speak (depends on response length)

**Total Flow Time**: ~4-6 seconds from voice → action triggered

## Security Notes

1. **Session IDs**: Generated server-side, opaque to client
2. **Movie Data**: Pre-populated from database, safe
3. **User Input**: Validated and sanitized before bot processing
4. **Permissions**: Microphone only granted when needed (Android 6+)

## Future Enhancements

1. ✨ **Multi-language support**: Spanish, Hindi, Tamil, etc.
2. ✨ **Personalized recommendations**: "Show me sci-fi movies"
3. ✨ **Payment integration**: "Complete payment with voice confirmation"
4. ✨ **Booking history**: "Show my past bookings"
5. ✨ **Emotion detection**: Adjust bot tone based on user sentiment
6. ✨ **Offline mode**: Cache movies & use on-device TTS
7. ✨ **Voice commands**: Custom voice shortcuts (e.g., "Hey CineSmart, top movies")

## Key Files

```
frontend:
  lib/
    screens/chat/chat_screen.dart           # Main chat UI & voice logic
    screens/booking/seat_selection_screen.dart  # Seat booking with params
    routes/app_routes.dart                  # GetX routing
    services/api_service.dart               # API calls
    models/chat_response_model.dart         # Response model
    models/chat_message.dart                # Message model

backend:
  app/
    routes/chat.py                          # Chat endpoint
    services/voice_chat_service.py          # Intent detection
    services/chat_session_store.py          # Session management
    schemas/chat_schema.py                  # Request/response schemas
```

## Support & Debugging

**Enable Debug Logging**:
```dart
// In ChatScreen
debugPrint('Message: $text');
debugPrint('Action: ${response.action}');
debugPrint('Data: ${response.data}');
```

**Backend Logs**:
```bash
# Check FastAPI server output for error details
# Look for "Chatbot intent detection" logs
```

**Test API Directly**:
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Book Avatar"}'
```

---

**Created**: 2026-04-13  
**Status**: ✅ Complete  
**Last Updated**: Version 1.0
