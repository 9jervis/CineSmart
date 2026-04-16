from pydantic import BaseModel
from typing import Any, Dict, Optional


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    user_id: Optional[int] = None


class ChatResponse(BaseModel):
    reply: str
    session_id: str
    action: Optional[str] = None
    data: Optional[Dict[str, Any]] = None
    expecting: Optional[str] = None
