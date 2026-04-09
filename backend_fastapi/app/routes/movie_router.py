from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.models.movie import Movie
from app.schemas.movie_schema import MovieCreate, MovieResponse
from app.core.config import get_db

router = APIRouter(prefix="/movies", tags=["Movies"])


@router.get("/", response_model=List[MovieResponse])
def get_movies(genre: str = None, db: Session = Depends(get_db)):
    """Get all movies, optionally filtered by genre"""
    query = db.query(Movie)
    if genre:
        query = query.filter(Movie.genre == genre)
    return query.all()


@router.get("/genres")
def get_genres(db: Session = Depends(get_db)):
    """Get all unique genres"""
    genres = db.query(Movie.genre).distinct().all()
    return [genre[0] for genre in genres]


@router.get("/{movie_id}", response_model=MovieResponse)
def get_movie(movie_id: int, db: Session = Depends(get_db)):
    """Get a specific movie by ID"""
    movie = db.query(Movie).filter(Movie.id == movie_id).first()
    if not movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    return movie


@router.post("/", response_model=MovieResponse)
def create_movie(movie: MovieCreate, db: Session = Depends(get_db)):
    """Create a new movie"""
    db_movie = Movie(**movie.dict())
    db.add(db_movie)
    db.commit()
    db.refresh(db_movie)
    return db_movie


@router.put("/{movie_id}", response_model=MovieResponse)
def update_movie(movie_id: int, movie: MovieCreate, db: Session = Depends(get_db)):
    """Update an existing movie"""
    db_movie = db.query(Movie).filter(Movie.id == movie_id).first()
    if not db_movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    
    for key, value in movie.dict().items():
        setattr(db_movie, key, value)
    
    db.commit()
    db.refresh(db_movie)
    return db_movie


@router.delete("/{movie_id}")
def delete_movie(movie_id: int, db: Session = Depends(get_db)):
    """Delete a movie"""
    db_movie = db.query(Movie).filter(Movie.id == movie_id).first()
    if not db_movie:
        raise HTTPException(status_code=404, detail="Movie not found")
    
    db.delete(db_movie)
    db.commit()
    return {"message": "Movie deleted successfully"}