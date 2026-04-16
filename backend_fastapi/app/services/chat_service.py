import re
from typing import Any, Dict, Optional

from sqlalchemy.orm import Session

from app.models.movie import Movie


def _list_movies(db: Session, limit: int = 8) -> str:
    movies = db.query(Movie).order_by(Movie.rating.desc()).limit(limit).all()
    if not movies:
        return "I couldn't find any movies right now."
    titles = ", ".join([m.title for m in movies])
    return f"Here are some movies you can book: {titles}."


def _find_movie_by_title(db: Session, title: str) -> Optional[Movie]:
    t = (title or "").strip()
    if not t:
        return None
    # Simple best-effort match: exact -> startswith -> contains
    exact = db.query(Movie).filter(Movie.title.ilike(t)).first()
    if exact:
        return exact
    starts = db.query(Movie).filter(Movie.title.ilike(f"{t}%")).first()
    if starts:
        return starts
    contains = db.query(Movie).filter(Movie.title.ilike(f"%{t}%")).first()
    return contains


def _extract_seat_count(text: str) -> Optional[int]:
    m = re.search(r"\b(\d{1,2})\s*(seat|seats|ticket|tickets)\b", text)
    if m:
        try:
            n = int(m.group(1))
            return n if 1 <= n <= 10 else None
        except ValueError:
            return None
    return None


def _extract_book_movie_title(text: str) -> Optional[str]:
    # Examples: "book avatar", "book movie avatar", "I want to book Avengers"
    m = re.search(r"\bbook\s+(?:movie\s+)?(.+)$", text)
    if not m:
        return None
    title = m.group(1)
    # remove trailing "tickets/seats" noise if present
    title = re.sub(r"\b(\d{1,2})\s*(seat|seats|ticket|tickets)\b.*$", "", title).strip()
    return title or None


def get_chat_result(
    db: Session,
    message: str,
    session: Dict[str, Any],
) -> Dict[str, Any]:
    """
    Returns a dict with keys:
      reply, action(optional), data(optional), expecting(optional)
    """
    text = (message or "").strip().lower()
    if not text:
        return {
            "reply": "Please say something like “show movies” or “book Avatar”.",
        }

    # If we are waiting for seat count, interpret the message as seat count
    if session.get("state") == "awaiting_seat_count":
        n = _extract_seat_count(text)
        if not n:
            return {"reply": "How many seats would you like to book? (1 to 10)", "expecting": "seat_count"}
        movie_id = session.get("movie_id")
        movie_title = session.get("movie_title")
        if not movie_id:
            session["state"] = None
            return {"reply": "Which movie would you like to book?"}
        session["state"] = None
        session["seat_count"] = n
        return {
            "reply": f"Opening seat selection for {n} seat(s) for {movie_title or 'your movie'}.",
            "action": "open_seat_page",
            "data": {"movie_id": movie_id, "seats": n},
        }

    # List movies
    if any(k in text for k in ["show movies", "movies", "now showing", "recommend"]):
        return {"reply": _list_movies(db)}

    # Show timings
    if any(k in text for k in ["timing", "timings", "showtime", "showtimes", "shows"]):
        return {
            "reply": (
                "Show timings (sample): 10:15 AM, 01:30 PM, 04:00 PM, 07:15 PM, 10:30 PM. "
                "Open a movie → choose a theatre → pick a time."
            )
        }

    # Book movie flow (movie mentioned)
    if "book" in text:
        seat_count = _extract_seat_count(text)
        title = _extract_book_movie_title(text)
        if not title:
            return {"reply": "Which movie would you like to book?"}

        movie = _find_movie_by_title(db, title)
        if not movie:
            return {"reply": f"I couldn't find “{title}”. Try saying the full movie name."}

        # If seat count is provided in the same utterance, open seat page directly
        if seat_count:
            return {
                "reply": f"Opening seat selection for {seat_count} seat(s) for {movie.title}.",
                "action": "open_seat_page",
                "data": {"movie_id": movie.id, "seats": seat_count},
            }

        # Otherwise ask for seat count and store state
        session["state"] = "awaiting_seat_count"
        session["movie_id"] = movie.id
        session["movie_title"] = movie.title
        return {
            "reply": f"Sure — how many seats would you like to book for {movie.title}?",
            "expecting": "seat_count",
        }

    # Greetings / fallback
    if any(k in text for k in ["hi", "hello", "hey"]):
        return {"reply": "Hi! Tell me a movie name to book, or say “show movies”."}

    return {
        "reply": "I can help you book movies. Try: “Book Avatar”, “Show movies”, or “Book 3 tickets for Avengers”."
    }
