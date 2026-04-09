from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.schemas.booking_schema import BookingCreate, BookingResponse
from app.services.booking_service import create_booking
from app.core.config import get_db
from app.models.seat import Seat  # 🔥 NEW IMPORT

router = APIRouter(prefix="/booking", tags=["Booking"])


# 🎟️ BOOK TICKETS
@router.post("/", response_model=BookingResponse)
def book_ticket(data: BookingCreate, db: Session = Depends(get_db)):
    booking = create_booking(db, data)

    if not booking:
        raise HTTPException(status_code=400, detail="Seats already booked")

    return booking


# 🎬 GET BOOKED SEATS (🔥 NEW API)
@router.get("/seats/{movie_id}")
def get_booked_seats(
    movie_id: int,
    show_time: str,
    db: Session = Depends(get_db)
):
    seats = db.query(Seat).filter(
        Seat.movie_id == movie_id,
        Seat.show_time == show_time,
        Seat.is_booked == True
    ).all()

    return [seat.seat_number for seat in seats]


print("Booking router loaded")