import re
from datetime import date, timedelta
from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session

from app.models.movie import Movie
from app.models.user import User

SHOW_TIMES = [
    "10:15 AM",
    "01:30 PM",
    "04:00 PM",
    "07:15 PM",
    "10:30 PM",
]


def _list_movies(db: Session, limit: int = 8) -> str:
    movies = db.query(Movie).order_by(Movie.rating.desc()).limit(limit).all()
    if not movies:
        return "I couldn't find any movies right now."
    return f"Here are some movies you can book: {', '.join(movie.title for movie in movies)}."


def _find_movie_by_title(db: Session, title: str) -> Optional[Movie]:
    cleaned = (title or "").strip()
    if not cleaned:
        return None
    exact = db.query(Movie).filter(Movie.title.ilike(cleaned)).first()
    if exact:
        return exact
    starts = db.query(Movie).filter(Movie.title.ilike(f"{cleaned}%")).first()
    if starts:
        return starts
    return db.query(Movie).filter(Movie.title.ilike(f"%{cleaned}%")).first()


_WORD_NUMS: Dict[str, int] = {
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
}
_SEAT_WORDS = r"(?:seat|seats|ticket|tickets)"
_WORD_NUM_PAT = "|".join(_WORD_NUMS.keys())


def _extract_seat_count(text: str, bare_ok: bool = False) -> Optional[int]:
    """Extract seat/ticket count from text. Pass bare_ok=True when already in seat-count state."""
    # digit + seat/ticket word: "2 seats", "3 tickets"
    m = re.search(rf"\b(\d{{1,2}})\s*{_SEAT_WORDS}\b", text)
    if m:
        count = int(m.group(1))
        return count if 1 <= count <= 10 else None
    # word number + seat/ticket: "two seats", "three tickets"
    m = re.search(rf"\b({_WORD_NUM_PAT})\s*{_SEAT_WORDS}\b", text)
    if m:
        return _WORD_NUMS[m.group(1)]
    if bare_ok:
        # bare digit: "2", "3"
        m = re.search(r"\b(\d{1,2})\b", text)
        if m:
            count = int(m.group(1))
            return count if 1 <= count <= 10 else None
        # bare word number: "two", "three"
        m = re.search(rf"\b({_WORD_NUM_PAT})\b", text)
        if m:
            return _WORD_NUMS[m.group(1)]
    return None


def _extract_showtime(text: str) -> Optional[str]:
    for showtime in SHOW_TIMES:
        if showtime.lower() in text:
            return showtime
    return None


def _extract_movie_hint(text: str) -> Optional[str]:
    patterns = [
        r"\bbook\s+(?:movie\s+)?(?P<title>.+)$",
        r"\b(?:for|about|open|details for|details about|tell me about)\s+(?P<title>.+)$",
    ]
    for pattern in patterns:
        match = re.search(pattern, text)
        if not match:
            continue
        title = match.group("title")
        # strip "2 tickets for" / "two seats for" prefix (voice input pattern)
        title = re.sub(
            rf"^(?:\d{{1,2}}|{_WORD_NUM_PAT})\s*{_SEAT_WORDS}\s+(?:for\s+)?",
            "",
            title,
            flags=re.IGNORECASE,
        ).strip()
        # strip "for HH:MM am/pm" suffix
        title = re.sub(
            r"\b(?:at|for)\s+\d{{1,2}}:\d{{2}}\s*(?:am|pm)\b.*$",
            "",
            title,
            flags=re.IGNORECASE,
        ).strip()
        # strip digit seat count suffix
        title = re.sub(
            rf"\b(\d{{1,2}})\s*{_SEAT_WORDS}\b.*$",
            "",
            title,
            flags=re.IGNORECASE,
        ).strip()
        # strip leading "movie" / "the movie"
        title = re.sub(r"^(movie|the movie)\s+", "", title, flags=re.IGNORECASE).strip()
        if title:
            return title
    return None


def _normalize_text(message: str) -> str:
    return re.sub(r"\s+", " ", (message or "").strip()).lower()


def _movie_payload(movie: Movie) -> Dict[str, Any]:
    return {
        "movie_id": movie.id,
        "movie": movie.title,
        "description": movie.description or "",
        "genre": movie.genre,
        "rating": movie.rating,
        "duration": movie.duration,
        "image_url": movie.image_url,
    }


def _build_seat_page_data(movie: Movie, seats: int, show_time: Optional[str]) -> Dict[str, Any]:
    data = _movie_payload(movie)
    data["seats"] = seats
    data["show_time"] = show_time or SHOW_TIMES[2]
    data["subtitle"] = "AI Assistant booking flow"
    return data


def _movies_payload(movies: list) -> List[Dict[str, Any]]:
    return [_movie_payload(m) for m in movies]


def _fetch_movies(db: Session, limit: int = 8) -> list:
    return db.query(Movie).order_by(Movie.rating.desc()).limit(limit).all()


_MONTHS: Dict[str, int] = {
    "january": 1, "jan": 1, "february": 2, "feb": 2,
    "march": 3, "mar": 3, "april": 4, "apr": 4,
    "may": 5, "june": 6, "jun": 6, "july": 7, "jul": 7,
    "august": 8, "aug": 8, "september": 9, "sep": 9,
    "october": 10, "oct": 10, "november": 11, "nov": 11,
    "december": 12, "dec": 12,
}
_MONTH_PATTERN = "|".join(_MONTHS.keys())

_LIST_MOVIES_PHRASES = [
    "show movies", "list movies", "list down movies", "now showing", "recommend",
    "what movies", "which movies", "movies available", "available movies",
    "whats on", "what's on", "movies playing", "movies running",
    "running movies", "current movies", "playing now",
    "show me movies", "show all movies", "all movies",
    "what can i watch", "what can i book",
    "movies are available", "movies are running", "movies are playing",
]

_DATE_WORDS = [
    "today", "tomorrow", "weekend", "saturday", "sunday",
    "monday", "tuesday", "wednesday", "thursday", "friday",
    "this week", "next week",
]

# ── Stop words: never count these as movie-title tokens ──────────────────────
_STOP_WORDS = {
    "the", "a", "an", "is", "are", "was", "were", "be", "been", "being",
    "for", "of", "in", "on", "at", "by", "to", "and", "or", "but",
    "not", "yet", "can", "do", "did", "has", "have", "will", "would",
    "you", "me", "my", "we", "it", "its", "this", "that", "what",
    "how", "who", "why", "when", "where", "which", "your", "our",
    "any", "all", "some", "just", "want", "need", "get", "let", "say",
    "see", "know", "show", "tell", "give", "please",
}

# ── Intent signal phrases ────────────────────────────────────────────────────
_PERSONAL_PHRASES = [
    "my name", "who am i", "do you know me", "your name", "who are you",
    "what am i", "remember me", "what is my", "whats my",
]
# Availability phrases that imply a SPECIFIC movie (not a general list).
# "available" alone is NOT here — it's too generic and clashes with
# "which movies are available on ..."
_AVAILABILITY_PHRASES = [
    "is it showing", "is it running", "is it playing", "availability",
]


def _classify_intent(text: str) -> str:
    """Classify the user message into an intent string.
    Ordered from most-specific to least-specific.
    """
    # Greetings — exact or starts-with to avoid false positives
    first_word = text.split()[0] if text.split() else ""
    if first_word in {"hi", "hello", "hey", "hiya", "howdy"}:
        return "greeting"

    # Personal questions first (before any movie logic)
    if any(p in text for p in _PERSONAL_PHRASES):
        return "personal"

    # Booking — very explicit signal
    if any(p in text for p in ["book", "tickets for", "seats for", "reserve"]):
        return "booking"

    # ── Date-based movie list query — MUST come before availability ──────────
    # Handles: "which movies are available on 15th April",
    #          "list down movies on 15 April", "movies tomorrow"
    if _is_date_movie_query(text):
        return "date_query"

    # ── General movie list — also before availability ─────────────────────────
    if _is_list_movies_intent(text):
        return "movie_list"

    # Availability — specific movie check: "is Avatar available?"
    # Only when "is" starts the sentence OR explicit availability phrases used
    if any(p in text for p in _AVAILABILITY_PHRASES):
        return "availability"
    if text.startswith("is ") and any(
        w in text for w in ["available", "showing", "running", "playing"]
    ):
        return "availability"
    # "is X available" pattern without date
    if "available" in text and re.search(r"^is\s+\w", text):
        return "availability"

    # Showtimes
    if any(
        p in text
        for p in ["timing", "timings", "showtime", "showtimes", "available shows"]
    ):
        return "showtime"

    # Movie details
    if any(
        p in text
        for p in [
            "movie details", "details of", "open movie", "about movie",
            "tell me about", "suitable for kids", "kid friendly",
            "age rating", "describe", "info about", "what is",
        ]
    ):
        return "movie_details"

    # Any remaining movie-related context?
    has_movie_ctx = any(
        w in text
        for w in ["movie", "movies", "film", "cinema", "ticket", "seat", "watch"]
    )
    return "movie_related" if has_movie_ctx else "unknown"


def _parse_date_from_text(text: str) -> Optional[date]:
    today = date.today()
    if "today" in text:
        return today
    if "tomorrow" in text:
        return today + timedelta(days=1)
    if "weekend" in text:
        days_ahead = (5 - today.weekday()) % 7 or 7
        return today + timedelta(days=days_ahead)
    day_order = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    for i, day_name in enumerate(day_order):
        if day_name in text:
            days_ahead = (i - today.weekday()) % 7 or 7
            return today + timedelta(days=days_ahead)
    # "25th april" or "april 25"
    m = re.search(rf"(\d{{1,2}})(?:st|nd|rd|th)?\s+({_MONTH_PATTERN})", text)
    if m:
        try:
            return date(today.year, _MONTHS[m.group(2)], int(m.group(1)))
        except ValueError:
            pass
    m = re.search(rf"({_MONTH_PATTERN})\s+(\d{{1,2}})(?:st|nd|rd|th)?", text)
    if m:
        try:
            return date(today.year, _MONTHS[m.group(1)], int(m.group(2)))
        except ValueError:
            pass
    return None


def _is_list_movies_intent(text: str) -> bool:
    return any(phrase in text for phrase in _LIST_MOVIES_PHRASES)


def _is_date_movie_query(text: str) -> bool:
    """True when the user wants a movie list filtered by a date.
    Works for: 'movies on 15 April', 'which movies are available tomorrow',
    'list down movies on 15th April', 'movies running this weekend'.
    """
    has_date = (
        any(w in text for w in _DATE_WORDS)
        or bool(re.search(_MONTH_PATTERN, text))
        or bool(re.search(r"\b\d{1,2}(?:st|nd|rd|th)?\b", text))
    )
    # Broader movie context — includes 'available', 'list', 'which', 'running'
    has_movie_ctx = any(
        w in text
        for w in [
            "movie", "movies", "film", "cinema",
            "showing", "playing", "running", "available",
        ]
    )
    return has_date and has_movie_ctx


def _char_similarity(a: str, b: str) -> float:
    """Jaccard similarity on character sets — handles typos like 'Avtar'→'Avatar'."""
    if not a or not b:
        return 0.0
    sa, sb = set(a), set(b)
    return len(sa & sb) / len(sa | sb)


def _match_movie_from_text(db: Session, text: str) -> Optional[Movie]:
    all_movies = db.query(Movie).all()

    # 1. Try extracted hint → exact/prefix/fuzzy DB lookup
    hint = _extract_movie_hint(text)
    if hint:
        movie = _find_movie_by_title(db, hint)
        if movie:
            return movie
        # fuzzy fallback for the hint (handles typos)
        best: Optional[Movie] = None
        best_sim = 0.0
        for m in all_movies:
            sim = _char_similarity(hint.lower(), m.title.lower())
            if sim > best_sim:
                best_sim = sim
                best = m
        if best_sim >= 0.55:
            return best

    # 2. Token overlap across full text
    tokens = [t for t in re.split(r"[^a-z0-9]+", text) if len(t) > 2]
    if tokens:
        best_match: Optional[Movie] = None
        best_score = 0
        for movie in all_movies:
            movie_text = movie.title.lower()
            score = sum(1 for token in tokens if token in movie_text)
            if score > best_score:
                best_match = movie
                best_score = score
        if best_score > 0:
            return best_match

    # 3. Character similarity across all tokens vs each movie title
    if tokens:
        best_movie: Optional[Movie] = None
        best_sim2 = 0.0
        for movie in all_movies:
            for token in tokens:
                sim = _char_similarity(token, movie.title.lower())
                if sim > best_sim2:
                    best_sim2 = sim
                    best_movie = movie
        if best_sim2 >= 0.6:
            return best_movie

    return None


def _resolve_movie_from_session(db: Session, session: Dict[str, Any]) -> Optional[Movie]:
    movie_id = session.get("movie_id")
    if not movie_id:
        return None
    return db.query(Movie).filter(Movie.id == movie_id).first()


def _resolve_username(
    db: Session, session: Dict[str, Any], user_id: Optional[int]
) -> Optional[str]:
    """Return cached username from session, or look it up from DB by user_id."""
    cached = session.get("username")
    if cached:
        return cached
    if user_id:
        user = db.query(User).filter(User.id == user_id).first()
        if user and user.name:
            session["username"] = user.name
            return user.name
    return None


def get_chat_result(
    db: Session,
    message: str,
    session: Dict[str, Any],
    user_id: Optional[int] = None,
) -> Dict[str, Any]:
    text = _normalize_text(message)
    if not text:
        return {"reply": "Please say something like 'show movies' or 'book Avatar'."}

    intent = _classify_intent(text)

    # ── session state machines (respected regardless of intent) ────────────
    if session.get("state") == "awaiting_seat_count":
        seat_count = _extract_seat_count(text, bare_ok=True)
        if not seat_count:
            return {
                "reply": "How many seats would you like? Say a number from 1 to 10.",
                "expecting": "seat_count",
            }
        movie = _resolve_movie_from_session(db, session)
        if not movie:
            session["state"] = None
            return {"reply": "Which movie would you like to book?"}
        show_time = _extract_showtime(text) or session.get("show_time")
        session["state"] = None
        session["seat_count"] = seat_count
        return {
            "reply": f"Opening seat selection for {seat_count} seat(s) for {movie.title}.",
            "action": "open_seat_page",
            "data": _build_seat_page_data(movie, seat_count, show_time),
        }

    if session.get("state") == "awaiting_movie_for_details":
        movie = _match_movie_from_text(db, text)
        session["state"] = None
        if not movie:
            return {"reply": "I couldn't find that movie. Try saying the full title."}
        return {
            "reply": f"Here are the details for {movie.title}.",
            "action": "movie_details_card",
            "data": _movie_payload(movie),
        }

    # ── greeting ────────────────────────────────────────────────────────────
    if intent == "greeting":
        username = _resolve_username(db, session, user_id)
        name_part = f", {username}" if username else ""
        return {
            "reply": (
                f"Hi{name_part}! 🎬 I can help you with movies, bookings, and show timings.\n"
                "Try: 'Show movies', 'Book 2 tickets for Avatar', or 'Tell me about Jawan'."
            )
        }

    # ── personal questions ──────────────────────────────────────────────────
    if intent == "personal":
        username = _resolve_username(db, session, user_id)
        if username:
            return {
                "reply": f"Yes, your name is {username}! 😊 How can I help you with movie bookings?"
            }
        return {"reply": "I don't know your name yet. Log in and I'll remember you!"}

    # ── availability check: 'is Endgame available?' ─────────────────────────
    if intent == "availability":
        movie = _match_movie_from_text(db, text)
        target_date = _parse_date_from_text(text)
        date_str = (
            f" on {target_date.strftime('%B')} {target_date.day}" if target_date else ""
        )
        if movie:
            return {
                "reply": (
                    f"✅ Yes, {movie.title} is available{date_str}! "
                    f"Would you like to book tickets or see details?"
                ),
                "action": "movie_details_card",
                "data": _movie_payload(movie),
            }
        # Try to extract the queried name for a helpful "not found" reply
        m = re.search(
            r"^is\s+(.+?)\s+(?:available|showing|running|playing|on)\b", text
        )
        queried = m.group(1).strip().title() if m else "that movie"
        return {
            "reply": (
                f"❌ Sorry, I couldn’t find '{queried}'{date_str}. "
                "Say 'show movies' to see what’s playing."
            )
        }

    # ── date-based query ────────────────────────────────────────────────────
    if intent == "date_query":
        target_date = _parse_date_from_text(text)
        movies = _fetch_movies(db)
        date_str = (
            f"{target_date.strftime('%B')} {target_date.day}"
            if target_date
            else "that date"
        )
        heading = f"Movies on {date_str}"
        reply = (
            f"Here are {len(movies)} movies showing on {date_str}:"
            if movies
            else f"No movies found for {date_str}. Check back later!"
        )
        return {
            "reply": reply,
            "action": "show_movies",
            "data": {"movies": _movies_payload(movies), "heading": heading},
        }

    # ── list all movies ─────────────────────────────────────────────────────
    if intent == "movie_list":
        movies = _fetch_movies(db)
        if not movies:
            return {"reply": "I couldn't find any movies right now. Check back soon!"}
        names = ", ".join(m.title for m in movies[:4])
        suffix = "..." if len(movies) > 4 else ""
        return {
            "reply": f"Here are {len(movies)} movies now showing: {names}{suffix}.",
            "action": "show_movies",
            "data": {"movies": _movies_payload(movies), "heading": "Now Showing"},
        }

    # ── showtimes ───────────────────────────────────────────────────────────
    if intent == "showtime":
        movie = _match_movie_from_text(db, text)
        return {
            "reply": (
                f"Available shows for {movie.title}: {', '.join(SHOW_TIMES)}."
                if movie
                else f"Available shows today: {', '.join(SHOW_TIMES)}."
            ),
            "action": "show_available_shows",
            "data": {
                **(_movie_payload(movie) if movie else {}),
                "show_times": SHOW_TIMES,
            },
        }

    # ── movie details ───────────────────────────────────────────────────────
    if intent == "movie_details":
        movie = _match_movie_from_text(db, text)
        if not movie:
            session["state"] = "awaiting_movie_for_details"
            return {"reply": "Which movie would you like details for?", "expecting": "movie"}
        return {
            "reply": f"Here are the details for {movie.title}.",
            "action": "movie_details_card",
            "data": _movie_payload(movie),
        }

    # ── booking ─────────────────────────────────────────────────────────────
    if intent == "booking":
        movie = _match_movie_from_text(db, text)
        if not movie:
            return {"reply": "Which movie would you like to book?"}
        seat_count = _extract_seat_count(text)
        show_time = _extract_showtime(text)
        if seat_count:
            return {
                "reply": f"Opening seat selection for {seat_count} seat(s) for {movie.title}.",
                "action": "open_seat_page",
                "data": _build_seat_page_data(movie, seat_count, show_time),
            }
        session["state"] = "awaiting_seat_count"
        session["movie_id"] = movie.id
        session["movie_title"] = movie.title
        session["show_time"] = show_time or SHOW_TIMES[2]
        return {
            "reply": f"How many seats for {movie.title}? (1–10)",
            "expecting": "seat_count",
        }

    # ── movie_related fallback: try to match a title ────────────────────────
    if intent == "movie_related":
        movie = _match_movie_from_text(db, text)
        if movie:
            return {
                "reply": f"Did you mean {movie.title}? Here are its details:",
                "action": "movie_details_card",
                "data": _movie_payload(movie),
            }

    # ── unknown: not movie related ──────────────────────────────────────────
    return {
        "reply": (
            "I’m a movie booking assistant 🎬. I can help with:\n"
            "• Showing available movies — 'Show movies'\n"
            "• Booking tickets — 'Book 2 tickets for Avatar'\n"
            "• Movie details — 'Tell me about Jawan'\n"
            "• Show timings — 'Showtimes for Avengers'\n"
            "• Checking availability — 'Is Endgame available?'"
        )
    }
