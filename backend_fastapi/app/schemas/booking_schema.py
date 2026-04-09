from pydantic import BaseModel
from typing import List


class BookingCreate(BaseModel):
    user_id: int
    movie_id: int
    show_time: str
    seats: List[str]
    total_price: int


class BookingResponse(BaseModel):
    id: int
    user_id: int
    movie_id: int
    show_time: str
    seats: str
    total_price: int

    class Config:
        from_attributes = True