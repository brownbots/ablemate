from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from . import models, schemas
from .database import get_db

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.post("/", response_model=schemas.TaskOut)
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    db_task = models.Task(
        title=task.title,
        description=task.description,
        priority=task.priority,
        status="pending",  # Set default status
        task_type=task.task_type  # Include task type
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@router.get("/", response_model=list[schemas.TaskOut])
def get_tasks(db: Session = Depends(get_db)):
    return db.query(models.Task).all()