#!/usr/bin/env python3
"""Test fingerprint generation"""

from generate_templates_v2 import generate_fingerprint

# Test case from template
profile = {
    "intent": "faithBased",
    "maturity": "new",
    "motivations": ["closerToGod"],
    "challenge": "lackOfTime"
}

fingerprint = generate_fingerprint(profile)
print(f"Python fingerprint: {fingerprint}")
print(f"Expected from file: 1689162142")
print(f"Match: {fingerprint == '1689162142'}")

# Build key manually
key = f"{profile['intent']}_{profile['maturity']}_{profile['motivations'][0]}_{profile['challenge']}"
print(f"\nKey: {key}")

# Dart algorithm (Jenkins hash)
h = 0
for char in key:
    h = (h + ord(char)) & 0xFFFFFFFF
    h = (h + (h << 10)) & 0xFFFFFFFF
    h = (h ^ (h >> 6)) & 0xFFFFFFFF
h = (h + (h << 3)) & 0xFFFFFFFF
h = (h ^ (h >> 11)) & 0xFFFFFFFF
h = (h + (h << 15)) & 0xFFFFFFFF

# Convert to signed 32-bit
if h >= 0x80000000:
    h = h - 0x100000000

print(f"Manual hash: {h}")

