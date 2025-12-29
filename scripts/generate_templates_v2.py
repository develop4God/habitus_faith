# generate_templates_v2.py
# Rule-based template generator (no AI for base templates)
# Uses scoring engine to select optimal habits from catalog

import json
import os
from typing import List, Dict, Tuple, Optional
from habit_catalog import HABIT_CATALOG, get_habits_for_intent
import hashlib

# ==================== TEMPLATE MATRIX ====================
# 60 strategic profile combinations to generate

TEMPLATE_MATRIX = {
    "faithBased": [
        # new maturity (12 templates)
        {"maturity": "new", "motivations": ["closerToGod"], "challenge": "lackOfTime", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["prayerDiscipline"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["closerToGod", "prayerDiscipline"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["understandBible"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["growInFaith"], "challenge": "dontKnowStart", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["closerToGod"], "challenge": "givingUp", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["prayerDiscipline", "understandBible"], "challenge": "givingUp", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["growInFaith", "closerToGod"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"maturity": "new", "motivations": ["understandBible"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["overcomeHabits"], "challenge": "givingUp", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["prayerDiscipline"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["growInFaith"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        # growing maturity (4 templates)
        {"maturity": "growing", "motivations": ["understandBible", "growInFaith"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["closerToGod", "prayerDiscipline"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["prayerDiscipline"], "challenge": "givingUp", "supportLevel": "weak"},
        {"maturity": "growing", "motivations": ["overcomeHabits", "closerToGod"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        # mature maturity (4 templates)
        {"maturity": "mature", "motivations": ["understandBible", "growInFaith"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"maturity": "mature", "motivations": ["closerToGod", "prayerDiscipline"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "mature", "motivations": ["overcomeHabits"], "challenge": "givingUp", "supportLevel": "normal"},
        {"maturity": "mature", "motivations": ["growInFaith"], "challenge": "dontKnowStart", "supportLevel": "strong"},
        # passionate maturity (4 templates)
        {"maturity": "passionate", "motivations": ["closerToGod", "prayerDiscipline", "understandBible"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"maturity": "passionate", "motivations": ["growInFaith", "overcomeHabits"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "passionate", "motivations": ["understandBible"], "challenge": "dontKnowStart", "supportLevel": "strong"},
        {"maturity": "passionate", "motivations": ["closerToGod", "growInFaith"], "challenge": "givingUp", "supportLevel": "normal"}
    ],
    "wellness": [
        # 12 templates covering main motivation combinations
        {"motivations": ["physicalHealth"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"motivations": ["physicalHealth", "reduceStress"], "challenge": "lackOfTime", "supportLevel": "weak"},
        {"motivations": ["timeManagement"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"motivations": ["timeManagement", "productivity"], "challenge": "dontKnowStart", "supportLevel": "weak"},
        {"motivations": ["reduceStress"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        {"motivations": ["reduceStress", "betterSleep"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"motivations": ["productivity"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"motivations": ["betterSleep"], "challenge": "givingUp", "supportLevel": "weak"},
        {"motivations": ["physicalHealth", "timeManagement"], "challenge": "givingUp", "supportLevel": "weak"},
        {"motivations": ["productivity", "reduceStress"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"motivations": ["betterSleep", "physicalHealth"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"motivations": ["timeManagement", "reduceStress"], "challenge": "dontKnowStart", "supportLevel": "weak"}
    ],
    "both": [
        # 24 templates balancing spiritual + wellness
        # new maturity (8 templates)
        {"maturity": "new", "motivations": ["closerToGod", "physicalHealth"], "challenge": "lackOfTime", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["prayerDiscipline", "reduceStress"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["understandBible", "timeManagement"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["growInFaith", "physicalHealth"], "challenge": "givingUp", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["closerToGod", "productivity"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["prayerDiscipline", "betterSleep"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "new", "motivations": ["understandBible", "reduceStress"], "challenge": "dontKnowStart", "supportLevel": "weak"},
        {"maturity": "new", "motivations": ["growInFaith", "timeManagement"], "challenge": "givingUp", "supportLevel": "weak"},
        # growing maturity (8 templates)
        {"maturity": "growing", "motivations": ["closerToGod", "physicalHealth"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["prayerDiscipline", "productivity"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        {"maturity": "growing", "motivations": ["understandBible", "reduceStress"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["overcomeHabits", "timeManagement"], "challenge": "givingUp", "supportLevel": "weak"},
        {"maturity": "growing", "motivations": ["growInFaith", "betterSleep"], "challenge": "lackOfTime", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["closerToGod", "reduceStress"], "challenge": "lackOfMotivation", "supportLevel": "weak"},
        {"maturity": "growing", "motivations": ["prayerDiscipline", "physicalHealth"], "challenge": "dontKnowStart", "supportLevel": "normal"},
        {"maturity": "growing", "motivations": ["understandBible", "productivity"], "challenge": "givingUp", "supportLevel": "normal"},
        # mature maturity (4 templates)
        {"maturity": "mature", "motivations": ["closerToGod", "physicalHealth", "productivity"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"maturity": "mature", "motivations": ["understandBible", "reduceStress"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "mature", "motivations": ["growInFaith", "timeManagement"], "challenge": "dontKnowStart", "supportLevel": "strong"},
        {"maturity": "mature", "motivations": ["overcomeHabits", "betterSleep"], "challenge": "givingUp", "supportLevel": "weak"},
        # passionate maturity (4 templates)
        {"maturity": "passionate", "motivations": ["closerToGod", "prayerDiscipline", "physicalHealth"], "challenge": "lackOfTime", "supportLevel": "strong"},
        {"maturity": "passionate", "motivations": ["understandBible", "growInFaith", "productivity"], "challenge": "lackOfMotivation", "supportLevel": "normal"},
        {"maturity": "passionate", "motivations": ["closerToGod", "reduceStress"], "challenge": "dontKnowStart", "supportLevel": "strong"},
        {"maturity": "passionate", "motivations": ["growInFaith", "timeManagement"], "challenge": "givingUp", "supportLevel": "normal"}
    ]
}

# ==================== SCORING ENGINE ====================

class HabitScorer:
    """Scores habits based on profile match"""

    @staticmethod
    def score_habit(habit: Dict, profile: Dict) -> float:
        """Calculate habit score for given profile"""
        score = habit["priority"]  # Base priority

        # Motivation matching (+20 per match)
        for motivation in profile.get("motivations", []):
            if motivation in habit.get("motivation_match", []):
                score += 20

        # Challenge fit (multiply by fit factor 0.0-1.0)
        challenge = profile.get("challenge", "dontKnowStart")
        challenge_multiplier = habit.get("challenge_fit", {}).get(challenge, 0.5)
        score *= challenge_multiplier

        # Support level boost
        support = profile.get("supportLevel", "normal")
        if support == "weak":
            boost = habit.get("support_boost", {}).get("weak", 1.0)
            score *= boost

        return score

    @staticmethod
    def filter_by_maturity(habits: List[Dict], maturity: Optional[str]) -> List[Dict]:
        """Filter habits that are appropriate for maturity level"""
        if maturity is None:
            # Wellness path - no maturity filtering
            return habits

        filtered = []
        for habit in habits:
            mult = habit.get("maturity_multiplier")
            if mult is None or mult.get(maturity) is not None:
                filtered.append(habit)

        return filtered

# ==================== HABIT SELECTOR ====================

class HabitSelector:
    """Selects optimal habits for a profile"""

    def __init__(self, catalog: Dict):
        self.catalog = catalog
        self.scorer = HabitScorer()

    def select_habits(self, profile: Dict, count: int = 5) -> List[Dict]:
        """Main selection pipeline"""
        intent = profile.get("intent", "faithBased")

        # Step 1: Get appropriate pool
        pool = get_habits_for_intent(intent)

        # Step 2: Filter by maturity
        maturity = profile.get("maturity")
        filtered = self.scorer.filter_by_maturity(pool, maturity)

        # Step 3: Score all habits
        scored = [(self.scorer.score_habit(h, profile), h) for h in filtered]
        scored.sort(reverse=True, key=lambda x: x[0])

        # Step 4: Smart selection by category
        selected = self._smart_select(scored, profile, count)

        # Step 5: Adjust durations
        adjusted = self._adjust_durations(selected, profile)

        return adjusted

    def _smart_select(self, scored_habits: List[Tuple[float, Dict]],
                      profile: Dict, count: int) -> List[Dict]:
        """Select habits ensuring category balance"""
        intent = profile.get("intent")
        selected = []
        used_ids = set()

        if intent == "faithBased":
            # 4-5 spiritual + 0-1 support (physical/mental)
            spiritual = [h for s, h in scored_habits if h["category"] == "spiritual"][:5]
            selected.extend(spiritual)
            used_ids.update(h["id"] for h in spiritual)

            # Add relational if weak support
            if profile.get("supportLevel") == "weak" and len(selected) < count:
                relational = [h for s, h in scored_habits if h["category"] == "relational" and h["id"] not in used_ids][:1]
                selected.extend(relational)

        elif intent == "wellness":
            # 3 physical + 2 mental + (1 relational if weak support)
            physical = [h for s, h in scored_habits if h["category"] == "physical"][:3]
            mental = [h for s, h in scored_habits if h["category"] == "mental"][:2]
            selected.extend(physical)
            selected.extend(mental)
            used_ids.update(h["id"] for h in selected)

            if profile.get("supportLevel") == "weak":
                relational = [h for s, h in scored_habits if h["category"] == "relational" and h["id"] not in used_ids][:1]
                selected.extend(relational)

        else:  # both
            # 3 spiritual + 2 physical + 1 mental (+ relational if weak support)
            spiritual = [h for s, h in scored_habits if h["category"] == "spiritual"][:3]
            physical = [h for s, h in scored_habits if h["category"] == "physical"][:2]
            mental = [h for s, h in scored_habits if h["category"] == "mental"][:1]
            selected.extend(spiritual)
            selected.extend(physical)
            selected.extend(mental)
            used_ids.update(h["id"] for h in selected)

            if profile.get("supportLevel") == "weak" and len(selected) < count:
                relational = [h for s, h in scored_habits if h["category"] == "relational" and h["id"] not in used_ids][:1]
                selected.extend(relational)

        return selected[:count]

    def _adjust_durations(self, habits: List[Dict], profile: Dict) -> List[Dict]:
        """Adjust habit durations based on maturity and challenge"""
        adjusted = []

        for habit in habits:
            h = habit.copy()
            base = h["base_duration"]

            # Apply maturity multiplier
            maturity = profile.get("maturity")
            if maturity and h.get("maturity_multiplier"):
                mult = h["maturity_multiplier"].get(maturity, 1.0)
                duration = int(base * mult)
            else:
                duration = base

            # Challenge adjustments
            challenge = profile.get("challenge", "dontKnowStart")
            if challenge == "lackOfTime":
                duration = min(duration, 15)  # Max 15 min
            elif challenge == "givingUp":
                duration = max(int(duration * 0.5), 5)  # 50% easier, min 5
            elif challenge == "dontKnowStart":
                duration = int(duration * 0.7)  # 30% easier

            h["target_minutes"] = max(duration, 5)  # Never less than 5 min
            adjusted.append(h)

        return adjusted

# ==================== TEMPLATE GENERATOR ====================

def generate_template_id(profile: Dict) -> str:
    """Generate unique template ID from profile"""
    intent = profile["intent"]
    maturity = profile.get("maturity", "none")
    challenge = profile["challenge"]
    support = profile["supportLevel"]
    motivations = "_".join(sorted(profile["motivations"][:2]))

    return f"{intent}_{maturity}_{challenge}_{support}_{motivations}"

def generate_fingerprint(profile: Dict) -> str:
    """Generate cache fingerprint (matches OnboardingProfile.cacheFingerprint)"""
    intent = profile["intent"]
    maturity = profile.get("maturity", "")
    motivations = "_".join(sorted(profile["motivations"]))
    challenge = profile["challenge"]

    key = f"{intent}_{maturity}_{motivations}_{challenge}"
    return str(hash(key) & 0x7FFFFFFF)[:12]  # Positive hash, 12 chars

def generate_template(profile: Dict) -> Dict:
    """Generate single template from profile"""
    selector = HabitSelector(HABIT_CATALOG)

    # Select habits
    habits = selector.select_habits(profile, count=5 if profile.get("supportLevel") != "weak" else 6)

    # Build template structure
    template = {
        "template_id": generate_template_id(profile),
        "fingerprint": generate_fingerprint(profile),
        "version": "2.0",
        "generated_by": "rule_engine",
        "profile": {
            "intent": profile["intent"],
            "motivations": profile["motivations"],
            "challenge": profile["challenge"],
            "supportLevel": profile["supportLevel"],
            "spiritualMaturity": profile.get("maturity")
        },
        "habits": [
            {
                "id": h["id"],
                "nameKey": h["nameKey"],
                "category": h["category"],
                "emoji": h["emoji"],
                "target_minutes": h["target_minutes"],
                "verse_key": h.get("verse_key"),
                "notification_key": h["nameKey"],  # Used for i18n lookup
                "time_of_day": h.get("time_of_day", "flexible")
            }
            for h in habits
        ]
    }

    return template

# ==================== BATCH GENERATOR ====================

def generate_all_templates(output_dir: str = "habit_templates_v2"):
    """Generate all 60 templates"""
    os.makedirs(output_dir, exist_ok=True)

    generated = 0
    for intent, profiles in TEMPLATE_MATRIX.items():
        for profile in profiles:
            profile["intent"] = intent
            template = generate_template(profile)

            # Save template
            filename = f"{template['template_id']}.json"
            filepath = os.path.join(output_dir, filename)

            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(template, f, indent=2, ensure_ascii=False)

            generated += 1
            print(f"✅ [{generated:02d}/60] {template['template_id']}")

    print(f"\n🎉 Generated {generated} templates in {output_dir}/")
    print(f"📊 Size: {sum(os.path.getsize(os.path.join(output_dir, f)) for f in os.listdir(output_dir)) // 1024}KB")

# ==================== MAIN ====================

if __name__ == "__main__":
    print("🚀 Habit Template Generator v2 (Rule-Based)")
    print("="*60)
    generate_all_templates()

