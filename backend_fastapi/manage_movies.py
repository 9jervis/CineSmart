#!/usr/bin/env python3

"""
Admin script to manage movies in the CineSmart database.
Run this script to add, update, delete, or list movies.
"""

import sys
from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.movie import Movie

# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

def list_movies():
    """List all movies"""
    movies = db.query(Movie).all()
    print(f"\n📽️  Total Movies: {len(movies)}\n")
    for movie in movies:
        print(f"ID: {movie.id} | {movie.title} ({movie.genre}) - ⭐ {movie.rating}")

def add_movie():
    """Add a new movie"""
    print("\n🎬 Add New Movie")
    title = input("Title: ").strip()
    if not title:
        print("❌ Title is required")
        return

    description = input("Description: ").strip()
    genre = input("Genre: ").strip()
    rating = float(input("Rating (0-10): ").strip())
    duration = int(input("Duration (minutes): ").strip())
    image_url = input("Image URL: ").strip()

    movie = Movie(
        title=title,
        description=description,
        genre=genre,
        rating=rating,
        duration=duration,
        image_url=image_url
    )

    try:
        db.add(movie)
        db.commit()
        db.refresh(movie)
        print(f"✅ Movie added successfully! ID: {movie.id}")
    except Exception as e:
        print(f"❌ Error adding movie: {e}")
        db.rollback()

def update_movie():
    """Update an existing movie"""
    movie_id = int(input("\nEnter movie ID to update: ").strip())
    movie = db.query(Movie).filter(Movie.id == movie_id).first()

    if not movie:
        print("❌ Movie not found")
        return

    print(f"\n🎬 Updating: {movie.title}")
    print("Press Enter to keep current value")

    title = input(f"Title [{movie.title}]: ").strip() or movie.title
    description = input(f"Description [{movie.description[:50]}...]: ").strip() or movie.description
    genre = input(f"Genre [{movie.genre}]: ").strip() or movie.genre
    rating = input(f"Rating [{movie.rating}]: ").strip()
    rating = float(rating) if rating else movie.rating
    duration = input(f"Duration [{movie.duration}]: ").strip()
    duration = int(duration) if duration else movie.duration
    image_url = input(f"Image URL [{movie.image_url}]: ").strip() or movie.image_url

    try:
        movie.title = title
        movie.description = description
        movie.genre = genre
        movie.rating = rating
        movie.duration = duration
        movie.image_url = image_url

        db.commit()
        print("✅ Movie updated successfully!")
    except Exception as e:
        print(f"❌ Error updating movie: {e}")
        db.rollback()

def delete_movie():
    """Delete a movie"""
    movie_id = int(input("\nEnter movie ID to delete: ").strip())
    movie = db.query(Movie).filter(Movie.id == movie_id).first()

    if not movie:
        print("❌ Movie not found")
        return

    confirm = input(f"Are you sure you want to delete '{movie.title}'? (y/N): ").strip().lower()
    if confirm == 'y':
        try:
            db.delete(movie)
            db.commit()
            print("✅ Movie deleted successfully!")
        except Exception as e:
            print(f"❌ Error deleting movie: {e}")
            db.rollback()
    else:
        print("❌ Deletion cancelled")

def main():
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        if command == "list":
            list_movies()
        elif command == "add":
            add_movie()
        elif command == "update":
            update_movie()
        elif command == "delete":
            delete_movie()
        else:
            print("❌ Invalid command. Use: list, add, update, delete")
    else:
        print("\n🎬 CineSmart Movie Manager")
        print("Usage: python manage_movies.py <command>")
        print("Commands:")
        print("  list    - List all movies")
        print("  add     - Add a new movie")
        print("  update  - Update an existing movie")
        print("  delete  - Delete a movie")

    db.close()

if __name__ == "__main__":
    main()