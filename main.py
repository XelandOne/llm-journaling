from fastapi import FastAPI, Query, Body
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date
from backend.datamodels import Event, Feeling, ChatEntry
import uvicorn
from database import Base, engine
import models
from sqlalchemy.orm import Session
from database import SessionLocal
from fastapi import Depends
from mistral import extract_event_and_feeling, generate_advice


app = FastAPI(title="LifeChat API", description="API for logging and analyzing life events and feelings.", version="1.0.0")

# Enums and constants
EVENT_TAGS = ["work", "social", "health", "personal", "family", "travel", "education", "other"]
FEELING_ENUM = ["calm", "motivated", "stressed", "anxious", "happy", "sad", "angry", "relaxed", "excited", "tired"]

# Mocked database
events_db = []
feelings_db = []

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/addEvent")
def add_event(description: str, db: Session = Depends(get_db)):
    new_event = models.Event(
        startTime=datetime.now(),
        endTime=datetime.now(),
        description=description,
        tags="personal"
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event

@app.post("/lifeChat")
def submit_life_chat(entry: ChatEntry):
    result = extract_event_and_feeling(entry.chat)
    extracted_event = Event(**result["event"])
    extracted_feeling = Feeling(**result["feeling"])
    events_db.append(extracted_event)
    feelings_db.append(extracted_feeling)
    return {"event": extracted_event, "feeling": extracted_feeling}

@app.get("/getEvents", response_model=List[Event])
def get_events(startTime: datetime = Query(...), endTime: datetime = Query(...)):
    return [e for e in events_db if startTime <= e.startTime <= endTime]

@app.get("/getFeelings", response_model=List[Feeling])
def get_feelings(startTime: datetime = Query(...), endTime: datetime = Query(...)):
    return [f for f in feelings_db if startTime <= f.datetime <= endTime]

@app.get("/getAdvice", response_model=str)
def get_advice(startTime: datetime = Query(...), endTime: datetime = Query(...)):
    filtered_events = [e.dict() for e in events_db if startTime <= e.startTime <= endTime]
    filtered_feelings = [f.dict() for f in feelings_db if startTime <= f.datetime <= endTime]

    if not filtered_events and not filtered_feelings:
        return "Not enough data to generate advice."

    return generate_advice(filtered_events, filtered_feelings)
