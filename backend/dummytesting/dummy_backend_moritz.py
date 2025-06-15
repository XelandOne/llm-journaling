from fastapi import FastAPI, Query
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
from dummy_mistral import generate_advice

#from mistral import extract_event_and_feeling

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
import random
from datetime import timedelta

ACTIVITIES = [
    "Team Meeting",
    "Project Work",
    "Client Call",
    "Code Review",
    "Presentation Preparation",
    "Workout Session",
    "Grocery Shopping",
    "Study Session",
    "Meditation",
    "Dinner with Friends",
    "Strategy Planning",
    "Weekly Review",
]

def generate_dummy_events():
    events = []
    for i in range((END_DATE - START_DATE).days):
        day = START_DATE + timedelta(days=i)
        num_events = random.randint(1, 3)  # 1-3 events pro Tag

        for j in range(num_events):
            start_hour = random.randint(7, 17)
            start = day + timedelta(hours=start_hour)
            end = start + timedelta(hours=1)

            description = random.choice(ACTIVITIES)
            tag = random.choice(TAGS)

            events.append(
                Event(
                    date=day.strftime("%Y-%m-%d"),
                    startTime=start.isoformat(),
                    endTime=end.isoformat(),
                    description=description,
                    tags=[tag],
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
print(DUMMY_EVENTS)
DUMMY_FEELINGS = generate_dummy_feelings()


# --- Endpoints ---
#@app.post("/lifeChat")
#def submit_life_chat(chat: dict):
    #result = extract_event_and_feeling(chat['chat'])
    #return result


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
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)

    # Filtere die Dummy Events
    events = [
        e.model_dump() for e in DUMMY_EVENTS if start <= datetime.fromisoformat(e.startTime) < end
    ]

    # Filtere die Dummy Feelings
    feelings = [
        f.model_dump() for f in DUMMY_FEELINGS if start <= datetime.fromisoformat(f.datetime) < end
    ]

    # Falls keine Daten vorhanden, gib kurze Message zurück
    if not events and not feelings:
        return "No data for this period. Try to log more events and feelings!"

    # Generiere das AI-basierte Advice mit Mistral
    advice = generate_advice(events, feelings)

    return advice

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
