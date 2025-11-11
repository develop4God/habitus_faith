import firebase_admin
from firebase_admin import credentials, firestore
import os
import json

# Inicializa Firebase Admin SDK
cred = credentials.Certificate('C:/Users/cesar/habitus_faith/habitus-faith-app-firebase-adminsdk-fbsvc-ee12a92662.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Carpetas de templates por idioma
template_dirs = [
    'C:/Users/cesar/habitus_faith/habit_templates/templates-en',
    'C:/Users/cesar/habitus_faith/habit_templates/templates-es',
    'C:/Users/cesar/habitus_faith/habit_templates/templates-fr',
    'C:/Users/cesar/habitus_faith/habit_templates/templates-pt',
    'C:/Users/cesar/habitus_faith/habit_templates/templates-zh',
]

def clean_habit(habit):
    habit = dict(habit)
    habit.pop('description', None)
    return habit

def migrate_templates():
    for dir_path in template_dirs:
        lang = dir_path.split('-')[-1]
        for filename in os.listdir(dir_path):
            if filename.endswith('.json') and filename != 'metadata.json':
                with open(os.path.join(dir_path, filename), 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    fingerprint = data.get('pattern_id')
                    profile = data.get('fingerprint')
                    habits = data.get('generated_habits', [])
                    habits_clean = [clean_habit(h) for h in habits]
                    doc_data = {
                        'fingerprint': fingerprint,
                        'profile': profile,
                        'habits': habits_clean,
                        'createdAt': firestore.SERVER_TIMESTAMP,
                        'source': 'migrated',
                        'language': lang
                    }
                    db.collection('habit_templates_master').document(fingerprint).set(doc_data)
                    print(f'Template migrado: {fingerprint} ({lang})')

if __name__ == '__main__':
    migrate_templates()
    print('Migración completa de todos los templates locales a Firestore sin descripción.')
