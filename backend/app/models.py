from sqlalchemy import Column, Integer, String, ForeignKey, Text
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    dob = Column(String)
    gender = Column(String)
    role = Column(String)  # "volunteer" or "dependent"
    disability_status = Column(String, nullable=True)
    experience = Column(String, nullable=True)

    tasks = relationship("Task", back_populates="user")

class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    priority = Column(String, nullable=False)
    status = Column(String, default="pending", nullable=False)
    task_type = Column(String, nullable=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    user = relationship("User", back_populates="tasks")
