from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from dotenv import load_dotenv
import os

# Load environment variables from the .env file
load_dotenv()

# Read the database URL from environment variables
# e.g. postgresql://vectora:vectora@localhost:5432/vectora
DATABASE_URL = os.getenv("DATABASE_URL")

# The "engine" is the actual connection to PostgreSQL
# Think of it as the phone line between Python and the database
engine = create_engine(DATABASE_URL)

# A "session" is a single conversation with the database
# You open a session, do some work, then close it
# SessionLocal is a factory that creates new sessions
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base is the parent class that all our database models will inherit from
# When you create a class that inherits from Base, SQLAlchemy knows
# it represents a database table
class Base(DeclarativeBase):
    pass

# This is a "dependency" — a function FastAPI calls automatically
# to give each request its own database session
# When the request is done, it closes the session (the finally block)
def get_db():
    db = SessionLocal()
    try:
        yield db          # give the session to the endpoint
    finally:
        db.close()        # always close it when done, even if there's an error