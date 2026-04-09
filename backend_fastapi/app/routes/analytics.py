from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.services.analytics_service import booking_insights
from app.core.config import get_db

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/")
def get_analytics(db: Session = Depends(get_db)):
    return booking_insights(db)