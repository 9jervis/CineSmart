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


# 📋 GET USER BOOKINGS (🔥 NEW API FOR PROFILE)
@router.get("/user/{user_id}")
def get_user_bookings(user_id: int, db: Session = Depends(get_db)):
    from app.models.booking import Booking
    from app.models.movie import Movie
    
    bookings = db.query(Booking).filter(Booking.user_id == user_id).all()
    
    result = []
    for booking in bookings:
        movie = db.query(Movie).filter(Movie.id == booking.movie_id).first()
        if movie:
            result.append({
                "id": booking.id,
                "user_id": booking.user_id,
                "movie_id": booking.movie_id,
                "movie_title": movie.title,
                "movie_image": movie.image_url,
                "show_time": booking.show_time,
                "seats": booking.seats,
                "total_price": booking.total_price,
            })
    
    return result


# ❌ CANCEL BOOKING
@router.delete("/{booking_id}")
def cancel_booking(booking_id: int, db: Session = Depends(get_db)):
    from app.models.booking import Booking
    
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    # Free up the seats
    seat_numbers = [s.strip() for s in booking.seats.split(",")]
    for seat_num in seat_numbers:
        seat = db.query(Seat).filter(
            Seat.movie_id == booking.movie_id,
            Seat.show_time == booking.show_time,
            Seat.seat_number == seat_num,
        ).first()
        if seat:
            seat.is_booked = False
    
    db.delete(booking)
    db.commit()
    
    return {"message": "Booking cancelled successfully", "id": booking_id}


print("Booking router loaded")