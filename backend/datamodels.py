from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date


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
