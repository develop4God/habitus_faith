#!/usr/bin/env python3
"""
Integration test: Verify Python templates match Dart expectations
Tests the complete flow from onboarding profile to template loading
"""

import json
import os
from pathlib import Path
from typing import Dict
from generate_templates_v2 import generate_fingerprint

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    END = '\033[0m'

def simulate_dart_fingerprint(intent: str, maturity: str, motivations: list, challenge: str) -> str:
    """Simulate what Dart's cacheFingerprint would generate"""
    # This matches onboarding_models.dart line 80-82
    key = f"{intent}_{maturity}_{'_'.join(motivations)}_{challenge}"

    # Simulate Dart's Jenkins hash
    h = 0
    for char in key:
        h = (h + ord(char)) & 0xFFFFFFFF
        h = (h + (h << 10)) & 0xFFFFFFFF
        h = (h ^ (h >> 6)) & 0xFFFFFFFF
    h = (h + (h << 3)) & 0xFFFFFFFF
    h = (h ^ (h >> 11)) & 0xFFFFFFFF
    h = (h + (h << 15)) & 0xFFFFFFFF

    # Convert to signed 32-bit integer
    if h >= 0x80000000:
        h = h - 0x100000000

    return str(h)

def test_onboarding_scenarios():
    """Test realistic onboarding scenarios"""
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}ONBOARDING SCENARIO TESTS{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}\n")

    scenarios = [
        {
            "name": "New believer, busy schedule, wants to pray more",
            "profile": {
                "intent": "faithBased",
                "maturity": "new",
                "motivations": ["closerToGod"],
                "challenge": "lackOfTime"
            },
            "expected_habits": {
                "count": 5,
                "categories": ["spiritual"],
                "max_duration": 15
            }
        },
        {
            "name": "Wellness user wants to reduce stress",
            "profile": {
                "intent": "wellness",
                "maturity": "",
                "motivations": ["reduceStress"],
                "challenge": "lackOfMotivation"
            },
            "expected_habits": {
                "count": 5,
                "categories": ["physical", "mental"]
            }
        },
        {
            "name": "Growing Christian + physical health, weak support",
            "profile": {
                "intent": "both",
                "maturity": "growing",
                "motivations": ["closerToGod", "physicalHealth"],
                "challenge": "lackOfTime"
            },
            "expected_habits": {
                "count": 5,
                "categories": ["spiritual", "physical"]
            }
        },
        {
            "name": "Mature believer, understand Bible better",
            "profile": {
                "intent": "faithBased",
                "maturity": "mature",
                "motivations": ["understandBible", "growInFaith"],
                "challenge": "lackOfTime"
            },
            "expected_habits": {
                "count": 5,
                "categories": ["spiritual"]
            }
        }
    ]

    templates_dir = Path("habit_templates_v2")
    passed = 0
    failed = 0

    for i, scenario in enumerate(scenarios, 1):
        print(f"{Colors.BLUE}[{i}/{len(scenarios)}] {scenario['name']}{Colors.END}")
        profile = scenario["profile"]

        # Generate fingerprint
        fingerprint = generate_fingerprint(profile)
        print(f"  Fingerprint: {fingerprint}")

        # Check if template exists
        template_path = templates_dir / f"{fingerprint}.json"
        if not template_path.exists():
            print(f"  {Colors.RED}✗ Template not found{Colors.END}\n")
            failed += 1
            continue

        # Load and validate template
        with open(template_path) as f:
            template = json.load(f)

        habits = template.get("habits", [])
        expected = scenario["expected_habits"]

        # Validate habit count
        if len(habits) != expected["count"]:
            print(f"  {Colors.YELLOW}⚠ Expected {expected['count']} habits, got {len(habits)}{Colors.END}")

        # Validate categories
        categories = set(h["category"] for h in habits)
        expected_cats = set(expected["categories"])
        if not categories & expected_cats:
            print(f"  {Colors.RED}✗ Missing expected categories{Colors.END}")
            print(f"    Expected: {expected_cats}, Got: {categories}")
            failed += 1
            continue

        # Validate durations if specified
        if "max_duration" in expected:
            max_dur = max(h["target_minutes"] for h in habits)
            if max_dur > expected["max_duration"]:
                print(f"  {Colors.YELLOW}⚠ Max duration {max_dur} exceeds limit {expected['max_duration']}{Colors.END}")

        # Show habits
        print(f"  {Colors.GREEN}✓ Template valid{Colors.END}")
        print(f"  Habits: {', '.join(h['id'] for h in habits)}")
        print(f"  Categories: {', '.join(sorted(categories))}")
        print()
        passed += 1

    print(f"{Colors.BOLD}Results: {Colors.GREEN}{passed} passed{Colors.END}, {Colors.RED}{failed} failed{Colors.END}\n")
    return failed == 0

def test_fingerprint_consistency():
    """Test that Python and simulated Dart generate same fingerprints"""
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}FINGERPRINT CONSISTENCY TEST{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}\n")

    test_cases = [
        {
            "intent": "faithBased",
            "maturity": "new",
            "motivations": ["closerToGod"],
            "challenge": "lackOfTime"
        },
        {
            "intent": "wellness",
            "maturity": "",
            "motivations": ["physicalHealth", "reduceStress"],
            "challenge": "dontKnowStart"
        },
        {
            "intent": "both",
            "maturity": "passionate",
            "motivations": ["closerToGod", "prayerDiscipline", "physicalHealth"],
            "challenge": "lackOfTime"
        }
    ]

    all_match = True
    for case in test_cases:
        python_fp = generate_fingerprint(case)
        dart_fp = simulate_dart_fingerprint(
            case["intent"],
            case["maturity"],
            case["motivations"],
            case["challenge"]
        )

        match = python_fp == dart_fp
        symbol = f"{Colors.GREEN}✓{Colors.END}" if match else f"{Colors.RED}✗{Colors.END}"

        print(f"{symbol} {case['intent']}/{case['maturity'] or 'none'}/{case['challenge']}")
        print(f"  Python: {python_fp}")
        print(f"  Dart:   {dart_fp}")
        print()

        if not match:
            all_match = False

    if all_match:
        print(f"{Colors.GREEN}✓ All fingerprints match!{Colors.END}\n")
    else:
        print(f"{Colors.RED}✗ Some fingerprints don't match{Colors.END}\n")

    return all_match

def test_template_coverage():
    """Test that we have good coverage of the profile space"""
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}TEMPLATE COVERAGE ANALYSIS{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}\n")

    templates_dir = Path("habit_templates_v2")
    templates = list(templates_dir.glob("*.json"))

    # Analyze coverage
    intents = set()
    maturities = set()
    challenges = set()
    support_levels = set()

    for template_path in templates:
        with open(template_path) as f:
            template = json.load(f)
            profile = template["profile"]

            intents.add(profile["intent"])
            maturities.add(profile.get("spiritualMaturity"))
            challenges.add(profile["challenge"])
            support_levels.add(profile["supportLevel"])

    print(f"Total templates: {len(templates)}")
    print(f"\nIntents covered: {sorted(i for i in intents if i)}")
    print(f"Maturities covered: {sorted(m for m in maturities if m)}")
    print(f"Challenges covered: {sorted(challenges)}")
    print(f"Support levels covered: {sorted(support_levels)}")

    # Check minimum coverage
    min_templates = 60
    has_all_intents = {"faithBased", "wellness", "both"}.issubset(intents)
    has_all_challenges = {"lackOfTime", "lackOfMotivation", "dontKnowStart", "givingUp"}.issubset(challenges)

    print(f"\n{Colors.BOLD}Coverage Check:{Colors.END}")
    print(f"  Minimum templates (60): {Colors.GREEN}✓{Colors.END}" if len(templates) >= min_templates else f"{Colors.RED}✗{Colors.END}")
    print(f"  All intents: {Colors.GREEN}✓{Colors.END}" if has_all_intents else f"{Colors.RED}✗{Colors.END}")
    print(f"  All challenges: {Colors.GREEN}✓{Colors.END}" if has_all_challenges else f"{Colors.RED}✗{Colors.END}")
    print()

    return len(templates) >= min_templates and has_all_intents and has_all_challenges

if __name__ == "__main__":
    print(f"\n{Colors.BOLD}🧪 HABITUS FAITH TEMPLATE INTEGRATION TEST{Colors.END}\n")

    # Run all tests
    test1 = test_fingerprint_consistency()
    test2 = test_template_coverage()
    test3 = test_onboarding_scenarios()

    # Final summary
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}FINAL SUMMARY{Colors.END}")
    print(f"{Colors.BOLD}{'='*60}{Colors.END}")

    all_passed = test1 and test2 and test3

    if all_passed:
        print(f"\n{Colors.GREEN}{Colors.BOLD}🎉 ALL TESTS PASSED!{Colors.END}")
        print(f"{Colors.GREEN}Templates are ready for integration with Flutter app.{Colors.END}")
        print(f"\n{Colors.BOLD}Next steps:{Colors.END}")
        print(f"  1. Run: flutter pub get")
        print(f"  2. Run: flutter build apk --debug")
        print(f"  3. Test onboarding flow in app")
        exit(0)
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}❌ SOME TESTS FAILED{Colors.END}")
        print(f"{Colors.RED}Fix errors before compiling.{Colors.END}")
        exit(1)

