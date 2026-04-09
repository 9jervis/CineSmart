from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from app.core.database import Base


class Seat(Base):
    __tablename__ = "seats"

    id = Column(Integer, primary_key=True, index=True)
    movie_id = Column(Integer, ForeignKey("movies.id"))
    show_time = Column(String)
    seat_number = Column(String)  # A1, A2
    is_booked = Column(Boolean, default=False)