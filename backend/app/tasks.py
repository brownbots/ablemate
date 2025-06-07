from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app import models, schemas
from app.database import get_db
from app.auth import get_current_user

router = APIRouter()

# Create task endpoint - simplified for testing (no auth required)
@router.post("/", response_model=schemas.TaskOut)
def create_task(
    task: schemas.TaskCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new task request without authentication (for testing)
    """
    try:
        print(f"Received task data: {task.model_dump()}")

        valid_priorities = ["low", "medium", "high"]
        if task.priority.lower() not in valid_priorities:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Priority must be one of: {', '.join(valid_priorities)}"
            )

        db_task = models.Task(
            title=task.title,
            description=task.description,
            priority=task.priority.lower(),
            status="pending",
            task_type=task.task_type,
            user_id=1  # Use default user ID for testing
        )

        db.add(db_task)
        db.commit()
        db.refresh(db_task)

        print(f"Task created successfully with ID: {db_task.id}")
        return db_task

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error creating task: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create task: {str(e)}"
        )


# Create task endpoint with authentication
@router.post("/authenticated", response_model=schemas.TaskOut)
def create_authenticated_task(
    task: schemas.TaskCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    Create a new task request with user authentication
    """
    try:
        print(f"Authenticated user {current_user.id} creating task: {task.model_dump()}")

        valid_priorities = ["low", "medium", "high"]
        if task.priority.lower() not in valid_priorities:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Priority must be one of: {', '.join(valid_priorities)}"
            )

        db_task = models.Task(
            title=task.title,
            description=task.description,
            priority=task.priority.lower(),
            status="pending",
            task_type=task.task_type,
            user_id=current_user.id
        )

        db.add(db_task)
        db.commit()
        db.refresh(db_task)

        print(f"Authenticated task created successfully with ID: {db_task.id}")
        return db_task

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error creating authenticated task: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create task: {str(e)}"
        )


@router.get("/", response_model=List[schemas.TaskOut])
def get_all_tasks(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    """Get all tasks (for admin/volunteer view)"""
    try:
        tasks = db.query(models.Task).offset(skip).limit(limit).all()
        print(f"Retrieved {len(tasks)} tasks")
        return tasks
    except Exception as e:
        print(f"Error retrieving tasks: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve tasks"
        )


@router.get("/my-tasks", response_model=List[schemas.TaskOut])
def get_user_tasks(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Get tasks for the authenticated user"""
    try:
        tasks = db.query(models.Task).filter(models.Task.user_id == current_user.id).all()
        print(f"Retrieved {len(tasks)} tasks for user {current_user.id}")
        return tasks
    except Exception as e:
        print(f"Error retrieving user tasks: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve user tasks"
        )


@router.get("/{task_id}", response_model=schemas.TaskOut)
def get_task(
    task_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific task by ID"""
    try:
        task = db.query(models.Task).filter(models.Task.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )
        return task
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error retrieving task {task_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve task"
        )


@router.put("/{task_id}/status")
def update_task_status(
    task_id: int,
    new_status: str,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user)
):
    """Update task status (for volunteers)"""
    try:
        task = db.query(models.Task).filter(models.Task.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )

        valid_statuses = ["pending", "accepted", "in_progress", "completed", "cancelled"]
        if new_status not in valid_statuses:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Status must be one of: {', '.join(valid_statuses)}"
            )

        task.status = new_status

        # ✅ Assign volunteer if status is accepted and user is logged in
        if new_status == "accepted" and current_user:
            task.volunteer_id = current_user.id

        db.commit()
        print(f"Task {task_id} status updated to {new_status}")

        return {
            "message": f"Task status updated to {new_status}",
            "task_id": task_id,
            "new_status": new_status
        }

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error updating task status: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update task status"
        )


@router.delete("/{task_id}")
def delete_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Delete a task (only by the task creator)"""
    try:
        task = db.query(models.Task).filter(models.Task.id == task_id).first()
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )

        if task.user_id != current_user.id and current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own tasks"
            )

        db.delete(task)
        db.commit()

        return {"message": f"Task {task_id} deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error deleting task: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete task"
        )
