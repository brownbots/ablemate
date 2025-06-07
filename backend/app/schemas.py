from pydantic import BaseModel, EmailStr, model_validator, Field
from typing import Optional, List

# --- User Schemas ---

class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    confirm_password: str
    dob: str
    gender: str
    role: str
    disability_status: Optional[str] = None  # For dependents
    experience: Optional[str] = None         # For volunteers

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
    title: str = Field(..., min_length=1, max_length=200, description="Short description/title of the task")
    description: str = Field(..., min_length=1, max_length=1000, description="Detailed description of the task")
    priority: str = Field(..., description="Priority level: low, medium, or high")
    task_type: str = Field(..., description="Type/category of the task")

class TaskCreate(TaskBase):
    """Schema for creating a new task"""
    pass

class TaskOut(TaskBase):
    """Schema for task output/response"""
    id: int
    status: str = Field(default="pending", description="Current status of the task")
    user_id: Optional[int] = None
    user: Optional[UserResponse] = None
    volunteer_id: Optional[int] = None
    volunteer: Optional[UserResponse] = None

    class Config:
        from_attributes = True

class TaskResponse(BaseModel):
    """Response schema for task creation"""
    message: str
    task: TaskOut

class TaskUpdate(BaseModel):
    """Schema for updating task details"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, min_length=1, max_length=1000)
    priority: Optional[str] = None
    task_type: Optional[str] = None
    status: Optional[str] = None

class TaskStatusUpdate(BaseModel):
    """Schema for updating only task status"""
    status: str = Field(..., description="New status for the task")

# --- Health Check Schema ---

class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    message: str
    timestamp: str
