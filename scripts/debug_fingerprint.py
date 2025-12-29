#!/usr/bin/env python3
import json
import sys

# Read one template
with open('habit_templates_v2/1689162142.json', 'r') as f:
    template = json.load(f)

profile = template['profile']

# Build key exactly like Dart
intent = profile['intent']
maturity = profile.get('spiritualMaturity', '')
motivations = '_'.join(profile['motivations'])
challenge = profile['challenge']

key = f"{intent}_{maturity}_{motivations}_{challenge}"

# Calculate Jenkins hash
h = 0
for char in key:
    h = (h + ord(char)) & 0xFFFFFFFF
    h = (h + (h << 10)) & 0xFFFFFFFF
    h = (h ^ (h >> 6)) & 0xFFFFFFFF
h = (h + (h << 3)) & 0xFFFFFFFF
h = (h ^ (h >> 11)) & 0xFFFFFFFF
h = (h + (h << 15)) & 0xFFFFFFFF

if h >= 0x80000000:
    h = h - 0x100000000

# Write results to file
with open('fingerprint_debug.txt', 'w') as f:
    f.write(f"Intent: {intent}\n")
    f.write(f"Maturity: {maturity}\n")
    f.write(f"Motivations: {motivations}\n")
    f.write(f"Challenge: {challenge}\n")
    f.write(f"\n")
    f.write(f"Key: {key}\n")
    f.write(f"Stored fingerprint: {template['fingerprint']}\n")
    f.write(f"Calculated hash: {h}\n")
    f.write(f"Match: {str(h) == template['fingerprint']}\n")

print("Results written to fingerprint_debug.txt")

