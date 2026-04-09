import pandas as pd
from sqlalchemy.orm import Session
from app.models.booking import Booking

def booking_insights(db: Session):
    bookings = db.query(Booking).all()

    if not bookings:
        return {"message": "No data available"}

    data = [{
        "movie_id": b.movie_id,
        "total_price": b.total_price
    } for b in bookings]

    df = pd.DataFrame(data)

    total_revenue = df["total_price"].sum()
    most_booked = df["movie_id"].value_counts().idxmax()

    return {
        "total_revenue": int(total_revenue),
        "most_booked_movie_id": int(most_booked)
    }