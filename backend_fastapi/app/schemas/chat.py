from pydantic import BaseModel
from typing import Optional, Dict, Any
from enum import Enum


class ChatMessageRole(str, Enum):
    """Enum for chat message roles."""
    USER = "user"
    ASSISTANT = "assistant"


class ChatMessage(BaseModel):
    """Schema for a chat message."""
    role: ChatMessageRole
    content: str


class ChatRequest(BaseModel):
    """Request schema for chat endpoint."""
    message: str
    movie_context: Optional[str] = None  # Current movie context
    booking_context: Optional[Dict[str, Any]] = None  # Current booking state


class ChatAction(str, Enum):
    """Enum for chatbot actions."""
    NONE = "none"
    OPEN_SEAT_PAGE = "open_seat_page"
    OPEN_MOVIE_LIST = "open_movie_list"
    OPEN_MOVIE_DETAILS = "open_movie_details"
    CONFIRM_BOOKING = "confirm_booking"
    SHOW_AVAILABLE_SHOWS = "show_available_shows"


class ChatActionData(BaseModel):
    """Schema for action data."""
    movie: Optional[str] = None
    seats: Optional[int] = None
    show_id: Optional[str] = None
    additional_info: Optional[Dict[str, Any]] = None


class ChatResponse(BaseModel):
    """Response schema for chat endpoint."""
    reply: str  # Human-readable response to display
    action: ChatAction  # Action to trigger in Flutter app
    data: Optional[ChatActionData] = None  # Data for the action
    context_update: Optional[Dict[str, Any]] = None  # Update to conversation context
