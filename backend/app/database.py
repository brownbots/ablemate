from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

DATABASE_URL = "postgresql://sid:2004@localhost:5432/ablemate_db?sslmode=disable"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)
Base = declarative_base()

# ✅ Add this function
def get_db():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()
