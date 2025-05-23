from pydantic import BaseModel

class UserCreate(BaseModel):
    full_name: str
    email: str
    password: str
    dob: str
    gender: str
    disability_status: str

class UserLogin(BaseModel):
    email: str
    password: str
