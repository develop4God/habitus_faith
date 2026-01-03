# generate_templates_v2.py
# Rule-based template generator (no AI for base templates)
# Uses scoring engine to select optimal habits from catalog

import json
import os
import logging
from typing import List, Dict, Tuple, Optional
from habit_catalog import HABIT_CATALOG, get_habits_for_intent
import hashlib
import argparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

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
        logger.info(f"Selecting habits for intent={intent}, maturity={profile.get('maturity')}, count={count}")

        # Step 1: Get appropriate pool
        pool = get_habits_for_intent(intent)
        logger.debug(f"Initial pool size: {len(pool)}")

        # Step 2: Filter by maturity
        maturity = profile.get("maturity")
        filtered = self.scorer.filter_by_maturity(pool, maturity)
        logger.debug(f"After maturity filter: {len(filtered)}")

        # Step 3: Score all habits
        scored = [(self.scorer.score_habit(h, profile), h) for h in filtered]
        scored.sort(reverse=True, key=lambda x: x[0])
        logger.debug(f"Top 3 scored habits: {[(h['id'], s) for s, h in scored[:3]]}")

        # Step 4: Smart selection by category
        selected = self._smart_select(scored, profile, count)
        logger.info(f"Selected {len(selected)} habits: {[h['id'] for h in selected]}")

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
            # 4-5 spiritual + 0-1 support (relational if weak support)
            max_spiritual = count - 1 if profile.get("supportLevel") == "weak" else count
            spiritual = [h for s, h in scored_habits if h["category"] == "spiritual" and h["id"] not in used_ids][:max_spiritual]
            selected.extend(spiritual)
            used_ids.update(h["id"] for h in spiritual)

            # Add relational if weak support
            if profile.get("supportLevel") == "weak" and len(selected) < count:
                relational = [h for s, h in scored_habits if h["category"] == "relational" and h["id"] not in used_ids][:1]
                selected.extend(relational)

        elif intent == "wellness":
            # 3 physical + 2 mental + (1 relational if weak support)
            needs_relational = profile.get("supportLevel") == "weak"
            max_physical = 3 if not needs_relational else 2
            max_mental = 2 if not needs_relational else 2

            physical = [h for s, h in scored_habits if h["category"] == "physical" and h["id"] not in used_ids][:max_physical]
            mental = [h for s, h in scored_habits if h["category"] == "mental" and h["id"] not in used_ids][:max_mental]
            selected.extend(physical)
            selected.extend(mental)
            used_ids.update(h["id"] for h in selected)

            if needs_relational and len(selected) < count:
                relational = [h for s, h in scored_habits if h["category"] == "relational" and h["id"] not in used_ids][:1]
                selected.extend(relational)

        else:  # both
            # 3 spiritual + 2 physical + 1 mental (+ relational if weak support)
            needs_relational = profile.get("supportLevel") == "weak"
            max_spiritual = 3 if not needs_relational else 2
            max_physical = 2 if not needs_relational else 2
            max_mental = 1

            spiritual = [h for s, h in scored_habits if h["category"] == "spiritual" and h["id"] not in used_ids][:max_spiritual]
            physical = [h for s, h in scored_habits if h["category"] == "physical" and h["id"] not in used_ids][:max_physical]
            mental = [h for s, h in scored_habits if h["category"] == "mental" and h["id"] not in used_ids][:max_mental]
            selected.extend(spiritual)
            selected.extend(physical)
            selected.extend(mental)
            used_ids.update(h["id"] for h in selected)

            if needs_relational and len(selected) < count:
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

import subprocess
import tempfile

def generate_fingerprint(profile: Dict) -> str:
    """Generate cache fingerprint matching Dart's OnboardingProfile.cacheFingerprint exactly

    CRITICAL: Must match onboarding_models.dart:
    String get cacheFingerprint {
      final key = '${primaryIntent.name}_${spiritualMaturity ?? ''}_${motivations.join('_')}_$challenge';
      return key.hashCode.toString();
    }
    
    Uses Dart directly to compute the hash to ensure 100% accuracy across Dart versions.
    """
    intent = profile["intent"]
    maturity = profile.get("maturity") or ""  # Empty string for wellness (no maturity), handle None
    # DO NOT sort motivations (Dart doesn't sort)
    motivations = "_".join(profile["motivations"])
    challenge = profile["challenge"]

    key = f"{intent}_{maturity}_{motivations}_{challenge}"

    # Call Dart to get the actual hashCode using a temp file
    dart_code = f"void main() {{ print('{key}'.hashCode); }}"
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.dart', delete=False) as f:
        f.write(dart_code)
        temp_path = f.name
    
    try:
        result = subprocess.run(
            ['dart', temp_path],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise RuntimeError(f"Dart hashCode calculation failed: {result.stderr}")
        
        fingerprint = result.stdout.strip()
        return fingerprint
    finally:
        os.unlink(temp_path)

def validate_template(template: Dict) -> bool:
    """Ensure template has required structure and minimum quality"""
    required_fields = ["template_id", "fingerprint", "version", "profile", "habits"]

    # Check required fields
    if not all(k in template for k in required_fields):
        logger.error(f"Template missing required fields: {set(required_fields) - set(template.keys())}")
        return False

    # Check minimum habits count
    if len(template["habits"]) < 3:
        logger.error(f"Template has only {len(template['habits'])} habits (minimum 3)")
        return False

    # Validate each habit has required fields
    habit_required = ["id", "nameKey", "category", "emoji", "target_minutes", "notification_key"]
    for habit in template["habits"]:
        if not all(k in habit for k in habit_required):
            logger.error(f"Habit {habit.get('id', 'unknown')} missing fields: {set(habit_required) - set(habit.keys())}")
            return False

    return True

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

def generate_all_templates(output_dir: str = "habit_templates_v2", max_templates: int = 60):
    """Generate up to max_templates templates"""
    os.makedirs(output_dir, exist_ok=True)
    generated = 0
    failed = 0

    logger.info(f"Starting template generation (max: {max_templates})")

    for intent, profiles in TEMPLATE_MATRIX.items():
        for profile in profiles:
            if generated >= max_templates:
                break

            profile["intent"] = intent

            try:
                template = generate_template(profile)

                # Validate template
                if not validate_template(template):
                    logger.error(f"Validation failed for profile: {profile}")
                    failed += 1
                    continue

                # Save template using fingerprint as filename
                filename = f"{template['fingerprint']}.json"
                filepath = os.path.join(output_dir, filename)

                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(template, f, indent=2, ensure_ascii=False)

                generated += 1
                logger.info(f"✅ [{generated:02d}/{max_templates}] {template['template_id']} -> {filename}")

            except Exception as e:
                logger.error(f"Failed to generate template for {profile}: {e}")
                failed += 1
                continue

        if generated >= max_templates:
            break

    # Summary
    total_size = sum(os.path.getsize(os.path.join(output_dir, f)) for f in os.listdir(output_dir)) // 1024
    logger.info(f"\n{'='*60}")
    logger.info(f"🎉 Generated {generated} templates in {output_dir}/")
    logger.info(f"❌ Failed: {failed}")
    logger.info(f"📊 Total size: {total_size}KB")
    logger.info(f"{'='*60}")

    return generated, failed

# ==================== MAIN ====================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Habit Template Generator v2 (Rule-Based)")
    parser.add_argument('--max', type=int, default=60, help='Maximum number of templates to generate (for UAT)')
    args = parser.parse_args()
    print("🚀 Habit Template Generator v2 (Rule-Based)")
    print("="*60)
    generate_all_templates(max_templates=args.max)
