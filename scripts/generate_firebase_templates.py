import firebase_admin
from firebase_admin import credentials, firestore
import json

# Inicializa Firebase Admin SDK
cred = credentials.Certificate('C:/Users/cesar/habitus_faith/habitus-faith-app-firebase-adminsdk-fbsvc-ee12a92662.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Ejemplo de datos para guardar como template maestro
fingerprint = 'wellness_inconsistent_lackOfMotivation_physicalHealth_reduceStress'
profile = {
    "primaryIntent": "wellness",
    "motivations": ["physicalHealth", "reduceStress"],
    "challenge": "lackOfMotivation",
    "supportLevel": None,
    "spiritualMaturity": "inconsistent"
}
habits = [
    {
        "name": "Quick Stretch Break",
        "description": "Simple movement to reduce stress and boost energy",
        "category": "physical",
        "emoji": "🧘",
        "microHabits": [
            {"title": "Take 5 deep breaths", "durationMinutes": 1, "order": 0},
            {"title": "Stretch neck and shoulders", "durationMinutes": 2, "order": 1}
        ],
        "notifications": [
            {"time": "14:00", "title": "Relaxation Break 🧘", "body": "Take 3 minutes to relax", "enabled": True}
        ]
    },
    {
        "name": "Gratitude Moment",
        "description": "Improve mindset and reduce stress through gratitude",
        "category": "mental",
        "emoji": "🌈",
        "microHabits": [
            {"title": "Write down 3 good things from today", "durationMinutes": 2, "order": 0},
            {"title": "Set one small goal for tomorrow", "durationMinutes": 1, "order": 1}
        ],
        "notifications": [
            {"time": "20:00", "title": "Gratitude Time 🌈", "body": "Reflect on your day", "enabled": True}
        ]
    }
]

data = {
    'fingerprint': fingerprint,
    'profile': profile,
    'habits': habits,
    'createdAt': firestore.SERVER_TIMESTAMP,
    'source': 'manual'
}

doc_ref = db.collection('habit_templates_master').document(fingerprint)
doc_ref.set(data)
print(f'Template guardado en Firebase con fingerprint: {fingerprint}')

# Puedes repetir el bloque anterior para otros fingerprints y templates

