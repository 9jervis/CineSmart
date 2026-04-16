#!/usr/bin/env python3

"""
Refresh movie poster URLs using OMDb.

Usage:
  set OMDB_API_KEY=...   (PowerShell: $env:OMDB_API_KEY="...")
  python refresh_posters.py
"""

from sqlalchemy.orm import sessionmaker

from app.core.database import engine
from app.models.movie import Movie
from app.utils.omdb import fetch_poster_url_by_title


def main() -> None:
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    try:
        movies = db.query(Movie).all()
        updated = 0
        for m in movies:
            poster = fetch_poster_url_by_title(m.title)
            if poster and poster != m.image_url:
                m.image_url = poster
                updated += 1
                print(f"✅ {m.title} -> {poster}")
        db.commit()
        print(f"\nDone. Updated {updated} movie(s).")
    finally:
        db.close()


if __name__ == "__main__":
    main()

