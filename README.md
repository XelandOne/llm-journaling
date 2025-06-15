# LLM Journal
A journaling assistant powered by LLMs that helps users track their events, feelings, and provides personalized advice and motivation based on their Google Calender. This Project was build in 24h during the Tech: Karlsruhe AI Hackathon.

## Features
- **Event Tracking**: Automatically extracts and manages calendar events
- **Feeling Analysis**: Analyzes and tracks user emotions and feelings
- **Smart Advice**: Provides personalized advice based on events and feelings
- **Motivational Quotes**: Generates relevant motivational quotes
- **Calendar Integration**: Seamlessly integrates with Google Calendar

# Used Tools
- FastAPI
- Mistral, ChatGPT API
- ACI.dev for Google Calender Intergration
- Elevenlabs for Voice
- Frontend: Flutter

# Screenshots


# Set up 

## Set API keys

``` bash
export MISTRAL_API_KEY=
export ELEVENLABS_API_KEY=
export ACI_API_KEY=
export LINKED_ACCOUNT_OWNER_ID=
export OPENAI_API_KEY=
```

## How to run
python3 -m venv venv
./venv/bin/activate
pip install -r requirements.txt

## Run App





# Project Structure

```
llm-journal-1/
├── backend/
│   ├── mistral.py          # Main LLM interaction logic
│   ├── schemes.py          # Data models and schemas
│   └── gcal/              # Google Calendar integration
├── requirements.txt        # Project dependencies
└── README.md              # This file
```

# License
MIT License