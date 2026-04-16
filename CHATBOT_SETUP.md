# Voice-Enabled AI Chatbot Setup Guide

## Overview
This guide walks you through setting up the voice-enabled AI chatbot assistant for the CineSmart movie booking application.

## Architecture

### Backend (FastAPI)
- **Endpoint**: `POST /api/chat/message`
- **Intent Detection**: Rule-based NLP for extracting movie names and seat counts
- **Actions**: Structured responses with navigation commands

### Frontend (Flutter)
- **Voice Input**: Speech-to-text integration using `speech_to_text` package
- **Voice Output**: Text-to-speech for bot responses using `flutter_tts`
- **Chat UI**: Message bubbles with real-time updates
- **Navigation**: Automatic screen transitions based on bot actions

## Installation

### 1. Backend Setup

```bash
cd backend_fastapi
python -m venv .venv
.venv\Scripts\activate  # On Windows

# Install dependencies
pip install -r requirements.txt
```

### 2. Flutter Setup

```bash
cd cinesmart_app
flutter pub get
```

### 3. Update pubspec.yaml Dependencies

The following packages are required:

```yaml
dependencies:
  speech_to_text: ^6.1.1  # Speech recognition
  flutter_tts: ^0.14.1    # Text-to-speech
  get: ^4.6.5             # State management
  http: ^1.1.0            # HTTP requests
  uuid: ^4.0.0            # Unique IDs
  permission_handler: ^11.4.4  # Runtime permissions
```

## Running the Application

### Start Backend

```bash
cd backend_fastapi
.venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`

### Start Flutter App

```bash
cd cinesmart_app
flutter run
```

## API Endpoints

### 1. Chat Message Endpoint

**POST** `/api/chat/message`

**Request:**
```json
{
  "message": "Book 3 seats for Avatar",
  "movie_context": null,
  "booking_context": {}
}
```

**Response:**
```json
{
  "reply": "Perfect! Opening seat selection for 3 seats for Avatar.",
  "action": "open_seat_page",
  "data": {
    "movie": "Avatar",
    "seats": 3,
    "show_id": null,
    "additional_info": null
  },
  "context_update": {
    "current_movie": "Avatar",
    "selected_seats": 3
  }
}
```

### 2. Get Available Movies

**GET** `/api/chat/movies`

**Response:**
```json
{
  "movies": [
    "Avatar",
    "Avengers",
    "Inception",
    "The Matrix",
    "Dune",
    "Interstellar",
    "The Dark Knight",
    "Pulp Fiction"
  ],
  "total": 8
}
```

## Example Conversations

### Example 1: Direct Booking

**User:** "Book 3 seats for Avatar"

**Bot Response:**
```
Reply: "Perfect! Opening seat selection for 3 seats for Avatar."
Action: open_seat_page
Data: movie=Avatar, seats=3
```

**Result:** App navigates to seat selection screen with movie and seat count pre-filled.

### Example 2: Multi-step Booking

**User:** "I want to book Avatar"

**Bot Response:**
```
Reply: "Great! You want to book Avatar. How many seats would you like to book?"
Action: none
Context: current_movie=Avatar
```

**User:** "3 seats"

**Bot Response:**
```
Reply: "Perfect! Opening seat selection for 3 seats for Avatar."
Action: open_seat_page
Data: movie=Avatar, seats=3
```

### Example 3: Browse Movies

**User:** "Show me movies"

**Bot Response:**
```
Reply: "Here are some popular movies available: Avatar, Avengers, Inception, The Matrix, Dune"
Action: open_movie_list
Data: null
```

## Intent Detection Logic

The chatbot uses rule-based intent detection:

### Detected Intents

1. **book_with_details**: "Book 3 seats for Avatar"
   - Triggers: Book keywords + Movie name + Seat count
   - Action: open_seat_page

2. **book_movie**: "Book Avatar"
   - Triggers: Book keywords + Movie name (no seat count)
   - Action: none (asks for seat count)

3. **confirm_seats**: "3 seats"
   - Triggers: Seat keywords + Seat count (no movie)
   - Action: none (asks for movie)

4. **show_movies**: "Show me movies" or "What movies are available"
   - Triggers: Show keywords (no movie name)
   - Action: open_movie_list

5. **show_movie_details**: "Show Avatar" or "Tell me about Inception"
   - Triggers: Show keywords + Movie name
   - Action: open_movie_details

6. **confirm**: "Yes" or "Confirm"
   - Triggers: Confirmation keywords
   - Action: confirm_booking

## Voice Features

### Speech-to-Text

- **Language**: English (en_US)
- **Timeout**: 30 seconds of listening
- **Partial Results**: Enabled for real-time feedback
- **Auto-stop**: After 5 seconds of silence

### Text-to-Speech

- **Language**: English (en-US)
- **Speech Rate**: 0.5x (normal)
- **Volume**: 1.0 (max)
- **Pitch**: 1.0 (normal)

## Navigation Actions

The chatbot can trigger these screen navigations:

1. **open_seat_page**: Navigate to seat selection with movie and seat count
   ```dart
   Get.toNamed('/seat-booking', arguments: {
     'movie': 'Avatar',
     'seats': 3,
     'showId': null,
   });
   ```

2. **open_movie_list**: Navigate to movies listing page
   ```dart
   Get.toNamed('/movies');
   ```

3. **open_movie_details**: Navigate to specific movie details
   ```dart
   Get.toNamed('/movie-details', arguments: {'movie': 'Avatar'});
   ```

4. **confirm_booking**: Show booking confirmation
   ```dart
   Get.snackbar('Booking Confirmed', 'Your booking has been confirmed!');
   ```

## Permissions Required (Android)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- For TTS -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Permissions Required (iOS)

Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs network access for API calls</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice commands</string>
```

## Testing

### Unit Tests for Intent Detection

Create `test/chatbot_service_test.py` in backend:

```python
import pytest
from app.services.chatbot_service import ChatbotService

@pytest.fixture
def service():
    return ChatbotService()

def test_detect_book_with_details(service):
    intent, data = service._detect_intent("book 3 seats for avatar")
    assert intent == "book_with_details"
    assert data['movie'] == 'Avatar'
    assert data['seats'] == 3

def test_detect_show_movies(service):
    intent, data = service._detect_intent("show me movies")
    assert intent == "show_movies"
```

### Manual Testing

1. **Test Voice Input**:
   - Click mic button
   - Say "Book Avatar"
   - Verify text is recognized
   - Verify bot asks for seat count

2. **Test Voice Output**:
   - Listen to bot responses
   - Verify speech is clear and audible

3. **Test Navigation**:
   - Say "Book 3 seats for Avatar"
   - Verify seat selection screen opens
   - Verify movie name is displayed
   - Verify seat count is pre-filled

4. **Test Context Update**:
   - Say "Book Avatar"
   - Say "3 seats"
   - Verify bot remembers the movie context
   - Say "Show Avatar"
   - Verify bot opens movie details or seat page

## Troubleshooting

### Voice Recognition Not Working

1. Check permissions are granted (Settings > Apps > CineSmart)
2. Test with Google Speech Recognition app
3. Ensure internet connection (required for cloud-based STT)
4. Check device language is set to English

### TTS Not Playing

1. Check volume is not muted
2. Check system volume is high
3. Check TTS engine is installed (Android: Settings > Text-to-speech > Install data)
4. Test with system TTS settings

### API Connection Issues

1. Verify backend is running: `curl http://localhost:8000/api/chat/movies`
2. Check firewall allows local connections
3. Verify correct IP/port in ChatService constants
4. On Android emulator, use `10.0.2.2` instead of `localhost`

### Intent Detection Issues

1. Check chatbot logs for recognized text
2. Add new intent patterns in `chatbot_service.py`
3. Update keyword lists in helper methods
4. Test with simplified messages first

## Extending the Chatbot

### Adding New Intents

1. Add intent type to `ChatAction` enum
2. Add intent detection logic to `_detect_intent()`
3. Add response generation to `_generate_response()`
4. Add navigation handler in `_handleChatAction()`

### Adding New Movies

Update `AVAILABLE_MOVIES` list in `chatbot_service.py`:

```python
AVAILABLE_MOVIES = [
    "Avatar",
    "Avengers",
    "Your New Movie",
]
```

### Improving NLP

1. Add more keyword patterns to helper methods
2. Implement fuzzy string matching for movie names
3. Use regex for more complex patterns
4. Consider integrating NLTK or spaCy for better NLP

## Performance Optimization

1. **Reduce API latency**:
   - Cache available movies on app startup
   - Use connection pooling in FastAPI

2. **Improve voice recognition**:
   - Add offline speech recognition
   - Implement audio preprocessing
   - Use device-specific models

3. **Optimize chat UI**:
   - Virtualize message list for large conversations
   - Implement pagination for old messages

## Future Enhancements

1. **Advanced NLP**: Replace rule-based with ML-based intent detection
2. **User Preferences**: Remember user preferences and past bookings
3. **Multi-language Support**: Support multiple languages
4. **Emotion Detection**: Analyze user sentiment
5. **Context Memory**: Remember entire conversation history
6. **Integration with Payment**: Process payments via chatbot
7. **Booking Confirmation**: Send confirmation emails/SMS

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review API response logs
3. Test with simplified examples
4. Check GitHub issues for similar problems
