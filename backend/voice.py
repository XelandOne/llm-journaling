import os
from typing import IO
from io import BytesIO
from elevenlabs import VoiceSettings, ElevenLabs
from dotenv import load_dotenv
from pydub import AudioSegment
from pydub.playback import play

load_dotenv()

ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")
elevenlabs = ElevenLabs(
    api_key=ELEVENLABS_API_KEY,
)


def text_to_speech_stream(text: str) -> IO[bytes]:
    # Perform the text-to-speech conversion
    response = elevenlabs.text_to_speech.stream(
        voice_id="pNInz6obpgDQGcFmaJgB", # Adam pre-made voice
        output_format="mp3_22050_32",
        text=text,
        model_id="eleven_multilingual_v2",
        voice_settings=VoiceSettings(
            stability=0.0,
            similarity_boost=1.0,
            style=0.0,
            use_speaker_boost=True,
            speed=1.0,
        ),
    )

    # Create a BytesIO object to hold the audio data in memory
    audio_stream = BytesIO()

    # Write each chunk of audio data to the stream
    for chunk in response:
        if chunk:
            audio_stream.write(chunk)

    audio_stream.seek(0)

    return audio_stream


def speech_to_text(audio_stream: IO[bytes]) -> str:
    response = elevenlabs.speech_to_text.convert(
        audio=audio_stream,
        model_id="eleven_multilingual_v2",
    )
    return response


if __name__ == '__main__':
    audio = text_to_speech_stream("Hallo du Banause, wie kann ich dir helfen?")

    # MP3-Stream direkt abspielen
    audio_segment = AudioSegment.from_file(audio, format="mp3")
    play(audio_segment)