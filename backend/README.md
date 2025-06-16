# LifeChat Backend

A FastAPI-based backend service for the LifeChat application that provides endpoints for logging and analyzing life events and feelings. Currently implemented with dummy data, it's designed to be easily extended with real database integration or Google Calendar synchronization.

## Features

- RESTful API endpoints for managing life events and feelings
- AI-powered advice generation using Mistral
- Motivational speech generation with text-to-speech capabilities
- CORS enabled for local frontend development
- Dummy data generation for testing and development

## Setup

1. Create a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Copy the example environment file and configure if needed:
```bash
cp example.env .env
```

## Running the Backend

To start the backend server:

```bash
python dummy_backend.py
```

The server will start on `http://localhost:8000`. You can access the API documentation at `http://localhost:8000/docs`.

## API Endpoints

- `POST /lifeChat` - Submit chat messages and extract events/feelings
- `GET /getEvents` - Retrieve events within a time range
- `GET /getFeelings` - Retrieve feelings within a time range
- `GET /getAdvice` - Get AI-generated advice based on events and feelings
- `GET /getMotivationalSpeech` - Get a motivational speech as audio stream

## Future Extensibility

The backend is designed to be easily extended:

1. **Database Integration**: 
   - The dummy data can be replaced with a real database
   - Database models can be added in the `database_integration` directory
   - Current endpoints can be modified to use database queries instead of dummy data

2. **Google Calendar Integration**:
   - The `gcal.py` module is prepared for Google Calendar integration
   - Events can be synced with Google Calendar instead of using dummy data
   - Authentication and calendar operations are handled separately

## Development Notes

- The backend uses FastAPI for high performance and automatic API documentation
- CORS is enabled for all origins to facilitate local development
- Dummy data is generated for testing purposes
- AI features are powered by Mistral
- Text-to-speech capabilities are included for motivational speeches

## Environment Variables

See `example.env` for required environment variables. Currently, the dummy backend can run without any environment variables, but they will be needed for:
- Database connections
- Google Calendar API integration
- AI model API keys
- Text-to-speech service credentials
