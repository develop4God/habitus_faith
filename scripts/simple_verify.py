#!/usr/bin/env python3
"""
Simple script to verify ONE template fingerprint manually
"""

import json
import sys

def jenkins_hash(s):
    """Calculate Jenkins hash like Dart's String.hashCode"""
    h = 0
    for char in s:
        h = (h + ord(char)) & 0xFFFFFFFF
        h = (h + (h << 10)) & 0xFFFFFFFF
        h = (h ^ (h >> 6)) & 0xFFFFFFFF
    h = (h + (h << 3)) & 0xFFFFFFFF
    h = (h ^ (h >> 11)) & 0xFFFFFFFF
    h = (h + (h << 15)) & 0xFFFFFFFF

    # Convert to signed 32-bit
    if h >= 0x80000000:
        h = h - 0x100000000

    return h

# Load template
print("Loading template 1689162142.json...")
with open('habit_templates_v2/1689162142.json', 'r') as f:
    template = json.load(f)

profile = template['profile']

# Extract fields
intent = profile['intent']
maturity = profile.get('spiritualMaturity', '')
motivations = '_'.join(profile['motivations'])
challenge = profile['challenge']

# Build key
key = f"{intent}_{maturity}_{motivations}_{challenge}"

# Calculate hash
calculated = jenkins_hash(key)
stored = template['fingerprint']

# Results
print(f"\nProfile:")
print(f"  Intent: {intent}")
print(f"  Maturity: {maturity}")
print(f"  Motivations: {profile['motivations']}")
print(f"  Challenge: {challenge}")
print(f"\nFingerprint Calculation:")
print(f"  Key: {key}")
print(f"  Stored: {stored}")
print(f"  Calculated: {calculated}")
print(f"  Match: {str(calculated) == stored}")

if str(calculated) != stored:
    print(f"\n❌ MISMATCH!")
    print(f"   Expected: {stored}")
    print(f"   Got: {calculated}")
    print(f"   Difference: {int(stored) - calculated}")
    sys.exit(1)
else:
    print(f"\n✅ MATCH! Fingerprint is correct.")
    sys.exit(0)

