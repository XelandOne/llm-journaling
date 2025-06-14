# mistral_api.py
from datetime import datetime
import os
import json

import pytz
from mistralai import Mistral
from dotenv import load_dotenv

from gcal import aci

load_dotenv()
MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY", "xxx")

client = Mistral(api_key=MISTRAL_API_KEY)

def call_mistral(messages, model="mistral-large-latest"):
    response = client.chat.complete(
        model=model,
        messages=messages,
        # response_format={"type": "json_object"},
        tools=[#aci.functions.get_definition("GOOGLE_CALENDAR__EVENTS_LIST"),
               aci.functions.get_definition("GOOGLE_CALENDAR__EVENTS_INSERT")
               ],
        tool_choice="required",
        # parallel_tool_calls = True
    )
    tool_call = (
        response.choices[0].message.tool_calls[0]
        if response.choices[0].message.tool_calls
        else None
    )

    if tool_call:
        result = aci.handle_function_call(
            tool_call.function.name,
            json.loads(tool_call.function.arguments),
            linked_account_owner_id=os.getenv("LINKED_ACCOUNT_OWNER_ID", "")
        )
        print(result)
    return response.choices[0].message.content

def extract_event_and_feeling(chat: str) -> dict:
    system = {
        "role": "system",
        "content": f"Extract structured Event and Feeling data from a user chat log. Make sure events are atomic and separated. Make sure to include all required parameters including path. Use timezone Europe/Berlin It is {datetime.now(pytz.timezone("Europe/Berlin")).strftime('%m/%d/%Y %I:%M:%S %p %Z')}.",
    }
    user = {
        "role": "user",
        "content": f"""
    Chat: "{chat}"

""",
    }
    response = call_mistral([system, user])
    return json.loads(response)

def generate_advice(events: list, feelings: list) -> str:
    system = {
        "role": "system",
        "content": """You are a kind, thoughtful life coach.
        """,
    }
    user = {
        "role": "user",
        "content": f"""
    Here are the user's events:
    {json.dumps(events, indent=2)}

    Here are the user's feelings:
    {json.dumps(feelings, indent=2)}

    Please provide personal, supportive advice.
    Provide advice based on events and emotional states. 
    Please return some advices for the user to achieve their goals.
    Please return a list of advices of maximum 3.
    Do not preamble. Just return the list of advices.
    """,
    }
    return call_mistral([system, user], temperature=0.3)
