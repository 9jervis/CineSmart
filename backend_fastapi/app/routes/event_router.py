from fastapi import APIRouter
from typing import List

from app.schemas.event_schema import EventResponse

router = APIRouter(prefix="/events", tags=["Events"])

# Sample latest event data. These are returned in reverse chronological order.
events = [
    {
        "id": 1,
        "title": "Dacoit: Live Action Experience",
        "venue": "INOX: R-City, Ghatkopar",
        "city": "Mumbai",
        "date": "2026-04-11",
        "time": "04:00 PM",
        "category": "Movie Premiere",
        "price": 550,
        "image_url": "https://picsum.photos/300/180?random=21",
        "description": "Watch the action thriller with immersive sound and premium seating.",
        "show_times": ["10:15 AM", "04:00 PM", "10:30 PM"]
    },
    {
        "id": 2,
        "title": "Comedy Nights Live",
        "venue": "PVR: Phoenix Marketcity",
        "city": "Mumbai",
        "date": "2026-04-12",
        "time": "08:00 PM",
        "category": "Comedy",
        "price": 350,
        "image_url": "https://picsum.photos/300/180?random=22",
        "description": "A live stand-up comedy evening with the city’s top comedians.",
        "show_times": ["06:30 PM", "08:00 PM", "09:30 PM"]
    },
    {
        "id": 3,
        "title": "Bollywood Premiere: Star Saga",
        "venue": "Cinepolis: Seawoods",
        "city": "Mumbai",
        "date": "2026-04-13",
        "time": "09:00 PM",
        "category": "Premiere",
        "price": 650,
        "image_url": "https://picsum.photos/300/180?random=23",
        "description": "Premiere screening with special guest appearances and fan interaction.",
        "show_times": ["06:00 PM", "09:00 PM", "11:30 PM"]
    },
    {
        "id": 4,
        "title": "Live Concert: Rhythm Nights",
        "venue": "Nehru Centre",
        "city": "Mumbai",
        "date": "2026-04-10",
        "time": "07:30 PM",
        "category": "Music",
        "price": 450,
        "image_url": "https://picsum.photos/300/180?random=24",
        "description": "An unforgettable live music experience with top artists.",
        "show_times": ["05:30 PM", "07:30 PM", "09:30 PM"]
    },
    {
        "id": 5,
        "title": "Drama Premiere: Stage Stories",
        "venue": "Prithvi Theatre",
        "city": "Mumbai",
        "date": "2026-04-14",
        "time": "06:00 PM",
        "category": "Theatre",
        "price": 400,
        "image_url": "https://picsum.photos/300/180?random=25",
        "description": "A gripping live drama with talented performers and immersive storytelling.",
        "show_times": ["04:00 PM", "06:00 PM", "08:30 PM"]
    },
    {
        "id": 6,
        "title": "Sports Screening: IPL Final",
        "venue": "INOX: Raghuleela Mall",
        "city": "Mumbai",
        "date": "2026-04-15",
        "time": "07:00 PM",
        "category": "Sports",
        "price": 300,
        "image_url": "https://picsum.photos/300/180?random=26",
        "description": "Watch the IPL final live on a giant screen with stadium vibes.",
        "show_times": ["04:00 PM", "07:00 PM", "10:00 PM"]
    },
    {
        "id": 7,
        "title": "Classical Evening",
        "venue": "Shanmukhananda Hall",
        "city": "Mumbai",
        "date": "2026-04-16",
        "time": "07:30 PM",
        "category": "Music",
        "price": 500,
        "image_url": "https://picsum.photos/300/180?random=27",
        "description": "A soothing evening of Indian classical music performances.",
        "show_times": ["05:30 PM", "07:30 PM", "09:30 PM"]
    }
]

@router.get("/", response_model=List[EventResponse])
def get_events():
    return events
