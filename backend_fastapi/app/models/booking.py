from sqlalchemy import Column, Integer, String, ForeignKey
from app.core.database import Base


class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    movie_id = Column(Integer, ForeignKey("movies.id"))
    show_time = Column(String)
    seats = Column(String)  # "A1,A2"
    total_price = Column(Integer)