from fastapi import FastAPI, Query, Body
from typing import List, Optional
from datetime import datetime, date
import uvicorn
from database import SessionLocal, Base, engine
import backend.models as models
# from backend.mistral import extract_event_and_feeling, generate_advice
from sqlalchemy.orm import Session
from fastapi import Depends


Base.metadata.create_all(bind=engine)

app = FastAPI(title="LifeChat API", description="API for logging and analyzing life events and feelings.", version="1.0.0")


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




if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)