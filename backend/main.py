from fastapi import FastAPI, Query, Body
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date

from mistral import extract_event_and_feeling, generate_advice


app = FastAPI(title="LifeChat API", description="API for logging and analyzing life events and feelings.", version="1.0.0")

# Enums and constants
EVENT_TAGS = ["work", "social", "health", "personal", "family", "travel", "education", "other"]
FEELING_ENUM = ["calm", "motivated", "stressed", "anxious", "happy", "sad", "angry", "relaxed", "excited", "tired"]

# Models
class Event(BaseModel):
    date: date
    startTime: datetime
    endTime: datetime
    description: str
    tags: List[str] = Field(..., example=["work", "social"])

class Feeling(BaseModel):
    feelings: List[str] = Field(..., example=["happy", "calm"])
    score: int = Field(..., ge=1, le=10)
    datetime: datetime

class ChatEntry(BaseModel):
    chat: str = Field(..., example="I felt happy during my vacation.")

# Mocked database
events_db = []
feelings_db = []

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