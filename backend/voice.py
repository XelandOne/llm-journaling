import os
from typing import IO
from io import BytesIO
from elevenlabs import VoiceSettings, ElevenLabs
from dotenv import load_dotenv
from pydub import AudioSegment
from pydub.playback import play
import sounddevice as sd
import soundfile as sf

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
        file=audio_stream,
        model_id="scribe_v1"
    )
    return response


def record_audio(duration=5, sample_rate=44100):
    """Record audio from microphone for specified duration"""
    print(f"Recording for {duration} seconds...")
    recording = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=1)
    sd.wait()
    print("Recording finished!")
    
    # Convert to BytesIO
    audio_io = BytesIO()
    sf.write(audio_io, recording, sample_rate, format='WAV')
    audio_io.seek(0)
    return audio_io


if __name__ == '__main__':
    # First generate some speech
    audio = text_to_speech_stream("Hallo du Banause, wie kann ich dir helfen?")
    
    # Test speech to text
    text = speech_to_text(audio)
    print("Transcribed text:", text.text)
    
    # Reset the stream position before playing
    audio.seek(0)
    
    # Save to a temporary file and then play
    with open("temp_audio.mp3", "wb") as f:
        f.write(audio.read())
    
    audio_segment = AudioSegment.from_mp3("temp_audio.mp3")
    play(audio_segment)
    
    # Clean up
    os.remove("temp_audio.mp3")

    # Record your voice
    print("Testing speech-to-text with your voice...")
    audio = record_audio()
    
    # Convert speech to text using existing function
    text = speech_to_text(audio)
    print("Transcribed text:", text.text)