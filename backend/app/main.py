from fastapi import FastAPI
from . import auth
from .database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI()
app.include_router(auth.router)
