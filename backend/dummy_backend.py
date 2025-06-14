from fastapi import FastAPI, Query
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware

from mistral import extract_event_and_feeling

app = FastAPI(
    title="LifeChat API",
    description="API for logging and analyzing life events and feelings.",
    version="1.0.0",
)

# Allow CORS for local frontend testing
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- Schemas ---
class Event(BaseModel):
    date: str
    startTime: str
    endTime: str
    description: str
    tags: List[str]


class Feeling(BaseModel):
    feelings: List[str]
    score: int = Field(..., ge=1, le=10)
    datetime: str


# --- Dummy Data Generation ---
TAGS = [
    "work",
    "social",
    "health",
    "personal",
    "family",
    "travel",
    "education",
    "other",
]
FEELINGS = [
    "calm",
    "motivated",
    "stressed",
    "anxious",
    "happy",
    "sad",
    "angry",
    "relaxed",
    "excited",
    "tired",
]

START_DATE = datetime(2025, 6, 1)
END_DATE = datetime(2025, 7, 1)


# Generate dummy events and feelings for each day in the range
def generate_dummy_events():
    events = []
    for i in range((END_DATE - START_DATE).days):
        day = START_DATE + timedelta(days=i)
        # 1-2 events per day
        for j in range(1, 3):
            start = day + timedelta(hours=8 + j * 2)
            end = start + timedelta(hours=1)
            events.append(
                Event(
                    date=day.strftime("%Y-%m-%d"),
                    startTime=start.isoformat(),
                    endTime=end.isoformat(),
                    description=f"Dummy event {j} on {day.strftime('%Y-%m-%d')}",
                    tags=[TAGS[(i + j) % len(TAGS)]],
                )
            )
    return events


def generate_dummy_feelings():
    feelings = []
    for i in range((END_DATE - START_DATE).days):
        day = START_DATE + timedelta(days=i)
        # 1-2 feelings per day
        for j in range(1, 3):
            dt = day + timedelta(hours=10 + j * 3)
            feelings.append(
                Feeling(
                    feelings=[FEELINGS[(i + j) % len(FEELINGS)]],
                    score=5 + ((i + j) % 6),
                    datetime=dt.isoformat(),
                )
            )
    return feelings


DUMMY_EVENTS = generate_dummy_events()
DUMMY_FEELINGS = generate_dummy_feelings()


# --- Endpoints ---
@app.post("/lifeChat")
def submit_life_chat(chat: str):
    result = extract_event_and_feeling(chat)
    return result


@app.get("/getEvents", response_model=List[Event])
def get_events(startTime: str = Query(...), endTime: str = Query(...)):
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)
    return [
        e for e in DUMMY_EVENTS if start <= datetime.fromisoformat(e.startTime) < end
    ]


@app.get("/getFeelings", response_model=List[Feeling])
def get_feelings(startTime: str = Query(...), endTime: str = Query(...)):
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)
    return [
        f for f in DUMMY_FEELINGS if start <= datetime.fromisoformat(f.datetime) < end
    ]


@app.get("/getAdvice", response_model=str)
def get_advice(startTime: str = Query(...), endTime: str = Query(...)):
    # Dummy advice based on the number of events/feelings in the range
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)
    events = [
        e for e in DUMMY_EVENTS if start <= datetime.fromisoformat(e.startTime) < end
    ]
    feelings = [
        f for f in DUMMY_FEELINGS if start <= datetime.fromisoformat(f.datetime) < end
    ]
    if not events and not feelings:
        return "No data for this period. Try to log more events and feelings!"
    avg_score = sum(f.score for f in feelings) / len(feelings) if feelings else 5
    if avg_score > 7:
        return "You seem to be doing great! Keep up the positive energy."
    elif avg_score > 4:
        return "Things are going okay. Consider focusing on activities that make you happy."
    else:
        return "It looks like you've had a tough time. Reach out to friends or family, and take care of yourself."


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
