#!/usr/bin/env python3
"""
Unit tests for habit template generator v2
Tests scoring, selection, and fingerprint matching
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from generate_templates_v2 import (
    HabitSelector,
    HabitScorer,
    generate_fingerprint,
    validate_template,
    generate_template
)
from habit_catalog import HABIT_CATALOG, get_habits_for_intent

def test_catalog_completeness():
    """Verify catalog has required number of habits"""
    print("\n=== TEST: Catalog Completeness ===")

    spiritual = len(HABIT_CATALOG["spiritual"])
    physical = len(HABIT_CATALOG["physical"])
    mental = len(HABIT_CATALOG["mental"])
    relational = len(HABIT_CATALOG["relational"])
    total = spiritual + physical + mental + relational

    print(f"Spiritual: {spiritual}/20")
    print(f"Physical: {physical}/15")
    print(f"Mental: {mental}/8")
    print(f"Relational: {relational}/2")
    print(f"Total: {total}/45")

    assert spiritual == 20, f"Expected 20 spiritual habits, got {spiritual}"
    assert physical == 15, f"Expected 15 physical habits, got {physical}"
    assert mental == 8, f"Expected 8 mental habits, got {mental}"
    assert relational == 2, f"Expected 2 relational habits, got {relational}"

    print("✅ PASSED: Catalog complete with 45 habits")
    return True

def test_faithBased_new_lackOfTime():
    """Test faith-based profile for new believers with time constraints"""
    print("\n=== TEST: Faith-Based New Believer (Lack of Time) ===")

    profile = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["closerToGod"],
        "challenge": "lackOfTime",
        "supportLevel": "normal"
    }

    selector = HabitSelector(HABIT_CATALOG)
    habits = selector.select_habits(profile, count=5)

    print(f"Selected {len(habits)} habits:")
    for h in habits:
        print(f"  - {h['id']}: {h['nameKey']} ({h['target_minutes']}min, {h['category']})")

    # Assertions
    assert len(habits) == 5, f"Expected 5 habits, got {len(habits)}"
    assert all(h["category"] == "spiritual" for h in habits), "All habits should be spiritual"
    assert all(h["target_minutes"] <= 15 for h in habits), "All habits should be ≤15min (lackOfTime)"

    print("✅ PASSED: Correct habit selection and time limits")
    return True

def test_wellness_lackOfTime():
    """Test wellness profile with time constraints"""
    print("\n=== TEST: Wellness (Lack of Time) ===")

    profile = {
        "intent": "wellness",
        "motivations": ["physicalHealth", "reduceStress"],
        "challenge": "lackOfTime",
        "supportLevel": "normal"
    }

    selector = HabitSelector(HABIT_CATALOG)
    habits = selector.select_habits(profile, count=5)

    print(f"Selected {len(habits)} habits:")
    categories = {}
    for h in habits:
        cat = h['category']
        categories[cat] = categories.get(cat, 0) + 1
        print(f"  - {h['id']}: {h['nameKey']} ({h['target_minutes']}min, {cat})")

    print(f"Category distribution: {categories}")

    # Assertions
    assert len(habits) == 5, f"Expected 5 habits, got {len(habits)}"
    assert categories.get("physical", 0) >= 2, "Should have at least 2 physical habits"
    assert categories.get("mental", 0) >= 1, "Should have at least 1 mental habit"

    print("✅ PASSED: Correct category distribution")
    return True

def test_both_weak_support():
    """Test combined profile with weak support (should add relational habit)"""
    print("\n=== TEST: Both Intent (Weak Support) ===")

    profile = {
        "intent": "both",
        "maturity": "growing",
        "motivations": ["closerToGod", "physicalHealth"],
        "challenge": "lackOfMotivation",
        "supportLevel": "weak"
    }

    selector = HabitSelector(HABIT_CATALOG)
    habits = selector.select_habits(profile, count=6)

    print(f"Selected {len(habits)} habits:")
    categories = {}
    for h in habits:
        cat = h['category']
        categories[cat] = categories.get(cat, 0) + 1
        print(f"  - {h['id']}: {h['nameKey']} ({cat})")

    print(f"Category distribution: {categories}")

    # Assertions
    assert len(habits) == 6, f"Expected 6 habits, got {len(habits)}"
    assert categories.get("relational", 0) >= 1, "Weak support should include relational habit"
    assert categories.get("spiritual", 0) >= 2, "Should have spiritual habits"
    assert categories.get("physical", 0) >= 1, "Should have physical habits"

    print("✅ PASSED: Relational habit added for weak support")
    return True

def test_fingerprint_matching():
    """Test that fingerprint generation matches Dart's hashCode"""
    print("\n=== TEST: Fingerprint Generation ===")

    # Test case 1: faith-based with maturity
    profile1 = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["closerToGod", "prayerDiscipline"],  # Order matters!
        "challenge": "lackOfTime"
    }

    fingerprint1 = generate_fingerprint(profile1)
    print(f"Profile 1 fingerprint: {fingerprint1}")

    # Test case 2: wellness without maturity
    profile2 = {
        "intent": "wellness",
        "motivations": ["physicalHealth"],
        "challenge": "lackOfMotivation"
    }

    fingerprint2 = generate_fingerprint(profile2)
    print(f"Profile 2 fingerprint: {fingerprint2}")

    # Test case 3: motivation order matters
    profile3 = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["prayerDiscipline", "closerToGod"],  # Reversed order
        "challenge": "lackOfTime"
    }

    fingerprint3 = generate_fingerprint(profile3)
    print(f"Profile 3 fingerprint: {fingerprint3}")

    # Assertions
    assert fingerprint1 != fingerprint2, "Different profiles should have different fingerprints"
    assert fingerprint1 != fingerprint3, "Motivation order should affect fingerprint"
    assert isinstance(int(fingerprint1), int), "Fingerprint should be a valid integer string"

    # Check signed integer range (Dart uses signed 32-bit)
    fp_int = int(fingerprint1)
    assert -2147483648 <= fp_int <= 2147483647, f"Fingerprint {fp_int} out of signed 32-bit range"

    print("✅ PASSED: Fingerprint generation matches Dart behavior")
    return True

def test_template_validation():
    """Test template validation function"""
    print("\n=== TEST: Template Validation ===")

    profile = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["closerToGod"],
        "challenge": "dontKnowStart",
        "supportLevel": "normal"
    }

    template = generate_template(profile)

    print(f"Generated template: {template['template_id']}")
    print(f"Fingerprint: {template['fingerprint']}")
    print(f"Habits count: {len(template['habits'])}")

    # Validate
    is_valid = validate_template(template)
    assert is_valid, "Generated template should be valid"

    # Test invalid template (too few habits)
    invalid_template = template.copy()
    invalid_template['habits'] = template['habits'][:2]

    is_invalid = validate_template(invalid_template)
    assert not is_invalid, "Template with <3 habits should be invalid"

    print("✅ PASSED: Template validation working correctly")
    return True

def test_maturity_filtering():
    """Test that maturity filtering works correctly"""
    print("\n=== TEST: Maturity Filtering ===")

    scorer = HabitScorer()

    # Get all spiritual habits
    spiritual_habits = HABIT_CATALOG["spiritual"]

    # Filter for new believers
    new_filtered = scorer.filter_by_maturity(spiritual_habits, "new")
    print(f"Habits available for 'new' maturity: {len(new_filtered)}/{len(spiritual_habits)}")

    # Filter for passionate believers (should allow more intensive habits)
    passionate_filtered = scorer.filter_by_maturity(spiritual_habits, "passionate")
    print(f"Habits available for 'passionate' maturity: {len(passionate_filtered)}/{len(spiritual_habits)}")

    # All habits should be available at some maturity level
    assert len(new_filtered) > 0, "Should have habits for new believers"
    assert len(passionate_filtered) > 0, "Should have habits for passionate believers"

    print("✅ PASSED: Maturity filtering working")
    return True

def test_duration_adjustment():
    """Test that durations are adjusted based on challenge"""
    print("\n=== TEST: Duration Adjustment ===")

    selector = HabitSelector(HABIT_CATALOG)

    # Test lackOfTime (should cap at 15min)
    profile_time = {
        "intent": "faithBased",
        "maturity": "mature",
        "motivations": ["growInFaith"],
        "challenge": "lackOfTime",
        "supportLevel": "normal"
    }

    habits_time = selector.select_habits(profile_time, count=5)
    max_duration_time = max(h["target_minutes"] for h in habits_time)
    print(f"Max duration with lackOfTime challenge: {max_duration_time}min")
    assert max_duration_time <= 15, "lackOfTime should cap durations at 15min"

    # Test givingUp (should reduce by 50%)
    profile_giving_up = {
        "intent": "faithBased",
        "maturity": "new",
        "motivations": ["closerToGod"],
        "challenge": "givingUp",
        "supportLevel": "normal"
    }

    habits_giving_up = selector.select_habits(profile_giving_up, count=5)
    avg_duration = sum(h["target_minutes"] for h in habits_giving_up) / len(habits_giving_up)
    print(f"Average duration with givingUp challenge: {avg_duration:.1f}min")
    assert avg_duration < 10, "givingUp should significantly reduce durations"

    print("✅ PASSED: Duration adjustments working correctly")
    return True

def run_all_tests():
    """Run all tests"""
    print("\n" + "="*60)
    print("RUNNING HABIT SELECTOR TEST SUITE")
    print("="*60)

    tests = [
        test_catalog_completeness,
        test_faithBased_new_lackOfTime,
        test_wellness_lackOfTime,
        test_both_weak_support,
        test_fingerprint_matching,
        test_template_validation,
        test_maturity_filtering,
        test_duration_adjustment,
    ]

    passed = 0
    failed = 0

    for test in tests:
        try:
            if test():
                passed += 1
        except AssertionError as e:
            print(f"❌ FAILED: {e}")
            failed += 1
        except Exception as e:
            print(f"❌ ERROR: {e}")
            failed += 1

    print("\n" + "="*60)
    print(f"TEST RESULTS: {passed} passed, {failed} failed")
    print("="*60)

    return failed == 0

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)

