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


def generate_random_scenario() -> dict:
    intent = random.choice(["faithBased", "wellness", "both"])
    if intent == "faithBased":
        motivations = random.sample(FAITH_MOTIVATIONS, 2)
        return {
            "intent": "faithBased",
            "motivations": motivations,
            "maturity": random.choice(FAITH_MATURITY),
            "challenge": random.choice(CHALLENGES)
        }
    elif intent == "wellness":
        goals = random.sample(WELLNESS_GOALS, 2)
        return {
            "intent": "wellness",
            "goals": goals,
            "state": random.choice(WELLNESS_STATE),
            "challenge": random.choice(CHALLENGES)
        }
    else:
        return {
            "intent": "both",
            "spiritual": random.choice(BOTH_SPIRITUAL),
            "wellness": random.choice(BOTH_WELLNESS),
            "challenge": random.choice(CHALLENGES)
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

def enrich_habit(habit, idx, pattern_id):
    name = habit.get("name", "").strip()
    category = habit.get("category", "other").strip()
    emoji = habit.get("emoji", "")
    # Detectar y reemplazar trivial
    if is_trivial(name):
        if "respirar" in name.lower() or "breath" in name.lower():
            name = "Respiración guiada 5 min"
            category = "mental"
            emoji = "🧘"
        else:
            # fallback por categoría
            fallback = random.choice(FALLBACK_ACTIONS.get(category, FALLBACK_ACTIONS["mental"]))
            name = fallback
            emoji = "✨"
    # Extraer duración
    m = re.search(r"(\d{1,3})\s*(min|mins|minutos|minutes|m)", name.lower())
    if m:
        minutes = int(m.group(1))
    else:
        minutes = MIN_DURATION_BY_CATEGORY.get(category, 5)
    # Enriquecer
    return {
        "name": name,
        "category": category,
        "emoji": emoji,
        "target_minutes": minutes,
        "difficulty": "easy" if minutes <= 7 else "medium" if minutes <= 20 else "hard",
        "predefined_id": f"tpl_{pattern_id}_{idx}",
        "subtasks": [],
        "recommended_time": None
    }

@retry(wait=wait_exponential(min=3, max=15), stop=stop_after_attempt(5))
def generate_template(scenario: dict, lang_code: str, lang_name: str, scenario_id: str) -> dict:
    intent = scenario["intent"]
    if intent == "faithBased":
        context = f"Motivaciones: {', '.join(scenario['motivations'])}\nMadurez: {scenario['maturity']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"faith_{scenario['maturity']}_{scenario['challenge']}_{'_'.join(scenario['motivations'][:2])}"
    elif intent == "wellness":
        context = f"Objetivos: {', '.join(scenario['goals'])}\nEstado: {scenario['state']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"well_{scenario['state']}_{scenario['challenge']}_{'_'.join(scenario['goals'][:2])}"
    else:
        context = f"Espiritual: {scenario['spiritual']}\nWellness: {scenario['wellness']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"both_{scenario['spiritual']}_{scenario['wellness']}_{scenario['challenge']}"
    prompt = f"""
Idioma: {lang_name}
Perfil: {intent}
{context}
Genera 6 hábitos con duración en el nombre.
CATEGORÍAS VÁLIDAS (usar solo estas 4):
- spiritual: Oración, lectura bíblica, meditación espiritual
- physical: Ejercicio, caminar, estiramientos, dormir
- mental: Reflexión, gratitud, mindfulness, planificación
- relational: Familia, amigos, servicio comunitario
Responde SOLO JSON (sin markdown, sin ```):
{{
  "pattern_id": "{pattern_id}",
  "habits": [
    {{
      "name": "Acción + duración (ej: Orar 10 min)",
      "category": "spiritual|physical|mental|relational",
      "emoji": "emoji"
    }}
  ]
}}
"""
    response = model.generate_content(prompt)
    text = response.text.strip().replace("```json", "").replace("```", "").strip()
    data = json.loads(text)
    # Validar
    assert len(data["habits"]) == 6, f"Expected 6 habits, got {len(data['habits'])}"
    assert "pattern_id" in data
    # Enriquecer y reemplazar triviales
    enriched = [enrich_habit(h, i, pattern_id) for i, h in enumerate(data["habits"])]
    data["habits"] = enriched
    data["scenario_id"] = scenario_id
    data["fingerprint"] = {
        "primaryIntent": intent,
        "motivations": scenario.get("motivations") or scenario.get("goals") or [scenario.get("spiritual"), scenario.get("wellness")],
        "challenge": scenario["challenge"],
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

