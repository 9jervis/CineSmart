from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.services.recommendation_service import recommend_movies
from app.schemas.movie_schema import MovieResponse
from app.core.config import get_db

router = APIRouter(prefix="/recommend", tags=["Recommendation"])


@router.get("/{movie_id}", response_model=list[MovieResponse])
def get_recommendations(movie_id: int, db: Session = Depends(get_db)):
    return recommend_movies(db, movie_id)