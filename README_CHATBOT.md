# Voice-Enabled AI Movie Booking Chatbot

## Quick Start

This document describes the voice-enabled AI chatbot implementation for CineSmart.

### What's Included

✅ **Flutter Frontend**
- Chat UI with message bubbles
- Speech-to-text voice input
- Text-to-speech audio responses
- Real-time recognized text display
- Automatic navigation based on bot actions
- State management with GetX

✅ **FastAPI Backend**
- Intent detection with rule-based NLP
- Movie booking logic
- Structured response format with actions
- Available movies API endpoint
- Context-aware conversation

✅ **Smart Features**
- Multi-step booking flow (book movie → select seats → confirm)
- Automatic screen navigation (e.g., seat selection page)
- Voice feedback for all bot responses
- Context memory across conversation
- Error handling and fallbacks

## File Structure

```
cinesmart_app/
├── lib/
│   ├── models/
│   │   └── chat_model.dart           # Chat data models
│   ├── services/
│   │   ├── chat_service.dart         # API communication
│   │   └── voice_service.dart        # Voice I/O handling
│   ├── controllers/
│   │   └── chat_controller.dart      # Chat logic & state
│   ├── screens/
│   │   ├── chat/
│   │   │   └── chat_screen.dart      # Chat UI
│   │   └── booking/
│   │       └── seat_selection_screen.dart  # Seat selection UI
│   └── routes/
│       └── app_routes.dart           # Navigation setup
│
backend_fastapi/
└── app/
    ├── schemas/
    │   └── chat.py                   # Request/response models
    ├── services/
    │   └── chatbot_service.py        # Intent detection & logic
    ├── routes/
    │   └── chat.py                   # Chat API endpoints
    └── main.py                       # FastAPI app setup
```

## Features

### 1. Voice Input

```dart
// User clicks mic button
_controller.startVoiceInput();

// Says: "Book 3 seats for Avatar"
// Text is recognized and displayed
// User confirms or continues
```

### 2. Voice Output

```dart
// Bot speaks response
voiceService.speak(response.reply);

// "Perfect! Opening seat selection for 3 seats for Avatar."
// Audio plays automatically
```

### 3. Smart Navigation

```python
# Backend response
{
    "reply": "Opening seat selection...",
    "action": "open_seat_page",
    "data": {
        "movie": "Avatar",
        "seats": 3
    }
}

# Frontend automatically navigates
Get.toNamed('/seat-booking', arguments: {
    'movie': 'Avatar',
    'seats': 3
});
```

### 4. Booking Flow

```
User: "Book Avatar"
  ↓
Bot: "How many seats?"
  ↓
User: "3 seats"
  ↓
Bot: "Opening seat selection..." → Navigate to seat page
  ↓
User: Selects 3 seats
  ↓
Bot: Confirms booking
```

## Installation & Setup

See detailed instructions in [CHATBOT_SETUP.md](CHATBOT_SETUP.md)

## API Examples

### Example 1: Direct Booking

```bash
curl -X POST http://localhost:8000/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Book 3 seats for Avatar",
    "movie_context": null,
    "booking_context": {}
  }'
```

Response:
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

### Example 2: Step-by-Step Booking

**Step 1:**
```bash
curl -X POST http://localhost:8000/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{"message": "I want to book Inception"}'
```

Response:
```json
{
  "reply": "Great! You want to book Inception. How many seats would you like to book?",
  "action": "none",
  "data": null,
  "context_update": {
    "current_movie": "Inception"
  }
}
```

**Step 2:**
```bash
curl -X POST http://localhost:8000/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "2 seats",
    "booking_context": {"current_movie": "Inception"}
  }'
```

Response:
```json
{
  "reply": "Perfect! Opening seat selection for 2 seats for Inception.",
  "action": "open_seat_page",
  "data": {
    "movie": "Inception",
    "seats": 2
  },
  "context_update": {
    "current_movie": "Inception",
    "selected_seats": 2
  }
}
```

## Testing

### Run Backend Tests

```bash
cd backend_fastapi
python test_chatbot_api.py
```

This runs:
- Get available movies
- Book with all details
- Multi-step booking
- Movie browsing
- Confirmations
- Edge cases

### Manual UI Testing

1. **Test Voice Input**:
   - Click the microphone button
   - Say "Book Avatar"
   - Verify text appears

2. **Test Voice Output**:
   - Listen for bot response
   - Verify audio plays

3. **Test Navigation**:
   - Say "Book 3 seats for Avatar"
   - Verify seat selection screen opens
   - Verify movie and seat count are passed

4. **Test Seat Selection**:
   - Select 3 seats
   - Verify "Confirm" button enables
   - Verify feedback on seat selection

## Conversation Examples

### Example 1: Voice Booking

```
User: *speaks* "Book Avatar"
Recognized: "Book Avatar"
Bot: "Great! You want to book Avatar. How many seats would you like?"

User: *speaks* "Three"
Recognized: "Three"
Bot: "Perfect! Opening seat selection for 3 seats for Avatar."
[App navigates to seat selection screen]
```

### Example 2: Text Booking

```
User: *types* "Book 2 tickets for The Matrix"
Bot: "Perfect! Opening seat selection for 2 seats for The Matrix."
[App navigates to seat selection screen]
```

### Example 3: Browse Movies

```
User: *speaks* "What movies do you have?"
Recognized: "What movies do you have?"
Bot: "Here are some popular movies available: Avatar, Avengers, Inception, The Matrix, Dune"
[Optional: App opens movie list]
```

### Example 4: Complex Request

```
User: *speaks* "I need 5 seats for Dune"
Recognized: "I need 5 seats for Dune"
Bot: "Perfect! Opening seat selection for 5 seats for Dune."
[App navigates with 5 seats pre-selected for Dune]
```

## Customization

### Adding New Intents

**In `backend_fastapi/app/services/chatbot_service.py`:**

```python
def _detect_intent(self, message: str, context):
    # Add new keyword check
    if self._contains_cancel_keywords(message):
        return "cancel_booking", {}
    
    # ...

def _contains_cancel_keywords(self, message: str) -> bool:
    keywords = ["cancel", "abort", "stop", "nevermind"]
    return any(keyword in message for keyword in keywords)

def _generate_response(self, intent, intent_data, message):
    # Add new response
    if intent == "cancel_booking":
        return ChatResponse(
            reply="Your booking has been cancelled. How else can I help?",
            action=ChatAction.NONE,
            context_update={},
        )
```

### Adding New Movies

**In `backend_fastapi/app/services/chatbot_service.py`:**

```python
AVAILABLE_MOVIES = [
    "Avatar",
    "Avengers",
    "Your New Movie",  # ← Add here
]
```

## Troubleshooting

### Voice Not Working

1. Check microphone permissions (Settings > Apps > CineSmart > Permissions)
2. Test with device's native voice app
3. Check internet connection
4. Try restarting the app

### Bot Not Responding

1. Verify backend is running: `curl http://localhost:8000/api/chat/movies`
2. Check Firebase/backend logs
3. Verify correct API URL in `ChatService`
4. Test with simple text first

### Navigation Not Triggering

1. Check boat action is not `none`
2. Verify route is registered in `GetX`
3. Check for error logs
4. Test with direct button navigation

## Performance Tips

1. **Cache movies** on app startup
2. **Use partial results** for faster STT feedback
3. **Limit message history** to recent 50 messages
4. **Batch API calls** when possible
5. **Use connection pooling** in FastAPI

## Future Enhancements

- [ ] ML-based NLP (replace rule-based)
- [ ] Multi-language support
- [ ] User preference learning
- [ ] Booking history tracking
- [ ] Payment integration
- [ ] Real booking confirmation
- [ ] Email/SMS notifications
- [ ] Emotion detection
- [ ] Contexual responses
- [ ] OAuth integration

## Support

For issues:
1. Check [CHATBOT_SETUP.md](CHATBOT_SETUP.md) for detailed setup
2. Run test suite: `python backend_fastapi/test_chatbot_api.py`
3. Check logs for errors
4. Try manual testing with simple messages
