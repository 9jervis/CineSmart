from typing import Optional, Dict, Any, Tuple
from enum import Enum
import re

from app.schemas.chat import ChatAction, ChatActionData, ChatResponse


class ChatbotService:
    """Service for handling chatbot logic and intent detection."""

    # Movie list for context
    AVAILABLE_MOVIES = [
        "Avatar",
        "Avengers",
        "Inception",
        "The Matrix",
        "Dune",
        "Interstellar",
        "The Dark Knight",
        "Pulp Fiction",
    ]

    def __init__(self):
        self.conversation_history: list[Dict[str, str]] = []

    async def process_message(self, message: str, context: Optional[Dict[str, Any]] = None) -> ChatResponse:
        """
        Process user message and generate appropriate response with action.
        
        Args:
            message: User's input message
            context: Additional context like current booking state
            
        Returns:
            ChatResponse with reply, action, and data
        """
        # Normalize message
        normalized_message = message.lower().strip()

        # Detect intent
        intent, intent_data = self._detect_intent(normalized_message, context)

        # Generate response based on intent
        response = self._generate_response(intent, intent_data, normalized_message)

        return response

    def _detect_intent(self, message: str, context: Optional[Dict[str, Any]] = None) -> Tuple[str, Dict[str, Any]]:
        """
        Detect user intent from message.
        Returns: (intent_type, intent_data)
        """
        intent_data = {}

        # Check for booking intents
        if self._contains_book_keywords(message):
            movie = self._extract_movie_name(message)
            seats = self._extract_seat_count(message)

            if movie and seats:
                # "Book 3 seats for Avatar"
                return "book_with_details", {"movie": movie, "seats": seats}
            elif movie:
                # "Book Avatar" - need to ask for seat count
                return "book_movie", {"movie": movie}
            elif seats:
                # "Book 3 seats" - need movie context
                return "confirm_seats", {"seats": seats}
            else:
                # Just "book"
                return "book_general", {}

        # Check for showing movies
        if self._contains_show_keywords(message):
            movie = self._extract_movie_name(message)
            if movie:
                return "show_movie_details", {"movie": movie}
            else:
                return "show_movies", {}

        # Check for seats selection
        if self._contains_seat_keywords(message):
            seats = self._extract_seat_count(message)
            return "select_seats", {"seats": seats}

        # Check for confirmation
        if self._contains_confirm_keywords(message):
            return "confirm", {}

        # Default: general query
        return "general_query", {}

    def _generate_response(self, intent: str, intent_data: Dict[str, Any], message: str) -> ChatResponse:
        """
        Generate response based on detected intent.
        """
        if intent == "book_with_details":
            movie = intent_data.get("movie")
            seats = intent_data.get("seats")
            return ChatResponse(
                reply=f"Perfect! Opening seat selection for {seats} seats for {movie}.",
                action=ChatAction.OPEN_SEAT_PAGE,
                data=ChatActionData(movie=movie, seats=seats),
                context_update={"current_movie": movie, "selected_seats": seats},
            )

        elif intent == "book_movie":
            movie = intent_data.get("movie")
            return ChatResponse(
                reply=f"Great! You want to book {movie}. How many seats would you like to book?",
                action=ChatAction.NONE,
                context_update={"current_movie": movie},
            )

        elif intent == "confirm_seats":
            seats = intent_data.get("seats")
            return ChatResponse(
                reply=f"I'll book {seats} seats for you. Which movie would you like to watch?",
                action=ChatAction.NONE,
                context_update={"selected_seats": seats},
            )

        elif intent == "book_general":
            return ChatResponse(
                reply="I'd be happy to help you book a movie! Which movie would you like to watch? You can choose from: "
                + ", ".join(self.AVAILABLE_MOVIES[:5]) + ", and more.",
                action=ChatAction.OPEN_MOVIE_LIST,
                context_update={},
            )

        elif intent == "show_movies":
            return ChatResponse(
                reply=f"Here are some popular movies available: {', '.join(self.AVAILABLE_MOVIES[:5])}",
                action=ChatAction.OPEN_MOVIE_LIST,
                context_update={},
            )

        elif intent == "show_movie_details":
            movie = intent_data.get("movie")
            return ChatResponse(
                reply=f"Let me show you details for {movie}.",
                action=ChatAction.OPEN_MOVIE_DETAILS,
                data=ChatActionData(movie=movie),
                context_update={"current_movie": movie},
            )

        elif intent == "select_seats":
            seats = intent_data.get("seats")
            return ChatResponse(
                reply=f"Got it! I've selected {seats} seats for you. Ready to confirm?",
                action=ChatAction.NONE,
                context_update={"selected_seats": seats},
            )

        elif intent == "confirm":
            return ChatResponse(
                reply="Perfect! Your booking has been confirmed. Enjoy the movie!",
                action=ChatAction.CONFIRM_BOOKING,
                context_update={},
            )

        else:  # general_query
            return ChatResponse(
                reply="I can help you book a movie! Just say 'book [movie name]' or 'show me movies'. "
                "What would you like to do?",
                action=ChatAction.NONE,
                context_update={},
            )

    # Helper methods for intent detection

    def _contains_book_keywords(self, message: str) -> bool:
        keywords = ["book", "reserve", "buy", "get", "want", "like to watch"]
        return any(keyword in message for keyword in keywords)

    def _contains_show_keywords(self, message: str) -> bool:
        keywords = ["show", "list", "available", "what movies", "tell me", "display"]
        return any(keyword in message for keyword in keywords)

    def _contains_seat_keywords(self, message: str) -> bool:
        keywords = ["seat", "seats", "ticket", "tickets"]
        return any(keyword in message for keyword in keywords)

    def _contains_confirm_keywords(self, message: str) -> bool:
        keywords = ["yes", "confirm", "book it", "proceed", "ok", "okay", "sure"]
        return any(keyword in message for keyword in keywords)

    def _extract_movie_name(self, message: str) -> Optional[str]:
        """
        Extract movie name from message by matching against known movies.
        """
        for movie in self.AVAILABLE_MOVIES:
            if movie.lower() in message:
                return movie
        return None

    def _extract_seat_count(self, message: str) -> Optional[int]:
        """
        Extract seat count from message using regex.
        Matches patterns like "3 seats", "3 tickets", "book 3", etc.
        """
        # Match patterns: "3 seat(s)", "3 ticket(s)", or just a number followed by these words
        patterns = [
            r"(\d+)\s+seats?",
            r"(\d+)\s+tickets?",
            r"book\s+(\d+)",
            r"want\s+(\d+)",
            r"(\d+)\s+for",
        ]

        for pattern in patterns:
            match = re.search(pattern, message, re.IGNORECASE)
            if match:
                return int(match.group(1))

        return None
