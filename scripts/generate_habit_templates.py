import os
import google.generativeai as genai
from dotenv import load_dotenv
from tenacity import retry, wait_exponential, stop_after_attempt
import json
import time
from datetime import datetime, timedelta
import hashlib
import random
import re
from collections import deque

load_dotenv()

# ============================================
# API KEY ROTATION MANAGER
# ============================================
class APIKeyManager:
    """Manages multiple API keys with automatic rotation on quota exhaustion"""

    def __init__(self):
        self.keys = []
        self.current_index = 0
        self.exhausted_keys = set()

        # Load all API keys from .env (GOOGLE_API_KEY_1, GOOGLE_API_KEY_2, GOOGLE_API_KEY_3, GOOGLE_API_KEY_4, GOOGLE_API_KEY_5)
        for i in range(1, 10):  # Support up to 9 keys
            key = os.getenv(f"GOOGLE_API_KEY_{i}")
            if key:
                self.keys.append(key)

        # Fallback to single key if numbered keys not found
        if not self.keys:
            key = os.getenv("GOOGLE_API_KEY")
            if key:
                self.keys.append(key)

        if not self.keys:
            raise ValueError("No API keys found in .env file. Add GOOGLE_API_KEY_1, GOOGLE_API_KEY_2, etc.")

        print(f"🔑 Loaded {len(self.keys)} API key(s)")
        self.configure_current_key()

    def configure_current_key(self):
        """Configure Gemini with current API key"""
        if self.current_index < len(self.keys):
            genai.configure(api_key=self.keys[self.current_index])
            print(f"🔄 Using API key #{self.current_index + 1}")

    def rotate_key(self):
        """Switch to next available API key"""
        self.exhausted_keys.add(self.current_index)

        # Find next non-exhausted key
        for i in range(len(self.keys)):
            next_index = (self.current_index + 1 + i) % len(self.keys)
            if next_index not in self.exhausted_keys:
                self.current_index = next_index
                self.configure_current_key()
                print(f"✅ Rotated to API key #{self.current_index + 1}")
                return True

        print(f"❌ All {len(self.keys)} API keys exhausted")
        return False

    def has_available_keys(self):
        """Check if there are non-exhausted keys"""
        return len(self.exhausted_keys) < len(self.keys)

api_key_manager = APIKeyManager()

def get_model():
    """Get fresh model instance with current API key"""
    return genai.GenerativeModel(
        'gemini-2.0-flash-lite', # MODIFICACIÓN 1: Usar el modelo con mejor cuota gratuita (30 RPM/1500 RPD)
        generation_config={
            "temperature": 0.85,
            "max_output_tokens": 1000,
        }
    )

# ============================================
# RATE LIMITER WITH DAILY PERSISTENCE
# ============================================
class RateLimiter:
    """Rate limiting control for Gemini 2.0 Flash (Free tier)"""

    def __init__(self, rpm=30, rpd=1500): # MODIFICACIÓN 2: Ajustar límites a 30 RPM y 1500 RPD
        self.rpm = rpm
        self.rpd = rpd
        self.requests_minute = deque()
        self.requests_day = deque()
        self.state_file = "rate_limiter_state.json"
        self.load_state()

    def load_state(self):
        """Load previous state to track daily usage across script runs"""
        if os.path.exists(self.state_file):
            try:
                with open(self.state_file, 'r') as f:
                    state = json.load(f)
                    today = datetime.now().date().isoformat()
                    # Only restore if it's the same day
                    if state.get('date') == today:
                        # Restore request timestamps from today
                        timestamps = [datetime.fromisoformat(ts) for ts in state.get('timestamps', [])]
                        self.requests_day = deque(timestamps)
                        print(f"📊 Restored state: {len(self.requests_day)} requests already made today")
                    else:
                        print(f"📅 New day - resetting counters")
                        self.requests_day = deque()
            except Exception as e:
                print(f"⚠️  Could not load rate limiter state: {e}")
                self.requests_day = deque()

    def save_state(self):
        """Save current state for next script run"""
        try:
            state = {
                'date': datetime.now().date().isoformat(),
                'timestamps': [ts.isoformat() for ts in self.requests_day]
            }
            with open(self.state_file, 'w') as f:
                json.dump(state, f)
        except Exception as e:
            print(f"⚠️  Could not save rate limiter state: {e}")

    def wait_if_needed(self):
        """Wait if necessary to respect limits"""
        now = datetime.now()

        # Clean old requests (>60 seconds)
        while self.requests_minute and (now - self.requests_minute[0]).total_seconds() > 60:
            self.requests_minute.popleft()

        # Clean old requests (>24 hours)
        while self.requests_day and (now - self.requests_day[0]).total_seconds() > 86400:
            self.requests_day.popleft()

        # Check daily limit
        remaining_today = self.rpd - len(self.requests_day)
        if remaining_today <= 0:
            print(f"⚠️  Daily limit reached ({len(self.requests_day)}/{self.rpd} RPD)")
            print(f"⏰  Resume tomorrow or wait {86400 - (now - self.requests_day[0]).total_seconds():.0f}s")
            return False

        # Check per-minute limit
        if len(self.requests_minute) >= self.rpm:
            wait_time = 60 - (now - self.requests_minute[0]).total_seconds() + 1
            if wait_time > 0:
                print(f"⏱️  Rate limit: waiting {wait_time:.1f}s... ({len(self.requests_minute)}/{self.rpm} RPM)")
                time.sleep(wait_time)
                return self.wait_if_needed()

        # Register request
        self.requests_minute.append(now)
        self.requests_day.append(now)
        self.save_state()

        # Base wait between requests (2.1s = max 28.5 RPM)
        time.sleep(2.1) # MODIFICACIÓN 3: Reducir espera para alcanzar 30 RPM (60s / 30 RPM = 2.0s)
        return True

    def get_stats(self):
        """Return usage statistics"""
        now = datetime.now()
        minute_count = sum(1 for t in self.requests_minute if (now - t).total_seconds() <= 60)
        day_count = len(self.requests_day)
        remaining = self.rpd - day_count
        return {
            "minute": minute_count,
            "day": day_count,
            "remaining": remaining,
            "rpm_limit": self.rpm,
            "rpd_limit": self.rpd
        }

rate_limiter = RateLimiter()

# Show initial status
initial_stats = rate_limiter.get_stats()
print(f"📊 Daily usage: {initial_stats['day']}/{initial_stats['rpd_limit']} RPD ({initial_stats['remaining']} remaining)")

# CONFIGURATION
MAX_TEMPLATES = int(input("Number of templates per language: ").strip() or 5)

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

MIN_DURATION_BY_CATEGORY = {
    "spiritual": 5,
    "physical": 10,
    "mental": 5,
    "relational": 5,
}

TRIVIAL_TERMS = [
    "respirar", "breathing", "beber agua", "tomar agua", "sentarse", "pararse",
    "ir al baño", "lavarse las manos", "parpadear", "mirar el celular", "scroll",
    "drink water", "sit down", "stand up", "blink", "check phone"
]

FALLBACK_ACTIONS = {
    "spiritual": ["Pray 10 min", "Bible reading 10 min", "Spiritual reflection 10 min"],
    "physical": ["Walk 15 min", "Stretching 10 min", "Exercise 20 min"],
    "mental": ["Meditation 10 min", "Planning 15 min", "Gratitude 10 min"],
    "relational": ["Call a friend 10 min", "Family time 20 min", "Community service 30 min"]
}

ALLOWED_EMOJIS = [
    "🚶", "😊", "📖", "💪", "🏃", "🏅", "🕒", "📅", "📞", "👨‍👩‍👧‍👦", "🤝", "🤸", "📝", "🗓️", "😃", "😌", "😇", "✍️", "📚", "🎯", "🧠"
]

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
    if any(x in name for x in ["morning", "mañana", "matin", "manhã", "早上", "早晨"]):
        return "08:00"
    if any(x in name for x in ["night", "evening", "noche", "soir", "noite", "晚上", "夜间"]):
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

def sanitize_emoji(emoji):
    if emoji in ALLOWED_EMOJIS:
        return emoji
    return DEFAULT_EMOJI

def enrich_habit(habit, idx, pattern_id):
    name = habit.get("name", "").strip()
    category = habit.get("category", "other").strip()
    emoji = habit.get("emoji", "")

    if is_trivial(name):
        if "breath" in name.lower() or "respirar" in name.lower():
            name = "Guided breathing 5 min"
            category = "mental"
            emoji = DEFAULT_EMOJI
        else:
            fallback = random.choice(FALLBACK_ACTIONS.get(category, FALLBACK_ACTIONS["mental"]))
            name = fallback
            emoji = DEFAULT_EMOJI

    m = re.search(r"(\d{1,3})\s*(min|mins|minutos|minutes|m|分钟)", name.lower())
    if m:
        minutes = int(m.group(1))
    else:
        minutes = MIN_DURATION_BY_CATEGORY.get(category, 5)

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

@retry(wait=wait_exponential(min=5, max=30), stop=stop_after_attempt(3))
def generate_template(scenario: dict, lang_code: str, lang_name: str, scenario_id: str) -> dict:
    if not rate_limiter.wait_if_needed():
        raise Exception("Daily limit reached")

    intent = scenario["intent"]
    support_level = scenario.get("supportLevel", "normal")

    motivations = scenario.get("motivations") or []
    goals = scenario.get("goals") or []
    spiritual = scenario.get("spiritual")
    wellness = scenario.get("wellness")

    if intent == "faithBased":
        while len(motivations) < 2:
            motivations.append("general")
        context = f"Motivations: {', '.join(motivations)}\nMaturity: {scenario['maturity']}\nChallenge: {scenario['challenge']}\nSupport network: {support_level}"
        pattern_id = f"faith_{scenario['maturity']}_{scenario['challenge']}_{support_level}_{'_'.join(motivations[:2])}"
    elif intent == "wellness":
        while len(goals) < 2:
            goals.append("general")
        context = f"Goals: {', '.join(goals)}\nState: {scenario['state']}\nChallenge: {scenario['challenge']}\nSupport network: {support_level}"
        pattern_id = f"well_{scenario['state']}_{scenario['challenge']}_{support_level}_{'_'.join(goals[:2])}"
    else:
        if not spiritual:
            spiritual = "general"
        if not wellness:
            wellness = "general"
        context = f"Spiritual: {spiritual}\nWellness: {wellness}\nChallenge: {scenario['challenge']}\nSupport network: {support_level}"
        pattern_id = f"both_{spiritual}_{wellness}_{scenario['challenge']}_{support_level}"

    prompt = f"""
Language: {lang_name}
Profile: {intent}
{context}

Generate 5 habits with duration in the name. ALL habit names, notification titles and bodies MUST be in {lang_name}.

ALLOWED CATEGORIES (use only these 4):
- spiritual: prayer, bible reading, spiritual reflection
- physical: exercise, walking, stretching, sleep
- mental: reflection, gratitude, mindfulness, planning
- relational: family, friends, community service

IMPORTANT:
- Use only neutral emojis: 😊, 🚶, 📖, 💪, 🏃, 🏅, 🕒, 📅, 📞, 👨‍👩‍👧‍👦, 🤝, 🤸, 📝, 🗓️, 😃, 😌, 😇, ✍️, 📚, 🎯, 🧠
- Field names in English, but habit names and notifications MUST be in {lang_name}
- Each habit needs 'notifications' array with time, title (engaging in {lang_name}), body (motivational in {lang_name}), enabled
- Distribute notifications throughout the day
- If support level is low, include 2+ relational habits
- Respond ONLY with JSON (no markdown):

{{
  "pattern_id": "{pattern_id}",
  "habits": [
    {{
      "name": "Action + duration in {lang_name}",
      "category": "spiritual|physical|mental|relational",
      "emoji": "emoji",
      "notifications": [{{"time": "HH:MM", "title": "engaging title in {lang_name}", "body": "motivational message in {lang_name}", "enabled": true}}]
    }}
  ]
}}
"""

    model = get_model()  # Get fresh model with current API key
    response = model.generate_content(prompt)
    text = response.text.strip().replace("```json", "").replace("```", "").strip()

    # Fix emoji formatting issues:
    # 1. Remove emojis from habit names (Gemini adds them incorrectly)
    text = re.sub(r'("name":\s*"[^"]*)([\U0001F300-\U0001F9FF])([^"]*")', r'\1\3', text)
    # 2. Fix emoji field without quotes: emoji -> "emoji"
    text = re.sub(r'("emoji":\s*)([^\s",\}]+)(\s*[,\}])', r'\1"\2"\3', text)

    try:
        data = json.loads(text)
    except Exception as e:
        print(f"❌ JSON parse error. Raw: {text[:200]}...")
        raise e

    habits = data.get("habits", [])
    if not isinstance(habits, list) or len(habits) != 5:
        raise ValueError(f"Expected 5 habits, got {len(habits) if isinstance(habits, list) else 'non-list'}")

    for i, h in enumerate(habits):
        if not isinstance(h, dict):
            raise ValueError(f"Habit {i} is not a dict")
        missing = [f for f in ["name", "category", "emoji"] if not h.get(f)]
        if missing:
            raise ValueError(f"Habit {i} missing: {missing}")

    enriched = []
    for i, h in enumerate(habits):
        enriched_habit = enrich_habit(h, i, pattern_id)
        if "notifications" in h:
            enriched_habit["notifications"] = h["notifications"]
        enriched.append(enriched_habit)

    data["habits"] = enriched
    data["scenario_id"] = scenario_id
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
            print(f"📂 Loaded {len(templates_data['templates'])} existing templates\n")

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

            stats = rate_limiter.get_stats()
            print(f"✅ [{total:3d}/{MAX_TEMPLATES}] {template['pattern_id'][:40]} | {stats['day']}/{stats['rpd_limit']} RPD ({stats['remaining']} left)")

            # Save after each successful template
            os.makedirs("habit_templates", exist_ok=True)
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(templates_data, f, ensure_ascii=False, indent=2)

        except Exception as e:
            errors += 1
            error_msg = str(e)
            print(f"❌ Error: {error_msg[:80]}")

            if "daily limit" in error_msg.lower() or "Daily limit" in error_msg:
                print(f"\n⚠️  DAILY LIMIT REACHED")
                print(f"📊 Progress: {generated}/{MAX_TEMPLATES} templates generated for {lang_code}")
                print(f"💾 Saved to: {output_file}")
                print(f"🔄 Run script again tomorrow to continue")
                return False  # Signal to stop processing other languages

            if "429" in error_msg or "ResourceExhausted" in error_msg:
                print(f"⏸️  Rate limit - waiting 60s...")
                time.sleep(60)
            else:
                time.sleep(5)

    # Final save
    os.makedirs("habit_templates", exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(templates_data, f, ensure_ascii=False, indent=2)

    total_templates = len(templates_data["templates"])
    file_size = os.path.getsize(output_file) // 1024

    stats = rate_limiter.get_stats()
    print(f"\n📊 {lang_code}: {total_templates} total ({generated} new), {errors} errors")
    print(f"📈 Daily usage: {stats['day']}/{stats['rpd_limit']} RPD ({stats['remaining']} remaining)")
    print(f"💾 {output_file} ({file_size}KB)\n")

    return True  # Successfully completed

if __name__ == "__main__":
    print("🚀 Habit Template Generator (Multi-Day Support)")
    print("="*60)
    print(f"📝 Templates per language: {MAX_TEMPLATES}")
    print(f"⚙️  Rate limits: 30 RPM, 1500 RPD (Free Tier Gemini 2.0 Flash-Lite)") # MODIFICACIÓN 4: Actualizar impresión de límites
    print(f"⏱️  Est. time: ~{(MAX_TEMPLATES * 2.1 * len(LANGUAGES)) / 60:.1f} min (if enough quota)")
    print("="*60)

    for lang_code in LANGUAGES.keys():
        success = generate_language_file(lang_code)
        if not success:
            print("\n⚠️  STOPPING: Daily limit reached")
            print("🔄 Run this script again tomorrow to continue with remaining languages")
            break

    final_stats = rate_limiter.get_stats()
    print("\n" + "="*60)
    print("✅ SESSION COMPLETED")
    print(f"📊 Total requests today: {final_stats['day']}/{final_stats['rpd_limit']}")
    print(f"📂 Files in: habit_templates/")

    if final_stats['remaining'] < 100:
        print(f"\n⚠️  Low quota remaining: {final_stats['remaining']} requests")
        print("💡 Consider running again tomorrow for remaining templates")