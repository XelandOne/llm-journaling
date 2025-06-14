# mistral_api.py
import os
import json
from mistralai import Mistral
from dotenv import load_dotenv

load_dotenv()
MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY", "xxx")

client = Mistral(api_key=MISTRAL_API_KEY)

def call_mistral(messages, model="mistral-small", temperature=0.7):
    response = client.chat.complete(
        model=model,
        messages=messages,
        temperature=temperature,
        response_format={"type": "json_object"}
    )
    return response.choices[0].message.content

def extract_event_and_feeling(chat: str) -> dict:
    system = {
        "role": "system",
        "content": "Extract structured Event and Feeling data from a user chat log. Make sure events are atomic and separated",
    }
    user = {
        "role": "user",
        "content": f"""
Chat: "{chat}"

Return a JSON object in this format:
{{
  "event": {{
    "name": "Short name of the event",
    "date": "YYYY-MM-DD",
    "startTime": "YYYY-MM-DDTHH:MM:SS",
    "endTime": "YYYY-MM-DDTHH:MM:SS",
    "description": "...",
    "tags": ["travel", "personal"]
  }},
  "feeling": {{
    "feelings": ["happy", "relaxed"],
    "score": 8,
    "datetime": "YYYY-MM-DDTHH:MM:SS"
  }}
}}""",
    }
    response = call_mistral([system, user])
    return json.loads(response)

def generate_advice(events: list, feelings: list) -> str:
    system = {
        "role": "system",
        "content": "You are a kind, thoughtful life coach. Provide advice based on events and emotional states.",
    }
    user = {
        "role": "user",
        "content": f"""
Here are the user's events:
{json.dumps(events, indent=2)}

Here are the user's feelings:
{json.dumps(feelings, indent=2)}

Please provide personal, supportive advice.""",
    }
    return call_mistral([system, user], temperature=0.9)
