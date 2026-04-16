# 👨‍💻 CineSmart Voice Chatbot - Developer's Extension Guide

## Overview

This guide helps developers extend the voice chatbot with new intents, actions, and capabilities. The system is designed to be modular and easy to extend.

---

## Architecture Overview

```
┌─────────────────┐
│   Flutter App   │ (Voice Input/Output)
└────────┬────────┘
         │ HTTP Request
         ▼
┌─────────────────────────────────────┐
│  FastAPI Backend (http://localhost) │
│  ├─ /chat endpoint                  │
│  └─ Intent Detection Service        │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────┐
│   Database      │
│   (Movies, etc) │
└─────────────────┘
```

---

## Adding New Intents

### Step 1: Understand Intent Detection

Intent detection happens in `app/services/voice_chat_service.py`:

```python
def get_chat_result(db: Session, message: str, session: Dict[str, Any]) -> Dict[str, Any]:
    text = _normalize_text(message)  # Lowercase, cleanup
    
    # Intent detection follows pattern:
    if any(phrase in text for phrase in ["keyword1", "keyword2"]):
        return {
            "reply": "Bot response",
            "action": "optional_action",
            "data": {...}
        }
```

### Step 2: Add New Intent

Example: Let's add a "Recommend movies" intent

```python
# In voice_chat_service.py, add to get_chat_result():

def get_chat_result(db: Session, message: str, session: Dict[str, Any]) -> Dict[str, Any]:
    text = _normalize_text(message)
    
    # ... existing code ...
    
    # NEW INTENT: Movie recommendations
    if any(phrase in text for phrase in ["recommend", "suggest", "what should i watch"]):
        return _get_recommendations(db, text, session)
    
    # ... rest of code ...

# Add helper function:
def _get_recommendations(db: Session, text: str, session: Dict[str, Any]) -> Dict[str, Any]:
    """Return personalized movie recommendations"""
    genre = _extract_genre_hint(text)  # Optional: extract genre preference
    
    # Get top-rated movies (you can add more logic here)
    movies = db.query(Movie).order_by(Movie.rating.desc()).limit(5).all()
    
    titles = ", ".join(movie.title for movie in movies)
    return {
        "reply": f"I'd recommend these movies: {titles}.",
        "action": "show_recommendations",
        "data": {
            "movies": [_movie_payload(m) for m in movies],
            "genre_filter": genre
        }
    }

def _extract_genre_hint(text: str) -> Optional[str]:
    """Extract genre preference from text"""
    genres = ["action", "comedy", "drama", "horror", "sci-fi"]
    for genre in genres:
        if genre in text:
            return genre
    return None
```

### Step 3: Test the Intent

```bash
# Using curl
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "recommend action movies"}'

# Expected response includes "action": "show_recommendations"
```

---

## Adding New Actions

Actions are handled in the Flutter app.

### Step 1: Define Action in Backend Response

```python
# In voice_chat_service.py
return {
    "reply": "Opening recommendations page...",
    "action": "show_recommendations",  # New action
    "data": {
        "movies": [...]
    }
}
```

### Step 2: Implement Action Handler

In `lib/screens/chat/chat_screen.dart`:

```dart
Future<void> _handleAction(String? action, Map<String, dynamic> data) async {
    if (action == null) return;

    switch (action) {
      case 'open_seat_page':
        _openSeatBookingPage(data);
        break;
      
      // NEW ACTION HANDLER
      case 'show_recommendations':
        _showRecommendations(data);
        break;
      
      default:
        debugPrint('Unknown action: $action');
    }
}

// Implement handler method
void _showRecommendations(Map<String, dynamic> data) {
    try {
        final movies = data['movies'] as List? ?? [];
        
        // Simple: Show as modal bottom sheet
        showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Text(
                            'Recommended Movies',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                            ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                            child: ListView.builder(
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                    final movie = movies[index] as Map;
                                    return ListTile(
                                        title: Text(movie['movie'] ?? 'Unknown'),
                                        subtitle: Text(
                                            'Rating: ${movie['rating']}/10'
                                        ),
                                    );
                                },
                            ),
                        ),
                        FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                        ),
                    ],
                ),
            ),
        );
    } catch (e) {
        debugPrint('Error showing recommendations: $e');
    }
}
```

### Step 3: Test the Action

1. Send message that triggers new action
2. Verify handler is called
3. Check UI updates correctly

---

## Adding New Database Queries

### Example: Filter Movies by Genre

```python
# In voice_chat_service.py

def _get_movies_by_genre(db: Session, genre: str) -> str:
    """Get movies of specific genre"""
    movies = db.query(Movie)\
        .filter(Movie.genre.ilike(f"%{genre}%"))\
        .order_by(Movie.rating.desc())\
        .limit(8)\
        .all()
    
    if not movies:
        return f"I couldn't find any {genre} movies."
    
    titles = ", ".join(movie.title for movie in movies)
    return f"Here are {genre} movies: {titles}."

# Use in intent handler:
if any(phrase in text for phrase in ["action movies", "comedy movies"]):
    genre = _extract_genre_hint(text)
    response = _get_movies_by_genre(db, genre)
    return {"reply": response}
```

---

## Enhancing Session Management

### Storing Custom Context

```python
# In get_chat_result():

session["user_preference"] = "action"
session["search_query"] = "best rated"
session["last_movie"] = "Avatar"

# Set state
store.set_state(session_id, **session)

# Retrieved in next call via session param
```

### Multi-step Conversation Example

```python
def get_chat_result(db, message, session):
    text = _normalize_text(message)
    
    # Check if we're in middle of multi-step flow
    if session.get("state") == "picking_show_time":
        show_time = _extract_showtime(text)
        movie_id = session.get("movie_id")
        movie = db.query(Movie).filter(Movie.id == movie_id).first()
        
        session["state"] = None
        return {
            "reply": f"Opening seat selection for {movie.title} at {show_time}",
            "action": "open_seat_page",
            "data": {
                "movie": movie.title,
                "show_time": show_time,
            }
        }
    
    # ... rest of code ...
```

---

## Best Practices for New Intents

### ✅ DO:

```python
# 1. Always normalize text
text = _normalize_text(message)

# 2. Return consistent response format
return {
    "reply": str,           # Always required, natural language
    "action": str or None,  # Lowercase snake_case
    "data": dict,          # Always include, can be empty {}
    "expecting": str or None,  # If awaiting input
}

# 3. Use helper functions for extraction
seat_count = _extract_seat_count(text)
show_time = _extract_showtime(text)
movie = _match_movie_from_text(db, text)

# 4. Handle edge cases gracefully
if not movie:
    return {"reply": "I couldn't find that movie..."}

# 5. Store session state for multi-step flows
session["state"] = "awaiting_seat_count"
session["movie_id"] = movie.id
```

### ❌ DON'T:

```python
# 1. Don't assume exact matches
if message == "book avatar":  # ❌ Won't match "Book Avatar" or "book Avatar"
    
# 2. Don't return None
return None  # ❌ Will crash frontend

# 3. Don't make blocking database queries
# Use efficient queries with limit()
movies = db.query(Movie).all()  # ❌ Loads all movies

# 4. Don't store sensitive data in session
session["user_password"] = ...  # ❌ Security issue

# 5. Don't forget to handle empty/null cases
chat_response = response['data'].get('movie')  # ✅ Safe
```

---

## Testing New Features

### Unit Tests (Backend)

```python
# In test_chatbot_api.py

def test_new_intent():
    """Test the new intent"""
    response = requests.post(
        "http://localhost:8000/chat",
        json={"message": "recommend action movies"}
    )
    
    assert response.status_code == 200
    data = response.json()
    
    assert "reply" in data
    assert data["action"] == "show_recommendations"
    assert "movies" in data["data"]

def test_new_intent_no_results():
    """Test edge case"""
    response = requests.post(
        "http://localhost:8000/chat",
        json={"message": "recommend xyzabc"}
    )
    
    data = response.json()
    assert "couldn't find" in data["reply"].lower()
```

### Manual Testing

```bash
# Run interactive test
python test_chatbot_voice_api.py --interactive

# Or use curl
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "your test message"}'
```

### Flutter Testing

```dart
// In test/chat_screen_test.dart

void main() {
  testWidgets('New action triggers navigation', (WidgetTester tester) async {
    // Mock API response with new action
    final response = ChatResponseModel(
      reply: "Test reply",
      sessionId: "test-123",
      action: "show_recommendations",
      data: {"movies": []},
    );
    
    // Test that handler processes action
    // Add your test assertions
  });
}
```

---

## Performance Optimization

### Caching Movie Data

```python
from functools import lru_cache

@lru_cache(maxsize=256)
def _get_movie_by_title(title: str):
    """Cache frequent movie lookups"""
    # Implementation
    pass
```

### Batch Database Queries

```python
# ❌ Bad: N+1 queries
movies = db.query(Movie).all()
for movie in movies:
    genres = movie.genres  # Extra query per movie

# ✅ Good: Single query with join
movies = db.query(Movie)\
    .options(joinedload(Movie.genres))\
    .all()
```

### Response Time Targets

- Intent detection: < 50ms
- Database query: < 100ms
- Total response: < 200ms
- Frontend action: < 300ms

---

## Debugging

### Enable Logging

```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

logger.debug(f"Processing message: {text}")
logger.debug(f"Extracted intent: {intent_name}")
logger.debug(f"Session state: {session}")
```

### Check Response Format

```bash
# Raw response from API
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}' | python -m json.tool
```

### Flutter Debugging

```dart
// Add to ChatScreen
debugPrint('Response action: ${response.action}');
debugPrint('Response data: ${response.data}');
debugPrint('Session ID: ${response.sessionId}');
```

---

## Common Patterns

### Pattern 1: Yes/No Follow-up

```python
if session.get("expecting") == "confirmation":
    if any(word in text for word in ["yes", "yeah", "sure", "ok"]):
        # Do action
        session["state"] = None
        return {"reply": "Confirmed! ..."}
    else:
        return {"reply": "Cancelled."}
```

### Pattern 2: Choice from List

```python
if session.get("state") == "picking_show_time":
    show_time = _extract_showtime(text)
    if show_time:
        return {"reply": f"Selected {show_time}"}
    else:
        return {"reply": f"Available times: {', '.join(SHOW_TIMES)}"}
```

### Pattern 3: Fallback Intent

```python
# At end of get_chat_result()
return {
    "reply": "I can help you book movies. Try: 'Book Avatar', 'Show movies', etc."
}
```

---

## Deployment Checklist

- [ ] New intent tested with multiple variations
- [ ] Edge cases handled (nulls, empty strings, invalid input)
- [ ] Response format matches schema
- [ ] Database queries optimized
- [ ] Session management correct
- [ ] Flutter action handler implemented
- [ ] UI/UX feels natural
- [ ] Error messages helpful
- [ ] Performance within targets
- [ ] Documentation updated

---

## Examples Library

### Example 1: Filter by Rating

```python
def get_highly_rated_movies(db: Session, min_rating: float = 7.5) -> str:
    movies = db.query(Movie)\
        .filter(Movie.rating >= min_rating)\
        .order_by(Movie.rating.desc())\
        .limit(5)\
        .all()
    
    if not movies:
        return f"No movies with {min_rating}+ rating available."
    
    return f"Highest rated: {', '.join(m.title for m in movies)}."
```

### Example 2: Price Estimation

```python
def estimate_booking_price(seat_count: int, seats: List[str]) -> int:
    """Estimate total price for seats"""
    PRICES = {
        'A': 210, 'B': 210, 'C': 210, 'D': 210,  # SILVER
        'E': 210, 'F': 210, 'G': 210, 'H': 210, 'I': 210,  # PREMIER
        'J': 190, 'K': 190, 'L': 190,  # EXECUTIVE
    }
    
    total = 0
    for seat in seats:
        row = seat[0]
        total += PRICES.get(row, 200)
    
    return total
```

### Example 3: Time Slot Availability

```python
def get_oldest_available_show(shows: List[str], current_time: str) -> str:
    """Get next available show time"""
    from datetime import datetime, time
    
    current = datetime.now().time()
    available = [s for s in shows if parse_time(s) > current]
    
    return available[0] if available else shows[-1]
```

---

## Support & Feedback

For questions about extending the chatbot:

1. Check existing intents in `voice_chat_service.py`
2. Review example test cases
3. Check Backend API documentation at `/docs`
4. Open an issue with detailed description

---

**Last Updated**: 2026-04-13  
**Version**: 1.0

