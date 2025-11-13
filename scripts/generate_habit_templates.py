import os
import google.generativeai as genai
from dotenv import load_dotenv
from tenacity import retry, wait_exponential, stop_after_attempt
import json
import time
from datetime import datetime
import hashlib
import random
import re

# Cargar variables de entorno
load_dotenv()
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])

model = genai.GenerativeModel(
    'gemini-2.0-flash',
    generation_config={
        "temperature": 0.85,
        "max_output_tokens": 1000,
    }
)

# CONFIGURACIÓN: Cantidad de templates a generar
MAX_TEMPLATES = int(input("¿Cuántos templates por idioma? (recomendado: 250-300 para 98% cobertura): ") or 250)

# Variables para generar escenarios dinámicamente
FAITH_MOTIVATIONS = ["closerToGod", "prayerDiscipline", "understandBible", "growInFaith", "overcomeHabits"]
FAITH_MATURITY = ["new", "growing", "mature", "passionate"]
WELLNESS_GOALS = ["timeManagement", "productivity", "physicalHealth", "reduceStress", "betterSleep"]
WELLNESS_STATE = ["starting", "inconsistent", "optimizing", "disciplined"]
BOTH_SPIRITUAL = ["closerToGod", "understandBible", "prayerDiscipline", "growInFaith", "overcomeHabits"]
BOTH_WELLNESS = ["timeManagement", "physicalHealth", "reduceStress", "productivity", "betterSleep"]
CHALLENGES = ["lackOfTime", "lackOfMotivation", "dontKnowStart", "givingUp"]

LANGUAGES = {
    "es": "español de México",
    "en": "English (US)",
    "pt": "português do Brasil",
    "fr": "français",
    "zh": "简体中文"
}

# Heurísticas y validación
MIN_DURATION_BY_CATEGORY = {
    "spiritual": 5,
    "physical": 10,
    "mental": 5,
    "relational": 5,
}
TRIVIAL_TERMS = [
    "respirar", "breathing", "beber agua", "tomar agua", "sentarse", "pararse",
    "ir al baño", "lavarse las manos", "parpadear", "mirar el celular", "scroll"
]
FALLBACK_ACTIONS = {
    "spiritual": ["Orar 10 min", "Lectura bíblica 10 min", "Reflexión 10 min"],
    "physical": ["Caminar 15 min", "Estiramientos 10 min", "Ejercicio 20 min"],
    "mental": ["Meditación 10 min", "Planificar 15 min", "Gratitud 10 min"],
    "relational": ["Llamar a un amigo 10 min", "Tiempo familiar 20 min", "Servicio 30 min"]
}

# Emojis permitidos (neutros, no religiosos ni esotéricos)
ALLOWED_EMOJIS = [
    "🚶", "😊", "📖", "💪", "🏃", "🏅", "🕒", "📅", "📞", "👨‍👩‍👧‍👦", "🤝", "🤸", "📝", "🗓️", "😃", "😌", "😇", "✍️", "📚", "🎯", "🧠"
]

# Si el emoji no es permitido, se reemplaza por uno neutro
DEFAULT_EMOJI = "😊"


def generate_random_scenario() -> dict:
    intent = random.choice(["faithBased", "wellness", "both"])
    support_levels = ["low", "normal", "high"]
    support_level = random.choice(support_levels)
    if intent == "faithBased":
        motivations = random.sample(FAITH_MOTIVATIONS, 2)
        return {
            "intent": "faithBased",
            "motivations": motivations,
            "maturity": random.choice(FAITH_MATURITY),
            "challenge": random.choice(CHALLENGES),
            "supportLevel": support_level
        }
    elif intent == "wellness":
        goals = random.sample(WELLNESS_GOALS, 2)
        return {
            "intent": "wellness",
            "goals": goals,
            "state": random.choice(WELLNESS_STATE),
            "challenge": random.choice(CHALLENGES),
            "supportLevel": support_level
        }
    else:
        return {
            "intent": "both",
            "spiritual": random.choice(BOTH_SPIRITUAL),
            "wellness": random.choice(BOTH_WELLNESS),
            "challenge": random.choice(CHALLENGES),
            "supportLevel": support_level
        }

def generate_scenario_id(scenario: dict) -> str:
    scenario_str = json.dumps(scenario, sort_keys=True)
    return hashlib.md5(scenario_str.encode()).hexdigest()[:12]

def load_existing_ids(filepath: str) -> set:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return {t['scenario_id'] for t in data.get('templates', [])}
    return set()

def is_trivial(name: str) -> bool:
    ln = name.lower()
    return any(term in ln for term in TRIVIAL_TERMS)

def infer_notification_time(habit):
    name = habit.get("name", "").lower()
    category = habit.get("category", "")
    # Lógica simple por nombre/categoría
    if any(x in name for x in ["mañana", "morning", "matin", "manhã"]):
        return "08:00"
    if any(x in name for x in ["noche", "night", "soir", "noite"]):
        return "21:00"
    if category == "spiritual":
        return "07:30"
    if category == "physical":
        return "18:00"
    if category == "mental":
        return "12:00"
    if category == "relational":
        return "19:00"
    return "12:00"

def notification_title_body(habit, lang):
    name = habit.get("name", "")
    # Puedes personalizar por idioma si lo deseas
    if lang == "es":
        return f"¡Hora de {name.split()[0].lower()}!", f"Recuerda: {name}"
    if lang == "en":
        return f"Time to {name.split()[0].lower()}!", f"Remember: {name}"
    if lang == "pt":
        return f"Hora de {name.split()[0].lower()}!", f"Lembre-se: {name}"
    if lang == "fr":
        return f"Heure de {name.split()[0].lower()}!", f"Rappel: {name}"
    if lang == "zh":
        return f"该{ name.split()[0] }了！", f"记得：{name}"
    return f"Time for {name}", f"Don't forget: {name}"

def sanitize_emoji(emoji):
    if emoji in ALLOWED_EMOJIS:
        return emoji
    return DEFAULT_EMOJI

def enrich_habit(habit, idx, pattern_id):
    name = habit.get("name", "").strip()
    category = habit.get("category", "other").strip()
    emoji = habit.get("emoji", "")
    # Detectar y reemplazar trivial
    if is_trivial(name):
        if "respirar" in name.lower() or "breath" in name.lower():
            name = "Guided breathing 5 min"
            category = "mental"
            emoji = DEFAULT_EMOJI
        else:
            # fallback por categoría
            fallback = random.choice(FALLBACK_ACTIONS.get(category, FALLBACK_ACTIONS["mental"]))
            name = fallback
            emoji = DEFAULT_EMOJI
    # Extraer duración
    m = re.search(r"(\d{1,3})\s*(min|mins|minutos|minutes|m)", name.lower())
    if m:
        minutes = int(m.group(1))
    else:
        minutes = MIN_DURATION_BY_CATEGORY.get(category, 5)
    # Sanear emoji
    emoji = sanitize_emoji(emoji)
    return {
        "id": f"tpl_{pattern_id}_{idx}",
        "nameKey": name,
        "category": category,
        "emoji": emoji,
        "target_minutes": minutes,
        "difficulty": "easy" if minutes <= 7 else "medium" if minutes <= 20 else "hard",
        "subtasks": [],
        "recommended_time": None
    }

def enrich_habit_with_notification(habit, lang):
    time = infer_notification_time(habit)
    title, body = notification_title_body(habit, lang)
    habit["notifications"] = [{
        "time": time,
        "title": title,
        "body": body,
        "enabled": True
    }]
    return habit

@retry(wait=wait_exponential(min=3, max=15), stop=stop_after_attempt(5))
def generate_template(scenario: dict, lang_code: str, lang_name: str, scenario_id: str) -> dict:
    intent = scenario["intent"]
    support_level = scenario.get("supportLevel", "normal")
    # Validar y asegurar que motivations/goals tengan al menos 2 elementos
    motivations = scenario.get("motivations") or []
    goals = scenario.get("goals") or []
    spiritual = scenario.get("spiritual")
    wellness = scenario.get("wellness")
    # Rellenar si faltan elementos
    if intent == "faithBased":
        while len(motivations) < 2:
            motivations.append("general")
        context = f"Motivaciones: {', '.join(motivations)}\nMadurez: {scenario['maturity']}\nDesafío: {scenario['challenge']}\nRed de apoyo: {support_level}"
        pattern_id = f"faith_{scenario['maturity']}_{scenario['challenge']}_{support_level}_{'_'.join(motivations[:2])}"
    elif intent == "wellness":
        while len(goals) < 2:
            goals.append("general")
        context = f"Objetivos: {', '.join(goals)}\nEstado: {scenario['state']}\nDesafío: {scenario['challenge']}\nRed de apoyo: {support_level}"
        pattern_id = f"well_{scenario['state']}_{scenario['challenge']}_{support_level}_{'_'.join(goals[:2])}"
    else:
        # both
        if not spiritual:
            spiritual = "general"
        if not wellness:
            wellness = "general"
        context = f"Espiritual: {spiritual}\nWellness: {wellness}\nDesafío: {scenario['challenge']}\nRed de apoyo: {support_level}"
        pattern_id = f"both_{spiritual}_{wellness}_{scenario['challenge']}_{support_level}"
    prompt = f"""
Language: {lang_name}
Profile: {intent}
{context}
Generate 5 habits with duration in the name.
ALLOWED CATEGORIES (use only these 4):
- spiritual: prayer, bible reading, spiritual reflection
- physical: exercise, walking, stretching, sleep
- mental: reflection, gratitude, mindfulness, planning
- relational: family, friends, community service

IMPORTANT:
- Use only neutral emojis (no religious, esoteric, or eastern symbols; do not use yoga, chakras, or meditation icons).
- For wellness habits, do NOT use Christian symbols, but avoid any symbol contrary to Christian values.
- If unsure, use a neutral emoji like 😊, 🚶, 📖, 💪, 🏃, 🏅, 🕒, 📅, 📞, 👨‍👩‍👧‍👦, 🤝, 🤸, 📝, 🗓️, 😃, 😌, 😇, ✍️, 📚, 🎯, 🧠.
- All instructions and field names must be in English, but the habit names and descriptions must be in the target language: {lang_name}.
- For each habit, add a field 'notifications' (array) with at least one notification. The notification time must be smart and logical for the habit type (e.g. morning for prayer, evening for reflection, after work for exercise, etc.), and the notifications for all habits should be distributed in an optimal daily order (no overlaps, covering morning, afternoon, and evening if possible).
- If support level is low, include at least two habits that encourage social connection or support (relational category).
- Respond ONLY with JSON (no markdown, no ```):
{{
  "pattern_id": "{pattern_id}",
  "habits": [
    {{
      "name": "Action + duration (e.g. Pray 10 min)",
      "category": "spiritual|physical|mental|relational",
      "emoji": "emoji",
      "notifications": [{{"time": "HH:MM", "title": "string", "body": "string", "enabled": true}}]
    }}
  ]
}}
"""
    response = model.generate_content(prompt)
    text = response.text.strip().replace("```json", "").replace("```", "").strip()
    try:
        data = json.loads(text)
    except Exception as e:
        print(f"❌ Error: Gemini response is not valid JSON. Raw response: {text}")
        raise e
    habits = data.get("habits", [])
    if not isinstance(habits, list):
        print(f"❌ Error: 'habits' is not a list. Raw: {habits}")
        raise ValueError("Gemini did not return a list for 'habits'")
    if len(habits) != 5:
        print(f"❌ Error: Gemini did not return 5 habits. Returned: {len(habits)}. Raw: {habits}")
        raise ValueError("Gemini did not return exactly 5 habits")
    for i, h in enumerate(habits):
        if not isinstance(h, dict):
            print(f"❌ Error: Habit at index {i} is not a dict. Habit: {h}")
            raise ValueError(f"Habit at index {i} is not a dict")
        missing_fields = [field for field in ["name", "category", "emoji"] if field not in h or not h[field]]
        if missing_fields:
            print(f"❌ Error: Habit at index {i} missing required fields {missing_fields}. Habit: {h}")
            raise ValueError(f"Habit at index {i} missing required fields: {missing_fields}")
    assert "pattern_id" in data
    enriched = []
    for i, h in enumerate(habits):
        try:
            enriched.append(enrich_habit(h, i, pattern_id))
        except Exception as e:
            print(f"❌ Error enriching habit at index {i}: {e}. Habit: {h}")
            raise
    data["habits"] = enriched
    data["scenario_id"] = scenario_id
    # Ajustar fingerprint y orden
    data["fingerprint"] = {
        "primaryIntent": intent,
        "motivations": motivations or goals or [spiritual, wellness],
        "challenge": scenario["challenge"],
        "supportLevel": support_level,
        "spiritualMaturity": scenario.get("maturity") or scenario.get("state")
    }
    return data

def generate_language_file(lang_code: str):
    lang_name = LANGUAGES[lang_code]
    output_file = f"habit_templates/templates-{lang_code}.json"
    print(f"\n{'='*60}")
    print(f"🌍 {lang_name.upper()} ({lang_code})")
    print(f"{'='*60}\n")
    existing_ids = load_existing_ids(output_file)
    templates_data = {
        "version": "1.0",
        "language": lang_code,
        "generated_at": datetime.now().isoformat(),
        "templates": []
    }
    if os.path.exists(output_file):
        with open(output_file, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
            templates_data["templates"] = existing_data.get("templates", [])
            print(f"📂 Cargados {len(templates_data['templates'])} templates existentes\n")
    generated = 0
    errors = 0
    attempts = 0
    max_attempts = MAX_TEMPLATES * 3
    while generated < MAX_TEMPLATES and attempts < max_attempts:
        attempts += 1
        scenario = generate_random_scenario()
        scenario_id = generate_scenario_id(scenario)
        if scenario_id in existing_ids:
            continue
        try:
            template = generate_template(scenario, lang_code, lang_name, scenario_id)
            template["habits"] = [enrich_habit_with_notification(h, lang_code) for h in template["habits"]]
            templates_data["templates"].append(template)
            existing_ids.add(scenario_id)
            generated += 1
            total = len(templates_data["templates"])
            print(f"✅ [{total:3d}/{MAX_TEMPLATES}] {template['pattern_id']}")
            os.makedirs("habit_templates", exist_ok=True)
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(templates_data, f, ensure_ascii=False, indent=2)
            if generated % 10 == 0:
                print(f"💾 Checkpoint: {total} templates guardados")
                time.sleep(3)
            else:
                time.sleep(2)
        except Exception as e:
            errors += 1
            error_msg = str(e)
            print(f"❌ Error al generar template: {error_msg}")
            if generated > 0 and errors % 5 == 0:
                os.makedirs("habit_templates", exist_ok=True)
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(templates_data, f, ensure_ascii=False, indent=2)
                print(f"💾 Guardado intermedio: {len(templates_data['templates'])} templates")
            if "ResourceExhausted" in error_msg or "429" in error_msg:
                print(f"⏸️  Rate limit - esperando 30s...")
                time.sleep(30)
            elif "RetryError" in error_msg:
                print(f"⚠️  Reintento fallido múltiple - continuando con siguiente...")
                time.sleep(5)
            else:
                print(f"❌ Error: {error_msg[:80]}")
            # Continúa con el siguiente intento aunque falle
    os.makedirs("habit_templates", exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(templates_data, f, ensure_ascii=False, indent=2)
    total_templates = len(templates_data["templates"])
    file_size = os.path.getsize(output_file) // 1024
    print(f"\n📊 {lang_code}: {total_templates} templates totales ({generated} nuevos), {errors} errores")
    print(f"💾 {output_file} ({file_size}KB)\n")
    if attempts >= max_attempts:
        print(f"⚠️  Alcanzado límite de intentos. Se generaron {generated}/{MAX_TEMPLATES} únicos.")

if __name__ == "__main__":
    print("🚀 Generador de Templates de Hábitos (Dinámico)")
    print("="*60)
    for lang_code in LANGUAGES.keys():
        generate_language_file(lang_code)
    print("\n✅ PROCESO COMPLETADO")
    print(f"📁 Archivos generados en: habit_templates/")
