from typing import List

from pydantic import BaseModel, Field


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
