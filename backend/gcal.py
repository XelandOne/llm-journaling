# email : xxx
# password : xxx

import json
import os
from typing import Any, Dict

from aci import ACI
from aci.types.functions import FunctionDefinitionFormat
from dotenv import load_dotenv
from mistralai import Mistral
from rich import print as rprint
from rich.panel import Panel

load_dotenv()
LINKED_ACCOUNT_OWNER_ID = os.getenv("LINKED_ACCOUNT_OWNER_ID", "")
if not LINKED_ACCOUNT_OWNER_ID:
    raise ValueError("LINKED_ACCOUNT_OWNER_ID is not set")


# gets MISTRAL_API_KEY from your environment variables
mistral = Mistral(api_key=os.getenv("MISTRAL_API_KEY"))
# gets ACI_API_KEY from your environment variables
aci = ACI()

def execute_calendar_function(function_name: str, user_message: str) -> Dict[str, Any]:
    """
    Execute a calendar function using Mistral AI and ACI.
    
    Args:
        function_name (str): Name of the calendar function to execute
        user_message (str): Message to send to Mistral AI
        
    Returns:
        Dict[str, Any]: Result of the function execution
    """
    function_definition = aci.functions.get_definition(function_name)
    
    response = mistral.chat.complete(
        model="mistral-large-latest",
        messages=[
            {
                "role": "system",
                "content": "You are a helpful assistant with access to a variety of tools.",
            },
            {
                "role": "user",
                "content": user_message,
            },
        ],
        tools=[function_definition],
        tool_choice="required",
    )
    
    tool_call = (
        response.choices[0].message.tool_calls[0]
        if response.choices[0].message.tool_calls
        else None
    )

    if tool_call:
        result = aci.functions.execute(
            tool_call.function.name,
            json.loads(tool_call.function.arguments),
            linked_account_owner_id=LINKED_ACCOUNT_OWNER_ID,
        )
        return result
    return {}

def get_calendar_events(time_min: str, time_max: str, email: str = "xxx") -> Dict[str, Any]:
    """
    Get calendar events for a specific time range.
    
    Args:
        time_min (str): Start time in ISO format (e.g., "2025-06-01T00:00:00Z")
        time_max (str): End time in ISO format (e.g., "2025-06-30T23:59:59Z")
        email (str): Email address to fetch events for
        
    Returns:
        Dict[str, Any]: Calendar events data
    """
    user_message = f"""
    get all event for user : {email}
    timeMin: {time_min},
    timeMax: {time_max}
    """
    return execute_calendar_function("GOOGLE_CALENDAR__EVENTS_LIST", user_message)

def create_calendar_event(
    summary: str,
    start_time: str,
    end_time: str,
    timezone: str = "Europe/Berlin",
    email: str = "xxx"
) -> Dict[str, Any]:
    """
    Create a new calendar event.
    
    Args:
        summary (str): Event title/summary
        start_time (str): Start time in ISO format (e.g., "2025-06-15T08:00:00+02:00")
        end_time (str): End time in ISO format (e.g., "2025-06-15T09:00:00+02:00")
        timezone (str): Timezone for the event
        email (str): Email address to create event for
        
    Returns:
        Dict[str, Any]: Created event data
    """
    event_data = {
        "end": {
            "dateTime": end_time,
            "timeZone": timezone
        },
        "start": {
            "dateTime": start_time,
            "timeZone": timezone
        },
        "summary": summary
    }
    
    user_message = f"""
    create event for user : {email}
    with details: {json.dumps(event_data)}
    """
    return execute_calendar_function("GOOGLE_CALENDAR__EVENTS_INSERT", user_message)

def main() -> None:
    # Example usage
    events = get_calendar_events(
        time_min="2025-06-01T00:00:00Z",
        time_max="2025-06-30T23:59:59Z"
    )
    create_calendar_event(
        summary="Learn",
        start_time="2025-06-15T08:00:00+02:00",
        end_time="2025-06-15T12:00:00+02:00",
        timezone="Europe/Berlin",
        email="xxx"
    )
    rprint(Panel("Calendar Events", style="bold yellow"))
    rprint(events)

if __name__ == "__main__":
    main()
