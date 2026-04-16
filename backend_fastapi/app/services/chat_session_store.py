import time
import uuid
from typing import Any, Dict, Optional, Tuple


class ChatSessionStore:
    def __init__(self, ttl_seconds: int = 20 * 60):
        self.ttl_seconds = ttl_seconds
        self._sessions: Dict[str, Dict[str, Any]] = {}

    def _now(self) -> float:
        return time.time()

    def _purge_expired(self) -> None:
        now = self._now()
        expired = [
            sid
            for sid, s in self._sessions.items()
            if now - float(s.get("updated_at", 0)) > self.ttl_seconds
        ]
        for sid in expired:
            self._sessions.pop(sid, None)

    def get_or_create(self, session_id: Optional[str]) -> Tuple[str, Dict[str, Any]]:
        self._purge_expired()
        if session_id and session_id in self._sessions:
            self._sessions[session_id]["updated_at"] = self._now()
            return session_id, self._sessions[session_id]

        sid = str(uuid.uuid4())
        self._sessions[sid] = {
            "state": None,
            "movie_id": None,
            "movie_title": None,
            "seat_count": None,
            "updated_at": self._now(),
        }
        return sid, self._sessions[sid]

    def set_state(self, session_id: str, **kwargs: Any) -> None:
        if session_id not in self._sessions:
            return
        self._sessions[session_id].update(kwargs)
        self._sessions[session_id]["updated_at"] = self._now()


store = ChatSessionStore()

