from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date
from mistralai.client import MistralClient
from mistralai.models.chat_completion import ChatMessage
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title="LifeChat API",
    description="API for logging and analyzing life events and feelings.",
    version="1.0.0"
)

# Initialize Mistral client
mistral_client = MistralClient(api_key=os.getenv('MISTRAL_API_KEY'))

# Pydantic models matching the OpenAPI spec
class Event(BaseModel):
    date: date
    startTime: datetime
    endTime: datetime
    description: str
    tags: List[str] = Field(..., description="List of tags for the event")

class Feeling(BaseModel):
    feelings: List[str] = Field(..., description="List of emotional states")
    score: int = Field(..., ge=1, le=10)
    datetime: datetime

events_db = []
feelings_db = []

@app.post("/lifeChat")
async def submit_life_chat(chat: dict):
    """
    Process a life chat entry and extract event and feeling information.
    """
    try:
        # Use Mistral AI to analyze the chat and extract structured information
        messages = [
            ChatMessage(role="system", content="""Extract event and feeling information from the user's chat.
            Return a JSON with two objects: 'event' and 'feeling'.
            Event should include date, startTime, endTime, description, and tags.
            Feeling should include feelings (list of emotions), score (1-10), and datetime."""),
            ChatMessage(role="user", content=chat["chat"])
        ]
        
        response = mistral_client.chat(
            model="mistral-small",
            messages=messages
        )
        
        extracted_data = eval(response.choices[0].message.content)
        
        event = Event(**extracted_data["event"])
        feeling = Feeling(**extracted_data["feeling"])
        
        # Store the data
        events_db.append(event)
        feelings_db.append(feeling)
        
        return {"event": event, "feeling": feeling}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/getEvents")
async def get_events(startTime: datetime, endTime: datetime):
    """
    Get events between two datetimes.
    """
    filtered_events = [
        event for event in events_db
        if startTime <= event.startTime <= endTime
    ]
    return filtered_events

@app.get("/getFeelings")
async def get_feelings(startTime: datetime, endTime: datetime):
    """
    Get feelings between two datetimes.
    """
    filtered_feelings = [
        feeling for feeling in feelings_db
        if startTime <= feeling.datetime <= endTime
    ]
    return filtered_feelings

@app.get("/getAdvice")
async def get_advice(startTime: datetime, endTime: datetime):
    """
    Get advice based on events and feelings in a date range.
    """
    # Get relevant events and feelings
    relevant_events = [
        event for event in events_db
        if startTime <= event.startTime <= endTime
    ]
    relevant_feelings = [
        feeling for feeling in feelings_db
        if startTime <= feeling.datetime <= endTime
    ]
    
    # Prepare context for the AI
    context = f"""
    Events in the period:
    {[event.description for event in relevant_events]}
    
    Feelings in the period:
    {[feeling.feelings for feeling in relevant_feelings]}
    """
    
    # Get advice from Mistral AI
    messages = [
        ChatMessage(role="system", content="""You are a helpful life coach. 
        Based on the user's events and feelings, provide specific, actionable advice.
        Keep the advice concise and practical."""),
        ChatMessage(role="user", content=context)
    ]
    
    response = mistral_client.chat(
        model="mistral-small",
        messages=messages
    )
    
    return response.choices[0].message.content

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 