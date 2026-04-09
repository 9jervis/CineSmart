from pydantic import BaseModel
from typing import List

class EventBase(BaseModel):
    title: str
    venue: str
    city: str
    date: str
    time: str
    category: str
    price: int
    image_url: str
    description: str
    show_times: List[str]


class EventResponse(EventBase):
    id: int

    class Config:
        from_attributes = True
