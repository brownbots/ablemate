from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import SessionLocal
from .schemas import UserCreate, UserLogin, UserResponse, TokenResponse, RegistrationSuccessResponse
from . import models
import hashlib

router = APIRouter(tags=["Authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

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

    return {
        "message": "User registered successfully",
        "user": UserResponse.model_validate(new_user)
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

    # TODO: Generate real JWT token here instead of dummy token
    token = "generated_jwt_token_here"

    return {
        "message": "Login successful",
        "access_token": token,
        "token_type": "bearer"
    }

# This is the missing get_current_user dependency to fix your import error:

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # For now, a dummy implementation that accepts the dummy token from login
    if token != "generated_jwt_token_here":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Find user by token - since token is dummy, just return the first user or dummy user
    user = db.query(models.User).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user
