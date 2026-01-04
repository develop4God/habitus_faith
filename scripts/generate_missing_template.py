#!/usr/bin/env python3
"""
Generate missing template for fingerprint 404862177
Quick fix script to generate the specific template causing onboarding failure
"""

import json
import sys
import os

# Add parent directory to path to import modules
sys.path.insert(0, os.path.dirname(__file__))

from generate_templates_v2 import generate_template, validate_template, generate_fingerprint
import logging

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def generate_missing_template():
    """Generate the specific template for fingerprint 404862177"""

    # Profile from log:
    # Intent: wellness
    # Motivations: ["physicalHealth", "reduceStress", "betterSleep"]
    # Challenge: lackOfMotivation
    # Support: weak

    profile = {
        "intent": "wellness",
        "motivations": ["physicalHealth", "reduceStress", "betterSleep"],
        "challenge": "lackOfMotivation",
        "supportLevel": "weak",
        "maturity": None  # wellness has no maturity
    }

    logger.info(f"Generating template for profile: {profile}")

    # Generate fingerprint to verify it matches
    fingerprint = generate_fingerprint(profile)
    logger.info(f"Generated fingerprint: {fingerprint}")

    if fingerprint != "404862177":
        logger.warning(f"⚠️  Fingerprint mismatch! Expected 404862177, got {fingerprint}")
        logger.warning("This might indicate a fingerprint generation inconsistency")

    # Generate template
    template = generate_template(profile)

    # Validate
    if not validate_template(template):
        logger.error("❌ Template validation failed!")
        return False

    # Save to assets directory
    output_dir = "../assets/habit_templates_v2"
    os.makedirs(output_dir, exist_ok=True)

    filename = f"{fingerprint}.json"
    filepath = os.path.join(output_dir, filename)

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(template, f, indent=2, ensure_ascii=False)

    logger.info(f"✅ Template saved to: {filepath}")
    logger.info(f"Template contains {len(template['habits'])} habits:")
    for habit in template['habits']:
        logger.info(f"  - {habit['emoji']} {habit['nameKey']} ({habit['target_minutes']}min)")

    return True

if __name__ == "__main__":
    print("🔧 Quick Fix: Generate Missing Template")
    print("="*60)

    success = generate_missing_template()

    if success:
        print("\n✅ SUCCESS: Template generated and validated")
        print("Next steps:")
        print("1. Verify the template file exists in assets/habit_templates_v2/")
        print("2. Rebuild the Flutter app")
        print("3. Test onboarding with wellness intent")
    else:
        print("\n❌ FAILED: Could not generate template")
        sys.exit(1)

