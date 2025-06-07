from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.auth import router as auth_router
from app.tasks import router as tasks_router
from app.database import Base, engine
import uvicorn

app = FastAPI(title="AbleMate API", version="1.0.0")

# CORS for Flutter frontend - allow all origins for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])
app.include_router(tasks_router, prefix="/api/tasks", tags=["Tasks"])

# Root endpoint for testing
@app.get("/")
async def root():
    return {"message": "AbleMate API is running!", "status": "ok"}

# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "API is working properly"}

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)
    print("Database tables created successfully!")
    print("AbleMate API started successfully!")

if __name__ == "__main__":
    # This ensures the server binds to all network interfaces (0.0.0.0)
    # so it can accept connections from other devices on the network
    uvicorn.run(
        "main:app", 
        host="0.0.0.0",  # This is crucial for accepting external connections
        port=8000, 
        reload=True
    )