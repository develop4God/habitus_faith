#!/usr/bin/env python3
import os
import json

TEMPLATE_DIR = os.path.join(os.path.dirname(__file__), '../assets/habit_templates_v2')
MANIFEST_PATH = os.path.join(TEMPLATE_DIR, 'template_manifest.json')

def main():
    fingerprints = []
    for fname in os.listdir(TEMPLATE_DIR):
        if fname.endswith('.json') and fname.isdigit():
            fingerprints.append(fname.replace('.json', ''))
    fingerprints.sort()
    with open(MANIFEST_PATH, 'w', encoding='utf-8') as f:
        json.dump(fingerprints, f, indent=2)
    print(f"✅ Generated manifest with {len(fingerprints)} fingerprints at {MANIFEST_PATH}")

if __name__ == '__main__':
    main()

