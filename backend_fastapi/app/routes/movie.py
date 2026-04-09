from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.schemas.movie_schema import MovieCreate, MovieResponse
from app.services.movie_service import (
    get_all_movies,
    get_movie_by_id,
    create_movie,
    get_trending_movies
)
from app.core.config import get_db

router = APIRouter(prefix="/movies", tags=["Movies"])


@router.post("/", response_model=MovieResponse)
def add_movie(movie: MovieCreate, db: Session = Depends(get_db)):
    return create_movie(db, movie)


@router.get("/", response_model=list[MovieResponse])
def list_movies(db: Session = Depends(get_db)):
    return get_all_movies(db)


@router.get("/trending", response_model=list[MovieResponse])
def trending_movies(db: Session = Depends(get_db)):
    return get_trending_movies(db)


@router.get("/{movie_id}", response_model=MovieResponse)
def movie_details(movie_id: int, db: Session = Depends(get_db)):
    return get_movie_by_id(db, movie_id)