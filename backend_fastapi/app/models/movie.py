from sqlalchemy import Column, Integer, String, Float
from app.core.database import Base

class Movie(Base):
    __tablename__ = "movies"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    genre = Column(String)
    rating = Column(Float)
    duration = Column(Integer)  # in minutes
    image_url = Column(String)