from datetime import datetime
import os
from typing import List

from fastapi import FastAPI, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
import uvicorn

from database_integration.database import SessionLocal, engine
from database_integration import models
from mistral import mistral_client, lifeChat, extract_event_and_feeling
from dotenv import load_dotenv

load_dotenv()

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

class Event(BaseModel):
    date: str
    startTime: str
    endTime: str
    description: str
    tags: List[str]
    name: str

class Feeling(BaseModel):
    feelings: List[str]
    score: int = Field(..., ge=1, le=10)
    datetime: str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/getEvents")
def get_events(startTime: str = Query(...), endTime: str = Query(...), db: Session = Depends(get_db)):
    events = db.query(models.Event).filter(
        models.Event.startTime >= startTime,
        models.Event.startTime < endTime
    ).all()
    return events

@app.post("/addEvent")
def add_event(event: Event, db: Session = Depends(get_db)):
    new_event = models.Event(
        date=event.date,
        startTime=event.startTime,
        endTime=event.endTime,
        description=event.description,
        tags=",".join(event.tags),
        name=event.name
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event

@app.post("/addFeeling")
def add_feeling(feelings: str, score: int, db: Session = Depends(get_db)):
    new_feeling = models.Feeling(
        feelings=feelings,
        score=score,
        datetime=datetime.now()
    )
    db.add(new_feeling)
    db.commit()
    db.refresh(new_feeling)
    return new_feeling

@app.get("/getAllFeelings")
def get_all_feelings(db: Session = Depends(get_db)):
    feelings = db.query(models.Feeling).all()
    return feelings

@app.get("/getFeelings")
def get_feelings(startTime: str = Query(...), endTime: str = Query(...), db: Session = Depends(get_db)):
    feelings = db.query(models.Feeling).filter(
        models.Feeling.datetime >= startTime,
        models.Feeling.datetime < endTime
    ).all()
    return feelings

@app.get("/getAdvice")
def get_advice(startTime: str = Query(...), endTime: str = Query(...), db: Session = Depends(get_db)):
    events = db.query(models.Event).filter(
        models.Event.startTime >= startTime,
        models.Event.startTime < endTime
    ).all()
    feelings = db.query(models.Feeling).filter(
        models.Feeling.datetime >= startTime,
        models.Feeling.datetime < endTime
    ).all()
    
    if not events and not feelings:
        return "No data for this period. Try to log more events and feelings!"
    
    events_data = [{
        "date": e.date,
        "startTime": e.startTime,
        "endTime": e.endTime,
        "description": e.description,
        "tags": e.tags.split(",") if e.tags else [],
        "name": e.name
    } for e in events]
    
    feelings_data = [{
        "feelings": f.feelings.split(",") if f.feelings else [],
        "score": f.score,
        "datetime": f.datetime.isoformat()
    } for f in feelings]
    
    response = mistral_client.chat(
        model="mistral-tiny",
        messages=[{
            "role": "system",
            "content": "You are a helpful journaling assistant. Analyze the user's events and feelings, and provide personalized advice and insights."
        }, {
            "role": "user",
            "content": f"Here are my events: {events_data}\nAnd my feelings: {feelings_data}\nPlease provide some advice and insights."
        }]
    )
    return response.choices[0].message.content

@app.post("/lifeChat")
def life_chat(chat: dict):
    content, created_events, created_feelings = lifeChat([{
        "role": "user",
        "content": chat["chat"]
    }])
    
    response = {
        "response": content,
        "created_events": created_events,
        "feeling": created_feelings
    }
    return response

@app.get("/getMotivationalSpeech")
def get_motivational_speech(startTime: str = Query(...), endTime: str = Query(...), db: Session = Depends(get_db)):
    events = db.query(models.Event).filter(
        models.Event.startTime >= startTime,
        models.Event.startTime < endTime
    ).all()
    feelings = db.query(models.Feeling).filter(
        models.Feeling.datetime >= startTime,
        models.Feeling.datetime < endTime
    ).all()
    
    if not events and not feelings:
        return "No data for this period. Try to log more events and feelings!"
    
    events_data = [{
        "date": e.date,
        "startTime": e.startTime,
        "endTime": e.endTime,
        "description": e.description,
        "tags": e.tags.split(",") if e.tags else [],
        "name": e.name
    } for e in events]
    
    feelings_data = [{
        "feelings": f.feelings.split(",") if f.feelings else [],
        "score": f.score,
        "datetime": f.datetime.isoformat()
    } for f in feelings]
    
    response = mistral_client.chat(
        model="mistral-tiny",
        messages=[{
            "role": "system",
            "content": "You are a motivational speaker. Create a short, inspiring speech based on the user's events and feelings."
        }, {
            "role": "user",
            "content": f"Here are my events: {events_data}\nAnd my feelings: {feelings_data}\nPlease create a motivational speech."
        }]
    )
    return response.choices[0].message.content

if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
