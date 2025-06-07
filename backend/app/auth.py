from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .database import SessionLocal
from .schemas import UserCreate, UserLogin, UserResponse, TokenResponse, RegistrationSuccessResponse # Import RegistrationSuccessResponse
from . import models
import hashlib

router = APIRouter(tags=["Authentication"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

@router.post("/register", response_model=RegistrationSuccessResponse, status_code=status.HTTP_201_CREATED)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(models.User).filter(models.User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    new_user = models.User(
        full_name=user.full_name,
        email=user.email,
        password=hash_password(user.password),
        dob=user.dob,
        gender=user.gender,
        role=user.role,
        disability_status=user.disability_status,
        experience=user.experience
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Return the data in the structure expected by RegistrationSuccessResponse
    return {
        "message": "User registered successfully",
        "user": UserResponse.model_validate(new_user) # Use model_validate to convert new_user to UserResponse
    }

@router.post("/login", response_model=TokenResponse)
async def login(user: UserLogin, db: Session = Depends(get_db)):
    hashed = hash_password(user.password)
    db_user = db.query(models.User).filter(
        models.User.email == user.email,
        models.User.password == hashed
    ).first()

    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return {
        "message": "Login successful",
        "access_token": "generated_jwt_token_here",
        "token_type": "bearer"
    }