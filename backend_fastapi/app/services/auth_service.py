from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from fastapi import HTTPException

from app.models.user import User
from app.utils.security import hash_password, verify_password


def create_user(db: Session, name: str, email: str, password: str):
    hashed_pwd = hash_password(password)

    user = User(
        name=name,
        email=email,
        password=hashed_pwd
    )

    try:
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    if not verify_password(password, user.password):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )
    return user
