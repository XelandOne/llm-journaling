from fastapi import FastAPI, Query
from typing import List
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
from mistral import generate_advice
from mistral import generate_motivation
from schemes import Event, Feeling
from voice import text_to_speech_stream
from fastapi.responses import StreamingResponse

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


# --- Dummy Data Generation ---
ACTIVITY_NAMES = [
    "Team Meeting",
    "Client Call",
    "Code Review",
    "Project Work",
    "Presentation Preparation",
    "Workout Session",
    "Grocery Shopping",
    "Study Session",
    "Meditation",
    "Dinner with Friends",
    "Strategy Planning",
    "Weekly Review",
    "Family Time",
    "Travel Planning",
    "Doctor Appointment",
    "Running",
    "Reading Session",
    "Online Course",
    "Birthday Celebration",
    "Networking Event"
]

TAGS = [
    "work",
    "work",
    "work",
    "work",
    "work",
    "health",
    "personal",
    "education",
    "health",
    "social",
    "planning",
    "planning",
    "family",
    "travel",
    "health",
    "health",
    "personal",
    "education",
    "social",
    "social"
]

ACTIVITY_DESCRIPTION = [
    "Attend a scheduled meeting with the team to discuss project updates and tasks.",
    "Communicate with clients to gather feedback or discuss ongoing projects.",
    "Review and improve codebase for current development tasks.",
    "Focus on implementing project tasks and developing new features.",
    "Prepare slides and materials for the upcoming presentation.",
    "Complete a full workout session for physical health and fitness.",
    "Purchase groceries and household items for the week.",
    "Spend time studying course materials for academic progress.",
    "Relax and reset the mind with a meditation session.",
    "Enjoy an evening meal with friends to socialize and unwind.",
    "Plan strategies for upcoming projects and set clear goals.",
    "Review weekly progress and plan next week's priorities.",
    "Spend quality time with family members at home or on outings.",
    "Organize travel arrangements for upcoming trips or vacations.",
    "Attend a scheduled doctor's appointment for regular health checkups.",
    "Go for a run to improve endurance and physical condition.",
    "Read a book or articles to expand knowledge and relax.",
    "Complete modules in an online course to learn new skills.",
    "Celebrate a birthday with friends or family.",
    "Attend a networking event to connect with new people professionally."
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



def generate_dummy_events():
    events = []
    for i in range((END_DATE - START_DATE).days):
        day = START_DATE + timedelta(days=i)
        num_events = random.randint(3, 3)  # 1-3 events pro Tag

        for j in range(num_events):
            start_hour = random.randint(7, 17)
            start = day + timedelta(hours=start_hour)
            end = start + timedelta(hours=1)

            i = random.randint(0, len(ACTIVITY_NAMES) - 1)
            name = ACTIVITY_NAMES[i]
            description = ACTIVITY_DESCRIPTION[i]
            tag = TAGS[i]

            events.append(
                Event(
                    date=day.strftime("%Y-%m-%d"),
                    startTime=start.isoformat(),
                    endTime=end.isoformat(),
                    description=description,
                    tags=[tag],
                    name=name,
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
@app.post("/lifeChat")
def submit_life_chat(chat: dict):
    response, events, feelings = extract_event_and_feeling(chat['chat'])
    return {
        "response": response,
        "created_events": events,
        "feeling": feelings
    }


@app.get("/getEvents", response_model=List[Event])
def get_events(startTime: str = Query(...), endTime: str = Query(...)):
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)
    return [
        e.model_dump() for e in DUMMY_EVENTS if start <= datetime.fromisoformat(e.startTime) < end
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


@app.get("/getMotivationalSpeech")
def get_motivational_speech(startTime: str = Query(...), endTime: str = Query(...)):
    start = datetime.fromisoformat(startTime)
    end = datetime.fromisoformat(endTime)

    # Filter events and feelings
    events = [
        e.model_dump() for e in DUMMY_EVENTS if start <= datetime.fromisoformat(e.startTime) < end
    ]
    feelings = [
        f.model_dump() for f in DUMMY_FEELINGS if start <= datetime.fromisoformat(f.datetime) < end
    ]

    # If no data, return a default motivational message
    if not events and not feelings:
        text = "No data for this period. Keep going and log more events and feelings to get personalized motivation!"
    else:
        # Generate advice using Mistral
        text = generate_motivation(events, feelings)

    # Convert text to speech
    audio_stream = text_to_speech_stream(text)

    # Return the audio stream
    return StreamingResponse(
        audio_stream,
        media_type="audio/mpeg",
        headers={"Content-Disposition": "attachment; filename=motivational_speech.mp3"}
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
