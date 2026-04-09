#!/usr/bin/env python3

"""
Seed script to populate the database with initial movie data.
Run this script to add movies to the database.
"""

from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.movie import Movie

# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

# Movie data
movies_data = [
    {
        "title": "Interstellar",
        "description": "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
        "genre": "Sci-Fi",
        "rating": 8.6,
        "duration": 169,
        "image_url": "https://picsum.photos/200/300?random=1"
    },
    {
        "title": "Inception",
        "description": "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
        "genre": "Sci-Fi",
        "rating": 8.8,
        "duration": 148,
        "image_url": "https://picsum.photos/200/300?random=2"
    },
    {
        "title": "The Dark Knight",
        "description": "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
        "genre": "Action",
        "rating": 9.0,
        "duration": 152,
        "image_url": "https://picsum.photos/200/300?random=3"
    },
    {
        "title": "Pulp Fiction",
        "description": "The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.",
        "genre": "Crime",
        "rating": 8.9,
        "duration": 154,
        "image_url": "https://picsum.photos/200/300?random=4"
    },
    {
        "title": "The Shawshank Redemption",
        "description": "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.",
        "genre": "Drama",
        "rating": 9.3,
        "duration": 142,
        "image_url": "https://picsum.photos/200/300?random=5"
    },
    {
        "title": "Forrest Gump",
        "description": "The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold from the perspective of an Alabama man with an IQ of 75.",
        "genre": "Drama",
        "rating": 8.8,
        "duration": 142,
        "image_url": "https://picsum.photos/200/300?random=6"
    },
    {
        "title": "The Matrix",
        "description": "A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.",
        "genre": "Sci-Fi",
        "rating": 8.7,
        "duration": 136,
        "image_url": "https://picsum.photos/200/300?random=7"
    },
    {
        "title": "Titanic",
        "description": "A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.",
        "genre": "Romance",
        "rating": 7.9,
        "duration": 194,
        "image_url": "https://picsum.photos/200/300?random=8"
    },
    {
        "title": "The Godfather",
        "description": "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
        "genre": "Crime",
        "rating": 9.2,
        "duration": 175,
        "image_url": "https://picsum.photos/200/300?random=9"
    },
    {
        "title": "Avatar",
        "description": "A paraplegic Marine dispatched to the moon Pandora on a unique mission becomes torn between following his orders and protecting the world he feels is his home.",
        "genre": "Sci-Fi",
        "rating": 7.9,
        "duration": 162,
        "image_url": "https://picsum.photos/200/300?random=10"
    },
    {
        "title": "The Avengers",
        "description": "Earth's mightiest heroes must come together and learn to fight as a team if they are going to stop the mischievous Loki and his alien army from enslaving humanity.",
        "genre": "Action",
        "rating": 8.0,
        "duration": 143,
        "image_url": "https://picsum.photos/200/300?random=11"
    },
    {
        "title": "Jurassic Park",
        "description": "A pragmatic paleontologist visiting an almost complete theme park is tasked with protecting a couple of kids after a power failure causes the park's cloned dinosaurs to run loose.",
        "genre": "Adventure",
        "rating": 8.2,
        "duration": 127,
        "image_url": "https://picsum.photos/200/300?random=12"
    }
    ,
    {
        "title": "3 Idiots",
        "description": "Two friends search for their long-lost companion, recalling their college days and the impact of an extraordinary friend.",
        "genre": "Bollywood",
        "rating": 8.4,
        "duration": 170,
        "image_url": "https://picsum.photos/seed/3idiots/400/600"
    },
    {
        "title": "Dangal",
        "description": "A former wrestler trains his daughters to become world-class wrestlers, challenging social norms along the way.",
        "genre": "Bollywood",
        "rating": 8.3,
        "duration": 161,
        "image_url": "https://picsum.photos/seed/dangal/400/600"
    },
    {
        "title": "RRR",
        "description": "A fictional tale of two legendary revolutionaries and their journey away from home before they started fighting for their country.",
        "genre": "Bollywood",
        "rating": 8.0,
        "duration": 187,
        "image_url": "https://picsum.photos/seed/rrr/400/600"
    },
    {
        "title": "Pathaan",
        "description": "An Indian spy takes on a dangerous mission to stop a major threat to national security.",
        "genre": "Bollywood",
        "rating": 6.7,
        "duration": 146,
        "image_url": "https://picsum.photos/seed/pathaan/400/600"
    },
    {
        "title": "Zindagi Na Milegi Dobara",
        "description": "Three friends embark on a road trip that changes their lives, confronting fears and discovering themselves.",
        "genre": "Bollywood",
        "rating": 8.2,
        "duration": 155,
        "image_url": "https://picsum.photos/seed/znmd/400/600"
    }
]

def seed_movies():
    """Add movies to database if they don't already exist"""
    try:
        for movie_data in movies_data:
            # Check if movie already exists
            existing_movie = db.query(Movie).filter(Movie.title == movie_data["title"]).first()
            if not existing_movie:
                movie = Movie(**movie_data)
                db.add(movie)
                print(f"Added movie: {movie_data['title']}")
            else:
                print(f"Movie already exists: {movie_data['title']}")

        db.commit()
        print("✅ Database seeded successfully!")

    except Exception as e:
        print(f"❌ Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_movies()