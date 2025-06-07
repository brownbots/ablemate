from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    dob = Column(String, nullable=False)
    gender = Column(String, nullable=False)
    role = Column(String, nullable=False)
    disability_status = Column(String, nullable=True)
    experience = Column(String, nullable=True)

    # Explicit foreign_keys usage here
    tasks = relationship("Task", back_populates="user", foreign_keys="Task.user_id")
    volunteer_tasks = relationship("Task", back_populates="volunteer", foreign_keys="Task.volunteer_id")

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    priority = Column(String, nullable=False)
    status = Column(String, default="pending")
    task_type = Column(String, nullable=False)

    user_id = Column(Integer, ForeignKey("users.id"))
    volunteer_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    user = relationship("User", back_populates="tasks", foreign_keys=[user_id])
    volunteer = relationship("User", back_populates="volunteer_tasks", foreign_keys=[volunteer_id])
