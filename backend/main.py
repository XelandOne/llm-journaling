from fastapi import FastAPI, Query, Body
from typing import List, Optional
from datetime import datetime, date
import uvicorn
from database import SessionLocal, Base, engine
import models as models
# from backend.mistral import extract_event_and_feeling, generate_advice
from sqlalchemy.orm import Session
from fastapi import Depends
from mistralai.client import MistralClient
from mistralai.models.chat_completion import ChatMessage
import os
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv

load_dotenv()

Base.metadata.create_all(bind=engine)

app = FastAPI(title="LifeChat API", description="API for logging and analyzing life events and feelings.", version="1.0.0")

mistral_client = MistralClient(api_key=os.getenv('MISTRAL_API_KEY'))

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"message": "Welcome to the LifeChat API! Use the endpoints to log events and feelings, and get advice."}

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

@app.get("/getAllEvents")
def get_events(
    db: Session = Depends(get_db)
):
    events = db.query(models.Event).all()
    return events

@app.get("/getAllFeelings")
def get_feelings(
    db: Session = Depends(get_db)
):
    feelings = db.query(models.Feeling).all()
    return feelings


@app.get("/getAdvice")
async def get_advice(startTime: datetime, endTime: datetime, db: Session = Depends(get_db)):
    """
    Get advice based on events and feelings in a date range.
    """
    events_db = db.query(models.Event).filter(
        models.Event.startTime >= startTime,
        models.Event.endTime <= endTime
    ).all()

    feelings_db = db.query(models.Feeling).filter(
        models.Feeling.datetime >= startTime,
        models.Feeling.datetime <= endTime
    ).all()

    context = f"""
    Events in the period:
    {[event.description for event in events_db]}
    
    Feelings in the period:
    {[feeling.feelings for feeling in feelings_db]}
    """
    
    messages = [
        ChatMessage(role="system", content="""You are a helpful life coach. 
        Based on the user's events and feelings, provide specific, actionable advice.
        Keep the advice concise and practical."""),
        ChatMessage(role="user", content=context)
    ]
    
    response = mistral_client.chat(
        model="mistral-large",
        messages=messages
    )
    
    return response.choices[0].message.content

@app.post("/lifeChat")
async def submit_life_chat(chat: dict, db: Session = Depends(get_db)):
    """
    Process a life chat entry and extract event and feeling information.
    """
    try:
        messages = [
            ChatMessage(role="system", content="""Extract event and feeling information from the user's chat.
            Return a JSON with two objects: 'event' and 'feeling'.
            Event should include date, startTime, endTime, description, and tags.
            Feeling should include feelings (list of emotions), score (1-10), and datetime."""),
            ChatMessage(role="user", content=chat["chat"])
        ]
        
        response = mistral_client.chat(
            model="mistral-large",
            messages=messages
        )
        
        extracted_data = eval(response.choices[0].message.content)
        
        event = Event(**extracted_data["event"])
        feeling = Feeling(**extracted_data["feeling"])
        
        db.add(event)
        db.add(feeling)
        db.commit()
        db.refresh(event)
        
        return {"event": event, "feeling": feeling}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)