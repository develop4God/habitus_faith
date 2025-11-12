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

load_dotenv()

# Fallback: if dotenv failed to parse or env vars are not set, try to read .env manually and extract keys
def _read_keys_from_dotenv_file(path='.env'):
    try:
        if not os.path.exists(path):
            return None
        keys = []
        with open(path, 'r', encoding='utf-8') as f:
            for line in f:
                raw = line.strip()
                if not raw or raw.startswith('#'):
                    continue
                # remove inline comments
                if '#' in raw:
                    raw = raw.split('#', 1)[0].strip()
                if '=' not in raw:
                    continue
                k, v = raw.split('=', 1)
                k = k.strip()
                v = v.strip()
                # remove surrounding quotes
                if v.startswith('"') and v.endswith('"'):
                    v = v[1:-1]
                if v.startswith("'") and v.endswith("'"):
                    v = v[1:-1]
                # split by comma if multiple
                parts = [p.strip().strip('"').strip("'") for p in v.split(',') if p.strip()]
                if k == 'GOOGLE_API_KEYS' and parts:
                    return parts
                if k == 'GOOGLE_API_KEY' and parts:
                    # if a single key is provided but contains commas, return list
                    return parts
        return None
    except Exception:
        return None

# Support multiple API keys: either GOOGLE_API_KEYS (comma-separated) or single GOOGLE_API_KEY
KEYS_RAW = os.environ.get("GOOGLE_API_KEYS") or os.environ.get("GOOGLE_API_KEY")
API_KEYS = []
if KEYS_RAW:
    # try to split KEY_RAW by comma and strip quotes
    API_KEYS = [k.strip().strip('"').strip("'") for k in KEYS_RAW.split(',') if k.strip()]
else:
    parsed = _read_keys_from_dotenv_file('.env')
    if parsed:
        API_KEYS = parsed

# Validate keys list: basic sanity check (contains typical Google key prefix or reasonable length)
_valid_api_keys = [k for k in API_KEYS if (k.startswith('AIza') or len(k) > 20)]
if not _valid_api_keys:
    # No valid-looking keys found -> switch to offline mode
    API_KEYS = []
    USE_OFFLINE = True
    print("⚠️ Warning: No valid GOOGLE_API_KEY(s) found in environment or .env. Running in OFFLINE fallback mode.")
    print("  - Update your .env with: GOOGLE_API_KEYS=KEY1,KEY2 or GOOGLE_API_KEY=KEY1")
else:
    API_KEYS = _valid_api_keys
    USE_OFFLINE = False

DEFAULT_KEY_COOLDOWN = int(os.environ.get("KEY_COOLDOWN_SECONDS", "60"))

class ApiKeyManager:
    def __init__(self, keys, cooldown=60):
        self.keys = keys
        self.cooldown = cooldown
        self.disabled_until = [0 for _ in keys]
        self.next_idx = 0

    def get_next_key(self):
        if not self.keys:
            return None, None
        n = len(self.keys)
        for i in range(n):
            idx = (self.next_idx + i) % n
            if time.time() >= self.disabled_until[idx]:
                self.next_idx = (idx + 1) % n
                return self.keys[idx], idx
        return None, None

    def disable_key(self, idx, cooldown=None):
        if idx is None:
            return
        cd = cooldown if cooldown is not None else self.cooldown
        self.disabled_until[idx] = time.time() + cd

api_key_manager = ApiKeyManager(API_KEYS, DEFAULT_KEY_COOLDOWN)


def run_model(prompt, model_name='gemini-2.0-flash', max_attempts=None):
    if USE_OFFLINE:
        raise RuntimeError('Offline mode enabled: no API keys available')
    attempts = 0
    max_attempts = max_attempts or (max(1, len(API_KEYS)) * 3)
    last_exc = None
    while attempts < max_attempts:
        key, kidx = api_key_manager.get_next_key()
        if key is None:
            wait = api_key_manager.cooldown
            print(f"⏳ All API keys cooling down. Sleeping {wait}s before retrying...")
            time.sleep(wait)
            attempts += 1
            continue
        try:
            genai.configure(api_key=key)
            model_local = genai.GenerativeModel(
                model_name,
                generation_config={
                    "temperature": 0.85,
                    "max_output_tokens": 1000,
                }
            )
            response = model_local.generate_content(prompt)
            return response
        except Exception as e:
            last_exc = e
            msg = str(e).lower()
            if "429" in msg or "rate" in msg or "quota" in msg or "resourceexhausted" in msg or "exhausted" in msg:
                print(f"⚠️ API key index {kidx} hit rate/quota error: {e}. Disabling key for {api_key_manager.cooldown}s and retrying with next key.")
                api_key_manager.disable_key(kidx)
                attempts += 1
                time.sleep(1 + attempts * 0.5)
                continue
            raise
    if last_exc:
        raise last_exc
    raise RuntimeError("Model call failed after rotating keys")

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

# --- Nuevas constantes y helpers para validación/enriquecimiento ---
MIN_DURATION_BY_CATEGORY = {
    "spiritual": 5,
    "physical": 10,
    "mental": 5,
    "relational": 5,
}
VALID_CATEGORIES = ["spiritual", "physical", "mental", "relational", "other"]
DIFFICULTY_OPTIONS = ["easy", "medium", "hard"]
TRIVIAL_TERMS = [
    "respirar", "breathing", "beber agua", "tomar agua", "sentarse", "pararse",
    "ir al baño", "lavarse las manos", "parpadear", "mirar el celular", "scroll"
]
DROP_TRIVIAL = True  # Si True, descartamos hábitos triviales en lugar de intentar parchearlos

# Verbos/acciones permitidas (es + en) — si el nombre no contiene ninguno de estos y no tiene duración, lo consideramos trivial
ALLOWED_ACTION_VERBS = [
    # Español
    'orar','oración','caminar','meditar','estirar','leer','reflexionar','planificar','hacer','ejercicio','llamar','servicio','gratitud','practicar','estudio','correr','yoga','estudio','escribir','dibujar','rezar','ayudar','ayuno','ayunar','ayuno',
    # English
    'pray','walk','meditate','stretch','read','reflect','plan','exercise','call','serve','gratitude','practice','study','run','yoga','write','draw','help','fast'
]

# Fallbacks por categoría - alternativas significativas para onboarding
FALLBACK_ACTIONS = {
    "spiritual": [
        {"name": "Oración guiada 10 min", "emoji": "🙏", "target_minutes": 10, "difficulty": "easy"},
        {"name": "Lectura bíblica 10 min (1 pasaje)", "emoji": "📖", "target_minutes": 10, "difficulty": "easy"},
        {"name": "Reflexión en versículo 10 min", "emoji": "🤔", "target_minutes": 10, "difficulty": "medium"}
    ],
    "physical": [
        {"name": "Caminata rápida 15 min", "emoji": "🚶", "target_minutes": 15, "difficulty": "easy"},
        {"name": "Estiramientos dinámicos 10 min", "emoji": "🤸", "target_minutes": 10, "difficulty": "easy"},
        {"name": "Ejercicio breve 20 min", "emoji": "💪", "target_minutes": 20, "difficulty": "medium"}
    ],
    "mental": [
        {"name": "Meditación guiada 10 min", "emoji": "🧘", "target_minutes": 10, "difficulty": "easy"},
        {"name": "Planificar 15 min (tareas clave)", "emoji": "🗓️", "target_minutes": 15, "difficulty": "medium"},
        {"name": "Diario de gratitud 10 min", "emoji": "😊", "target_minutes": 10, "difficulty": "easy"}
    ],
    "relational": [
        {"name": "Llamar a un amigo 10 min", "emoji": "📞", "target_minutes": 10, "difficulty": "easy"},
        {"name": "Tiempo familiar 20 min", "emoji": "👨‍👩‍👧‍👦", "target_minutes": 20, "difficulty": "easy"},
        {"name": "Servicio breve 30 min (semanal)", "emoji": "🤝", "target_minutes": 30, "difficulty": "medium"}
    ]
}

def parse_minutes_from_name(name: str):
    m = re.search(r"(\d{1,3})\s*(min|mins|minutos|minutes|m)", name.lower())
    if m:
        try:
            return int(m.group(1))
        except:
            return None
    return None

def is_trivial_action(name: str) -> bool:
    ln = name.lower()
    for term in TRIVIAL_TERMS:
        if term in ln:
            return True
    # consider too-generic short names trivial (e.g., single-word verbs without purpose)
    words = name.split()
    if len(words) <= 2 and any(len(w) < 8 for w in words):
        return True
    # si no es una acción trivial, pero no tiene verbo ni duración explícita, también lo consideramos trivial
    if not any(verb in ln for verb in ALLOWED_ACTION_VERBS):
        return True
    return False

def safe_predefined_id(pattern_id: str, idx: int, name: str) -> str:
    h = hashlib.sha1(f"{pattern_id}_{idx}_{name}".encode()).hexdigest()[:8]
    return f"tpl_{pattern_id}_{h}"


def validate_and_enrich_habit(h: dict, pattern_id: str, idx: int) -> dict | None:
    """Valida y enriquece un hábito generado. Devuelve None si inválido."""
    name = (h.get("name") or "").strip()
    cat = (h.get("category") or "other").strip()
    emoji = (h.get("emoji") or "").strip() or None

    if not name or len(name) < 3:
        return None

    # Normalizar categoría
    if cat not in VALID_CATEGORIES:
        cat_low = cat.lower()
        if cat_low in VALID_CATEGORIES:
            cat = cat_low
        else:
            cat = "other"

    # Detectar y transformar acciones triviales
    if is_trivial_action(name):
        # Si es respiración, transformamos en una práctica guiada más significativa
        if "respirar" in name.lower() or "breathing" in name.lower():
            # extraer minutos si hay
            parsed_min = parse_minutes_from_name(name)
            minutes = parsed_min if parsed_min and parsed_min >= MIN_DURATION_BY_CATEGORY.get(cat,5) else MIN_DURATION_BY_CATEGORY.get(cat,5)
            name = f"Respiración guiada {minutes} min (enfócate en la exhalación)"
            emoji = emoji or "🧘"
            # sobrescribimos target_minutes y difficulty
            target_minutes = minutes
            difficulty = "easy"
            # creamos subtarea sugerida
            subtasks = [{"id": hashlib.md5(name.encode()).hexdigest()[:8], "title": "Respira conscientemente durante la duración indicada", "completed": False}]
            # Construir enriched y retornar inmediatamente
            predefined_id = h.get("predefined_id") or safe_predefined_id(pattern_id, idx, name)
            enriched = {
                "name": name,
                "category": cat,
                "emoji": emoji,
                "target_minutes": target_minutes,
                "difficulty": difficulty,
                "predefined_id": predefined_id,
                "subtasks": subtasks,
                "recommended_time": h.get("recommended_time"),
                "notification": h.get("notification"),
            }
            if h.get("color_value") is not None:
                enriched["color_value"] = h.get("color_value")
            return enriched

        if DROP_TRIVIAL:
            # descartamos la tarea trivial, el caller rellenará con fallback
            print(f"🔕 Descargando hábito trivial: '{name}'")
            return None
        else:
            # si no descartamos, intentamos enriquecer
            if "respirar" in name.lower() or "breathing" in name.lower():
                name = name + " (ej. respiración guiada con intención)"
            else:
                print(f"⚠️ Hábito trivial detectado pero no descartado: {name}")

    # target_minutes
    target = h.get("target_minutes")
    if isinstance(target, int) and target > 0:
        target_minutes = target
    else:
        parsed = parse_minutes_from_name(name)
        if parsed is not None:
            target_minutes = parsed
        else:
            target_minutes = MIN_DURATION_BY_CATEGORY.get(cat, 5)

    # garantizar duración mínima según categoría
    min_req = MIN_DURATION_BY_CATEGORY.get(cat, 5)
    if target_minutes < min_req:
        target_minutes = min_req
        if not parse_minutes_from_name(name):
            name = f"{name} {target_minutes} min"

    # difficulty heurística
    difficulty = h.get("difficulty")
    if difficulty not in DIFFICULTY_OPTIONS:
        if target_minutes <= 7:
            difficulty = "easy"
        elif target_minutes <= 20:
            difficulty = "medium"
        else:
            difficulty = "hard"

    # subtasks normalizados
    subtasks_raw = h.get("subtasks") or []
    subtasks = []
    for s in subtasks_raw:
        if isinstance(s, dict) and s.get("title"):
            subtasks.append({
                "id": s.get("id") or hashlib.md5(s.get("title","\n").encode()).hexdigest()[:8],
                "title": s.get("title"),
                "completed": bool(s.get("completed", False))
            })
    if not subtasks and target_minutes >= 10:
        subtasks.append({"id": hashlib.md5(name.encode()).hexdigest()[:8], "title": f"Cumple {target_minutes} minutos", "completed": False})

    predefined_id = h.get("predefined_id") or safe_predefined_id(pattern_id, idx, name)

    enriched = {
        "name": name,
        "category": cat,
        "emoji": emoji,
        "target_minutes": target_minutes,
        "difficulty": difficulty,
        "predefined_id": predefined_id,
        "subtasks": subtasks,
        "recommended_time": h.get("recommended_time"),
        "notification": h.get("notification"),
    }

    if h.get("color_value") is not None:
        enriched["color_value"] = h.get("color_value")

    return enriched

# --- Mejor prompt: pide campos explícitos y restricción anti-trivial ---

def build_prompt(pattern_id: str, scenario: dict, lang_name: str, lang_code: str) -> str:
    # Prompt in English (model instruction language), but request answer in the target human language (lang_name)
    return f"""
You are a helpful assistant that generates habit templates for a mobile app onboarding flow.

Context: {json.dumps(scenario, ensure_ascii=False)}

Generate exactly 6 habits for this profile. Each habit must be a JSON object with these fields:
- name (string): clear action + duration in minutes (e.g. "Pray 10 min").
- category (string): one of [spiritual, physical, mental, relational].
- emoji (string): a representative emoji.
- target_minutes (integer): target duration in minutes; must match the name.
- difficulty (string): one of [easy, medium, hard].
- subtasks (optional array): list of steps {"title": "..."} (1-3 items) if applicable.
- predefined_id (optional string): unique template identifier.
- recommended_time (optional): "morning"|"evening"|"any" or "HH:MM".
- notification (optional object): {"timing": "atEventTime"|"before", "eventTime": "HH:MM"}.

Important rules (must follow):
- DO NOT generate trivial activities like "breathing" or "drink water". If breathing appears, convert it into a guided breathing practice with intent and duration.
- Ensure variety: include at least 3 different categories among the 6 habits.
- Keep at least 2 habits with target_minutes >= 10.
- Minimum durations: spiritual 5, physical 10, mental 5, relational 5.
- Avoid duplicates or very similar synonyms.
- Use the exact category keys [spiritual, physical, mental, relational].
- Respond ONLY valid JSON with this structure: {{"pattern_id":"...","habits":[{{...}}...]}}

pattern_id suggestion: {pattern_id}

IMPORTANT: produce the answer IN {lang_name} (language code: {lang_code}). Do not include additional commentary or markdown—only the JSON.
"""

# Reemplazo de la función generate_template para incluir validación y enriquecimiento
@retry(wait=wait_exponential(min=3, max=15), stop=stop_after_attempt(5))
def generate_template(scenario: dict, lang_code: str, lang_name: str, scenario_id: str) -> dict:
    """Genera 6 hábitos para un escenario y los enriquece/valida."""
    intent = scenario["intent"]

    if intent == "faithBased":
        context = f"Motivaciones: {', '.join(scenario['motivations'])}\nMadurez: {scenario['maturity']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"faith_{scenario['maturity']}_{scenario['challenge']}_{'_'.join(scenario['motivations'][:2])}"
    elif intent == "wellness":
        context = f"Objetivos: {', '.join(scenario['goals'])}\nEstado: {scenario['state']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"well_{scenario['state']}_{scenario['challenge']}_{'_'.join(scenario['goals'][:2])}"
    else:  # both
        context = f"Espiritual: {scenario['spiritual']}\nWellness: {scenario['wellness']}\nDesafío: {scenario['challenge']}"
        pattern_id = f"both_{scenario['spiritual']}_{scenario['wellness']}_{scenario['challenge']}"

    prompt = build_prompt(pattern_id, scenario, lang_name, lang_code)

    # If offline mode, use fallback sample instead of calling model
    if USE_OFFLINE:
        # Build a simple fallback 'raw' similar to model output but localized names may remain in English
        sample_names = [
            "Pray 10 min", "Walk 15 min", "Reflect 10 min", "Stretch 10 min", "Gratitude 10 min", "Call a friend 10 min"
        ]
        sample_cats = ["spiritual", "physical", "mental", "physical", "mental", "relational"]
        sample_emojis = ["🙏", "🚶", "🤔", "🤸", "😊", "📞"]
        raw = {"pattern_id": pattern_id, "habits": []}
        for i in range(6):
            raw['habits'].append({
                "name": sample_names[i],
                "category": sample_cats[i],
                "emoji": sample_emojis[i],
                "target_minutes": int(re.search(r"(\d+)", sample_names[i]).group(1)),
                "difficulty": "easy"
            })
    else:
        # call the model via run_model which rotates API keys if needed
        response = run_model(prompt)
        text = response.text.strip().replace("```json", "").replace("```", "").strip()
        raw = json.loads(text)

    # proceed with enrichment using `raw`
    data = raw

    # Validación básica de estructura
    if not data.get('pattern_id') or not isinstance(data.get('habits'), list) or len(data['habits']) != 6:
        raise AssertionError(f"Modelo retornó estructura inválida: {data}")

    # Enriquecer y validar cada hábito
    enriched_habits = []
    for idx, h in enumerate(data['habits']):
        enriched = validate_and_enrich_habit(h, data['pattern_id'], idx)
        if enriched:
            enriched_habits.append(enriched)

    # Si después del enriquecimiento no hay 6 hábitos válidos, rellenar con fallbacks
    if len(enriched_habits) < 6:
        needed = 6 - len(enriched_habits)
        print(f"🔁 Rellenando {needed} hábitos con fallbacks para {data.get('pattern_id')}")
        # intentar diversificar categorías
        existing_cats = [eh['category'] for eh in enriched_habits]
        idx_offset = len(enriched_habits)
        # fill with fallbacks prioritizing categories not present
        for cat in ['spiritual', 'physical', 'mental', 'relational']:
            if needed <= 0:
                break
            if cat not in existing_cats:
                fb = pick_fallback_for_category(cat, data['pattern_id'], idx_offset)
                enriched_habits.append(fb)
                existing_cats.append(cat)
                idx_offset += 1
                needed -= 1
        # if still needed, add random fallbacks
        while needed > 0:
            fb = pick_fallback_for_category(random.choice(['spiritual','physical','mental','relational']), data['pattern_id'], idx_offset)
            enriched_habits.append(fb)
            idx_offset += 1
            needed -= 1

    # Asegurar variedad de categorías
    cats = {hh['category'] for hh in enriched_habits}
    if len(cats) < 3:
        for hh in enriched_habits:
            if hh['category'] == 'other':
                hh['category'] = 'mental'
        cats = {hh['category'] for hh in enriched_habits}

    # Asegurar al menos 2 hábitos >= 10 minutos
    long_count = sum(1 for hh in enriched_habits if hh['target_minutes'] >= 10)
    if long_count < 2:
        for hh in enriched_habits[:2]:
            if hh['target_minutes'] < 10:
                hh['target_minutes'] = 10

    data['habits'] = enriched_habits
    data['scenario_id'] = scenario_id
    data['fingerprint'] = {
        'primaryIntent': intent,
        'motivations': scenario.get('motivations') or scenario.get('goals') or [scenario.get('spiritual'), scenario.get('wellness')],
        'challenge': scenario['challenge'],
        'spiritualMaturity': scenario.get('maturity') or scenario.get('state')
    }

    return data

def generate_random_scenario() -> dict:
    """Genera un escenario aleatorio balanceado"""
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
    else:  # both
        return {
            "intent": "both",
            "spiritual": random.choice(BOTH_SPIRITUAL),
            "wellness": random.choice(BOTH_WELLNESS),
            "challenge": random.choice(CHALLENGES)
        }

def generate_scenario_id(scenario: dict) -> str:
    """Genera ID único para evitar duplicados"""
    scenario_str = json.dumps(scenario, sort_keys=True)
    return hashlib.md5(scenario_str.encode()).hexdigest()[:12]

def load_existing_ids(filepath: str) -> set:
    """Carga IDs ya generados para evitar duplicados"""
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return {t['scenario_id'] for t in data.get('templates', [])}
    return set()

def generate_language_file(lang_code: str):
    """Genera templates-{lang}.json con escenarios únicos dinámicos"""
    
    lang_name = LANGUAGES[lang_code]
    output_file = f"habit_templates/templates-{lang_code}.json"
    
    print(f"\n{'='*60}")
    print(f"🌍 {lang_name.upper()} ({lang_code})")
    print(f"{'='*60}\n")
    
    # Cargar IDs existentes para evitar duplicados
    existing_ids = load_existing_ids(output_file)
    
    templates_data = {
        "version": "1.0",
        "language": lang_code,
        "generated_at": datetime.now().isoformat(),
        "templates": []
    }
    
    # Si el archivo existe, cargar templates previos
    if os.path.exists(output_file):
        with open(output_file, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
            templates_data["templates"] = existing_data.get("templates", [])
            print(f"📂 Cargados {len(templates_data['templates'])} templates existentes\n")
    
    generated = 0
    errors = 0
    attempts = 0
    max_attempts = MAX_TEMPLATES * 3  # Permite hasta 3x intentos para evitar loops infinitos
    
    while generated < MAX_TEMPLATES and attempts < max_attempts:
        attempts += 1
        
        # Generar escenario aleatorio
        scenario = generate_random_scenario()
        scenario_id = generate_scenario_id(scenario)
        
        # Saltar si ya existe
        if scenario_id in existing_ids:
            continue
        
        try:
            template = generate_template(scenario, lang_code, lang_name, scenario_id)
            templates_data["templates"].append(template)
            existing_ids.add(scenario_id)
            
            generated += 1
            total = len(templates_data["templates"])
            print(f"✅ [{total:3d}/{MAX_TEMPLATES}] {template['pattern_id']}")
            
            # GUARDAR INMEDIATAMENTE después de cada template exitoso
            os.makedirs("habit_templates", exist_ok=True)
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(templates_data, f, ensure_ascii=False, indent=2)
            
            # Rate limit progresivo
            if generated % 10 == 0:
                print(f"💾 Checkpoint: {total} templates guardados")
                time.sleep(3)
            else:
                time.sleep(2)
            
        except Exception as e:
            errors += 1
            error_msg = str(e)
            
            # Guardar progreso aunque haya error
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
    
    # Guardar archivo
    os.makedirs("habit_templates", exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(templates_data, f, ensure_ascii=False, indent=2)
    
    total_templates = len(templates_data["templates"])
    file_size = os.path.getsize(output_file) // 1024
    print(f"\n📊 {lang_code}: {total_templates} templates totales ({generated} nuevos), {errors} errores")
    print(f"💾 {output_file} ({file_size}KB)\n")
    
    if attempts >= max_attempts:
        print(f"⚠️  Alcanzado límite de intentos. Se generaron {generated}/{MAX_TEMPLATES} únicos.")

def pick_fallback_for_category(cat: str, pattern_id: str, idx_offset: int) -> dict:
    pool = FALLBACK_ACTIONS.get(cat, [])
    if not pool:
        pool = FALLBACK_ACTIONS.get('mental')
    choice = random.choice(pool)
    name = choice['name']
    emoji = choice.get('emoji')
    target_minutes = choice.get('target_minutes')
    difficulty = choice.get('difficulty')
    return {
        'name': name,
        'category': cat,
        'emoji': emoji,
        'target_minutes': target_minutes,
        'difficulty': difficulty,
        'predefined_id': safe_predefined_id(pattern_id, idx_offset, name),
        'subtasks': [{'id': hashlib.md5(name.encode()).hexdigest()[:8], 'title': name, 'completed': False}]
    }

if __name__ == "__main__":
    print("🚀 Generador de Templates de Hábitos (Dinámico)")
    print("="*60)
    
    for lang_code in LANGUAGES.keys():
        generate_language_file(lang_code)
    
    print("\n✅ PROCESO COMPLETADO")
    print(f"📁 Archivos generados en: habit_templates/")
