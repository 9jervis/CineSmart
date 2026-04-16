from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import get_db
from app.schemas.chat_schema import ChatRequest, ChatResponse
from app.services.voice_chat_service import get_chat_result
from app.services.chat_session_store import store

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("", response_model=ChatResponse)
def chat(req: ChatRequest, db: Session = Depends(get_db)):
    session_id, session = store.get_or_create(req.session_id)
    result = get_chat_result(db, req.message, session, user_id=req.user_id)
    store.set_state(session_id, **session)
    return ChatResponse(
        reply=result.get("reply", ""),
        session_id=session_id,
        action=result.get("action"),
        data=result.get("data"),
        expecting=result.get("expecting"),
    )
