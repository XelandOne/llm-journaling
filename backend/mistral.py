# mistral_api.py
from datetime import datetime
import os
import json
from typing import Tuple, List

import pytz
from aci.types.enums import FunctionDefinitionFormat
from mistralai import Mistral
from dotenv import load_dotenv

from schemes import Event, Feeling
from gcal import aci
from openai import OpenAI

load_dotenv()
MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY", "xxx")

mistral_client = Mistral(api_key=MISTRAL_API_KEY)
openai_client = OpenAI()

def google_event_to_event(event_data) -> Event:
    def strip_timezone(dt_str):
        # Remove timezone info if present (e.g., 2024-06-13T10:00:00+02:00 or 2024-06-13T10:00:00Z)
        if "+" in dt_str:
            return dt_str.split("+")[0]
        if "Z" in dt_str:
            return dt_str.replace("Z", "")
        return dt_str

    return Event(
        date=event_data["start"]["dateTime"][:10],
        startTime=strip_timezone(event_data["start"]["dateTime"]),
        endTime=strip_timezone(event_data["end"]["dateTime"]),
        description=event_data.get("summary", ""),
        tags=["calendar"],
        name=event_data.get("summary", ""),
    )

# --- Custom Tool for Feeling Extraction ---
def extract_feeling_from_log(feelings=None, score=None) -> dict:
    """
    Dummy implementation: Extracts a Feeling from a log string.
    Returns a dict with keys: feelings (list), score (int), datetime (str).
    Accepts optional arguments to create a Feeling entry.
    """
    from schemes import Feeling
    datetime_val = datetime.now().isoformat()
    feeling_obj = Feeling(
        feelings=feelings,
        score=score,
        datetime=datetime_val
    )
    return feeling_obj.model_dump()

# Tool definition for OpenAI
feeling_tool = {
    "type": "function",
    "function": {
        "name": "extract_feeling_from_log",
        "description": "Extracts a feeling from a user log. Always call this if the user utters how he feels.",
        "parameters": {
            "type": "object",
            "properties": {
                "feelings": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "A list of feelings or emotions expressed by the user."
                },
                "score": {
                    "type": "integer",
                    "description": "A score representing the intensity of the feeling (1-10)."
                }
            },
            "required": ["feelings", "score"]
        }
    }
}

def lifeChat(messages, model="gpt-4.1") -> Tuple[str, List[Event]]:
    tools=[
        aci.functions.get_definition("GOOGLE_CALENDAR__EVENTS_INSERT"),
        aci.functions.get_definition("GOOGLE_CALENDAR__EVENTS_LIST"),
        feeling_tool,  # Register the custom feeling extraction tool
    ]
    response = openai_client.chat.completions.create(
        model=model,
        messages=messages,
        tools=tools,
        tool_choice="required",
    )
    tool_calls = (
        response.choices[0].message.tool_calls
        if response.choices[0].message.tool_calls
        else None
    )

    created_events = []
    created_feelings = []  # Collect extracted feelings
    for tool_call in tool_calls:
        if tool_call.function.name == "extract_feeling_from_log":
            result = extract_feeling_from_log(**json.loads(tool_call.function.arguments))
            created_feelings.append(result)
        else:
            result = aci.handle_function_call(
                tool_call.function.name,
                json.loads(tool_call.function.arguments),
                linked_account_owner_id=os.getenv("LINKED_ACCOUNT_OWNER_ID", ""),
            )
            print(result)
            messages.append({"role": "assistant", "tool_calls": [tool_call]})
            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": tool_call.id,
                    "content": json.dumps(result),
                }
            )
            if (
                    tool_call.function.name == "GOOGLE_CALENDAR__EVENTS_INSERT"
                    and result.get("success")
                    and "data" in result
            ):
                created_events.append(google_event_to_event(result["data"]))

    messages[0] =  {
        "role": "system",
        "content": f"Answer the user as a journaling assistant and give him helpful guidance. Also inform him if you added something to his calendar. It is {datetime.now(pytz.timezone('Europe/Berlin')).strftime('%m/%d/%Y %I:%M:%S %p %Z')}.",
    }
    messages[1] = {
        "role": "user",
        "content": f"The request from the user: {messages[1]['content']}",
    }
    response = openai_client.chat.completions.create(
        model=model,
        messages=messages,
    )
    content = response.choices[0].message.content
    return content, created_events, created_feelings

def extract_event_and_feeling(chat: str) -> Tuple[Event, List[Event]]:
    system = {
        "role": "system",
        "content": f"Extract structured Event and Feeling data from a user chat log. Make sure events are atomic and separated. Do not use focus time. Always use orderBy startTime. Make sure to include all required parameters including path. Use timezone Europe/Berlin It is {datetime.now(pytz.timezone('Europe/Berlin')).strftime('%m/%d/%Y %I:%M:%S %p %Z')}.",
    }
    user = {
        "role": "user",
        "content": chat
    }
    response = lifeChat([system, user])
    return response


def generate_advice(events: list, feelings: list) -> str:
    prompt = f"""
    Here are the user's events:
    {json.dumps(events, indent=2)}
    
    Please provide personal, supportive advice.
    Provide advice based on events. 
    Please return some advices for the user to achieve their goals.
    Please return a list of advices of maximum 3.
    IMPORTANT: Format the response in a single line with no newlines. Use bold for each advice.
    Do not preamble. Just return the advices.
    Return concise and short advices.
    """

    messages = [{"role": "system",
                 "content": "You are a life coach and you are helping the user to achieve their deadlines. Always format your responses in markdown."},
                {"role": "user", "content": prompt}]

    chat_response = mistral_client.chat.complete(
        model="mistral-large-latest",
        messages=messages,
        temperature=0.3,
        max_tokens=100
    )
    return chat_response.choices[0].message.content


def generate_motivation(events: list, feelings: list) -> str:
    prompt = f"""
    You are a motivation coach.
    Return a 3 motivational quotes based on the user's events and feelings.
    Events: {json.dumps(events, indent=2)}
    Feelings: {json.dumps(feelings, indent=2)}
    Do not preamble. Just return the quotes.
    Return concise and short quotes.
    """

    messages = [{"role": "system",
                 "content": "You are a motivation coach. Return 3 motivational quotes based on the user's events and feelings."},
                {"role": "user", "content": prompt}]

    chat_response = mistral_client.chat.complete(
        model="mistral-large-latest",
        messages=messages,
        temperature=0.3,
        max_tokens=100
    )
    return chat_response.choices[0].message.content


def generate_advice_from_feeling(feeling: str) -> str:
    system = {
        "role": "system",
        "content": """You are a kind, thoughtful life coach. Always format your responses in markdown.""",
    }
    user = {
        "role": "user",
        "content": f"""
    Here is the user's feeling:
    {feeling}

    Please provide personal, supportive advice.
    Provide advice based on the feeling. 
    Please return some advices for the user to achieve their goals.
    Please return a list of advices of maximum 3.
    Format your response in markdown with each advice as a bullet point.
    Do not preamble. Just return the advices.
    """,
    }
    return lifeChat([system, user], model="mistral-large-latest", max_tokens=500)


if __name__ == "__main__":
    from dummytesting.dummy_backend_moritz import generate_dummy_events

    events = generate_dummy_events()

    print(generate_advice(events=events))
