from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.schemas.user_schema import UserCreate, UserResponse
from app.services.auth_service import create_user, authenticate_user
from app.core.config import get_db

router = APIRouter(prefix="/auth", tags=["Auth"])


class LoginRequest(BaseModel):
    email: str
    password: str


@router.post("/signup", response_model=UserResponse)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    return create_user(db, user.name, user.email, user.password)


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    print(data.email, data.password)  # debug
    db_user = authenticate_user(db, data.email, data.password)

    if not db_user:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    return {
        "message": "Login successful",
        "user_id": db_user.id,
        "name": db_user.name,
        "email": db_user.email,
    }