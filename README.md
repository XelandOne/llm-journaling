# LLM Journal App
A journaling assistant (AI Secretary) powered by LLMs that helps users track their events, feelings, and provides personalized advice and motivation based on their Google Calender. 
The idea and the motivation behind this was to have a clean overview of your upcoming deadlines and that the user can interact with an LLM to be informed of the upcoming deadlines and how to approach them.
This project was build in 24h during the {Tech: Karlsruhe} AI Hackathon and selected as a finalist. 

## Features
- **Chat System**: Chat with an AI and ask it for upcoming events and deadlines. Add new events in your calender.
- **Event Tracking**: Automatically extracts and manages calendar events
- **Feeling Analysis**: Analyzes and tracks user emotions and feelings based on chat
- **Smart Advice**: Provides personalized advice based on events and feelings
- **Motivational Quotes**: Generates relevant motivational quotes based on the upcoming events.
- **Calendar Integration**: Seamlessly integrates with Google Calendar

## UI and Functionality

Here are some screenshots of the app showcasing its various features and design:

| ![Start Screen](frontend/ui_demo/ui_screenshot_1.png) | ![Event Info](frontend/ui_demo/ui_screenshot_2.png) | ![Statistics](frontend/ui_demo/ui_screenshot_3.png) |
|:-----------------------------------------------------:|:---------------------------------------------------:|:---------------------------------------------------:|
|                  **Start Screen**                   |                  **Event Info**                  |                  **Statistics**                  |

|  ![Feedback and Speech](frontend/ui_demo/ui_screenshot_4.png)  | ![Chat screen](frontend/ui_demo/ui_screenshot_6.png) | ![Calendar Interaction](frontend/ui_demo/ui_screenshot_7.png) |
|:--------------------------------------------------------------:|:----------------------------------------------------:|:-------------------------------------------------------------:|
|                    **Feedback and Speech**                     |                **Chat screen**                 |                    **Calendar Interaction**                     |

| ![Feelings and Event extraction](frontend/ui_demo/ui_screenshot_8.png) | ![Calendar](frontend/ui_demo/ui_screenshot_9.png) | |
|:--------------------------------------------------------------:|:----------------------------------------------------:|:-------------------------------------------------------------:|
|                    **Feelings and Event extraction**                     |                **Calendar**                 | |

A demo video of the app in action is available [here](frontend/ui_demo/ui_demo_video.mp4).

# Used Tools
- FastAPI
- Mistral, ChatGPT API
- ACI.dev for Google Calender Intergration
- Elevenlabs for Voice
- Flutter for frontend

#

## Project Structure

```
llm-journal/
├── backend/               # Backend server and API
│   ├── main.py           # FastAPI application and endpoints
│   ├── mistral.py        # Mistral AI integration
│   ├── gcal.py           # Google Calendar integration
│   ├── voice.py          # Voice processing utilities
│   ├── database.py       # Database configuration
│   ├── models.py         # SQLAlchemy models
│   └── requirements.txt  # Python dependencies
└── frontend/             # Frontend application
    ├── ui_planning/      # UI planning documents
    ├── ui_demo/          # UI demo implementation
    └── llm_assistant/    # LLM assistant implementation
```

## Set API keys

``` bash
export MISTRAL_API_KEY=
export ELEVENLABS_API_KEY=
export ACI_API_KEY=
export LINKED_ACCOUNT_OWNER_ID=
export OPENAI_API_KEY=
```

## Set up venv
``` bash
cd backend
python3 -m venv venv
./venv/bin/activate
pip install -r requirements.txt
```

## Run App
``` bash
cd frontend/llm_assistant
flutter clean
flutter pub get
flutter run --ios
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.