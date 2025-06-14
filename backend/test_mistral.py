from pprint import pprint
from mistral import extract_event_and_feeling, generate_advice

def test_extraction():
    chat = "I felt super stressed during my final exams but relieved after I submitted everything. Then I went hiking with friends to celebrate."
    result = extract_event_and_feeling(chat)
    print("=== Extracted Event and Feeling ===")
    pprint(result)

def test_advice():
    events = [
        {
            "date": "2025-06-10",
            "startTime": "2025-06-10T09:00:00",
            "endTime": "2025-06-10T11:00:00",
            "description": "Final exams",
            "tags": ["education", "personal"]
        },
        {
            "date": "2025-06-11",
            "startTime": "2025-06-11T15:00:00",
            "endTime": "2025-06-11T19:00:00",
            "description": "Hiking celebration",
            "tags": ["social", "health"]
        }
    ]
    feelings = [
        {
            "feelings": ["stressed"],
            "score": 3,
            "datetime": "2025-06-10T10:30:00"
        },
        {
            "feelings": ["relieved", "happy"],
            "score": 8,
            "datetime": "2025-06-11T20:00:00"
        }
    ]

    print("=== Generated Advice ===")
    advice = generate_advice(events, feelings)
    print(advice)


if __name__ == "__main__":
    print("\n>>> Testing Event + Feeling Extraction...\n")
    test_extraction()

    print("\n>>> Testing Advice Generation...\n")
    test_advice()