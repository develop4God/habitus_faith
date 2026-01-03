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

        # Load all API keys from .env (GEMINI_API_KEY_1, GEMINI_API_KEY_2, ...)
        for i in range(1, 10):  # Support up to 9 keys
            key = os.getenv(f"GEMINI_API_KEY_{i}")
            if key:
                self.keys.append(key)

        # Fallback to single key if numbered keys not found
        if not self.keys:
            key = os.getenv("GEMINI_API_KEY")
            if key:
                self.keys.append(key)

        if not self.keys:
            raise ValueError("No API keys found in .env file. Add GEMINI_API_KEY_1, GEMINI_API_KEY_2, etc.")

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

ALLOWED_EMOJI
