from sqlalchemy.orm import Session
from app.models.booking import Booking
from app.models.seat import Seat

def create_booking(db: Session, data):
    # Step 1: Check if seats already booked
    for seat in data.seats:
        existing = db.query(Seat).filter(
            Seat.movie_id == data.movie_id,
            Seat.show_time == data.show_time,
            Seat.seat_number == seat,
            Seat.is_booked == True
        ).first()

        if existing:
            return None  # seat already taken

    # Step 2: Mark seats as booked
    for seat in data.seats:
        seat_obj = db.query(Seat).filter(
            Seat.movie_id == data.movie_id,
            Seat.show_time == data.show_time,
            Seat.seat_number == seat
        ).first()

        if not seat_obj:
            seat_obj = Seat(
                movie_id=data.movie_id,
                show_time=data.show_time,
                seat_number=seat,
                is_booked=True
            )
            db.add(seat_obj)
        else:
            seat_obj.is_booked = True

    # Step 3: Create booking
    booking = Booking(
        user_id=data.user_id,
        movie_id=data.movie_id,
        show_time=data.show_time,
        seats=",".join(data.seats),
        total_price=data.total_price
    )

    db.add(booking)
    db.commit()
    db.refresh(booking)

    return booking