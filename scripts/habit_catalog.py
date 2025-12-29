# habit_catalog.py
# Base catalog of 45 habits with metadata for scoring engine
# Language-agnostic: uses keys for i18n translation

HABIT_CATALOG = {
    "spiritual": [
        {
            "id": "sp01",
            "nameKey": "morning_prayer",
            "category": "spiritual",
            "emoji": "🙏",
            "base_duration": 10,
            "maturity_multiplier": {
                "new": 0.5,
                "growing": 1.0,
                "mature": 1.5,
                "passionate": 3.0
            },
            "tags": ["prayer", "morning", "foundational"],
            "motivation_match": ["closerToGod", "prayerDiscipline"],
            "challenge_fit": {
                "lackOfTime": 0.9,
                "lackOfMotivation": 0.8,
                "dontKnowStart": 1.0,
                "givingUp": 0.7
            },
            "support_boost": {"weak": 1.2},
            "verse_key": "psalms_5_3",
            "priority": 100,
            "time_of_day": "morning"
        }
    ],
    "physical": [
        {
            "id": "ph01",
            "nameKey": "daily_walk",
            "category": "physical",
            "emoji": "🚶",
            "base_duration": 20,
            "maturity_multiplier": None,
            "tags": ["exercise", "outdoor", "cardio"],
            "motivation_match": ["physicalHealth", "reduceStress"],
            "challenge_fit": {
                "lackOfTime": 0.7,
                "lackOfMotivation": 0.6,
                "dontKnowStart": 0.9,
                "givingUp": 0.9
            },
            "priority": 90,
            "time_of_day": "morning"
        }
    ],
    "mental": [
        {
            "id": "mn01",
            "nameKey": "mindfulness_meditation",
            "category": "mental",
            "emoji": "🧘",
            "base_duration": 10,
            "maturity_multiplier": None,
            "tags": ["mindfulness", "meditation", "stress"],
            "motivation_match": ["reduceStress"],
            "challenge_fit": {
                "lackOfTime": 0.8,
                "lackOfMotivation": 0.6,
                "dontKnowStart": 0.8,
                "givingUp": 0.8
            },
            "priority": 90,
            "time_of_day": "morning"
        }
    ],
    "relational": [
        {
            "id": "rl01",
            "nameKey": "call_friend_family",
            "category": "relational",
            "emoji": "📞",
            "base_duration": 15,
            "maturity_multiplier": None,
            "tags": ["connection", "support", "communication"],
            "motivation_match": [],
            "challenge_fit": {
                "lackOfTime": 0.7,
                "lackOfMotivation": 0.8,
                "dontKnowStart": 0.8,
                "givingUp": 0.9
            },
            "support_boost": {"weak": 2.0},
            "priority": 60,
            "time_of_day": "evening"
        }
    ]
}

def get_all_habits():
    """Returns all 45 habits as a flat list"""
    all_habits = []
    for category in HABIT_CATALOG.values():
        all_habits.extend(category)
    return all_habits

def get_habits_for_intent(intent):
    """Returns appropriate habit pool based on user intent"""
    if intent == "faithBased":
        return HABIT_CATALOG["spiritual"]
    elif intent == "wellness":
        return (HABIT_CATALOG["physical"] +
                HABIT_CATALOG["mental"] +
                HABIT_CATALOG["relational"])
    else:  # both
        return get_all_habits()
