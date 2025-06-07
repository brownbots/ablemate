from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.auth import router as auth_router
from app.tasks import router as tasks_router
from app.database import Base, engine

app = FastAPI()

# CORS for Flutter frontend (adjust if needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or replace with ["http://localhost:your_flutter_port"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Correct route prefixing
app.include_router(auth_router, prefix="/api/auth")   # final: /api/auth/register, /api/auth/login
app.include_router(tasks_router, prefix="/api/tasks") # e.g. /api/tasks/request

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)
