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

def call_mistral(messages, model="magistral-medium-2506"):
    response = client.chat.complete(
        model=model,
        messages=messages,
        tools=[
               aci.functions.get_definition("GOOGLE_CALENDAR__EVENTS_INSERT")
               ],
        tool_choice="required",
        max_tokens=4096,
        prompt_mode=None
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
    
    # Clean up the response content by removing quotes if present
    content = response.choices[0].message.content
    if content.startswith('"') and content.endswith('"'):
        content = content[1:-1]
    return content

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

def generate_advice(events: list) -> str:
    prompt = f"""
    Here are the user's events:
    {json.dumps(events, indent=2)}
    
    Please provide personal, supportive advice.
    Provide advice based on events. 
    Please return some advices for the user to achieve their goals.
    Please return a list of advices of maximum 3.
    Format your response in markdown for each advice.
    Do not preamble. Just return the advices.
    Return concise and short advices.
    """

    messages = [{"role": "system", "content": "You are a life coach and you are helping the user to achieve their deadlines. Always format your responses in markdown."}, {"role": "user", "content": prompt}]

    chat_response = client.chat.complete(
            model="mistral-large-latest",
            messages=messages,
            temperature=0.3,
            max_tokens=500
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
    return call_mistral([system, user], model="mistral-large-latest", max_tokens=500)


if __name__ == "__main__":
    from dummytesting.dummy_backend_moritz import generate_dummy_events
    events = generate_dummy_events()

    print(generate_advice(events=events))
