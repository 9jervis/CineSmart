from sqlalchemy.orm import Session
from app.models.movie import Movie

def recommend_movies(db: Session, movie_id: int):
    movie = db.query(Movie).filter(Movie.id == movie_id).first()

    if not movie:
        return []

    recommendations = db.query(Movie).filter(
        Movie.genre == movie.genre,
        Movie.id != movie.id
    ).all()

    return recommendations