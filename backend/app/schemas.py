from pydantic import BaseModel, EmailStr, model_validator
from typing import Optional


# --- User Schemas ---

class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    confirm_password: str
    dob: str
    gender: str
    role: str
    disability_status: Optional[str] = None  # for dependent
    experience: Optional[str] = None         # for volunteer

    @model_validator(mode='after')
    def check_passwords_match(self) -> 'UserCreate':
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match")
        return self


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    dob: str
    gender: str
    role: str
    disability_status: Optional[str] = None
    experience: Optional[str] = None

    class Config:
        from_attributes = True


class RegistrationSuccessResponse(BaseModel):
    message: str
    user: UserResponse


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


# --- Task Schemas ---

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    completed: bool = False


class TaskCreate(TaskBase):
    pass


class TaskOut(TaskBase):
    id: int

    class Config:
        from_attributes = True