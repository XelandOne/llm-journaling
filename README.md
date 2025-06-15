# LLM Journal App
A journaling assistant (AI Secretary) powered by LLMs that helps users track their events, feelings, and provides personalized advice and motivation based on their Google Calender. 
The idea and the motivation behind this was to have a clean overview of your upcoming deadlines and that the user can interact with an LLM to be informed of the upcoming deadlines and how to approach them.
This Project was build in 24h during the {Tech: Karlsruhe} AI Hackathon.

## Features
- **Chat System**: Chat with an AI and ask it for upcoming events and deadlines. Add new events in your calender.
- **Event Tracking**: Automatically extracts and manages calendar events
- **Feeling Analysis**: Analyzes and tracks user emotions and feelings based on chat
- **Smart Advice**: Provides personalized advice based on events and feelings
- **Motivational Quotes**: Generates relevant motivational quotes based on the upcoming events.
- **Calendar Integration**: Seamlessly integrates with Google Calendar

# Used Tools
- FastAPI
- Mistral, ChatGPT API
- ACI.dev for Google Calender Intergration
- Elevenlabs for Voice
- Flutter for frontend

# Screenshots
TODO: add ui screenshots with core functionalities

# Set up 

## Set API keys

TODO: check api key names
``` bash
export MISTRAL_API_KEY=
export ELEVENLABS_API_KEY=
export ACI_API_KEY=
export LINKED_ACCOUNT_OWNER_ID=
export OPENAI_API_KEY=
```

## Set up env
``` bash

python3 -m venv venv
./venv/bin/activate
pip install -r requirements.txt
```

## Run App
``` bash
TODO ...
```




# Project Structure
TODO: add more
```
llm-journal-1/
├── backend/
│   ├── mistral.py          # Main LLM interaction logic
│   ├── schemes.py          # Data models and schemas
│   └── gcal/               # Google Calendar integration
├── requirements.txt        # Project dependencies
└── README.md              
```

# License
MIT License