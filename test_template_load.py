#!/usr/bin/env python3
"""
Test rápido para verificar que los templates se pueden cargar
"""

import json

# Cargar un template de ejemplo
with open('assets/habit_templates_v2/1689162142.json', 'r') as f:
    template = json.load(f)

print("✅ Template cargado correctamente")
print(f"   ID: {template['template_id']}")
print(f"   Fingerprint: {template['fingerprint']}")
print(f"   Hábitos: {len(template['habits'])}")
print()

# Verificar estructura
assert 'template_id' in template
assert 'fingerprint' in template
assert 'version' in template
assert 'profile' in template
assert 'habits' in template
assert len(template['habits']) >= 3

print("✅ Estructura validada")
print()

# Mostrar primer hábito
habit = template['habits'][0]
print("📝 Primer hábito de ejemplo:")
print(f"   ID: {habit['id']}")
print(f"   Name Key: {habit['nameKey']}")
print(f"   Category: {habit['category']}")
print(f"   Emoji: {habit['emoji']}")
print(f"   Duration: {habit['target_minutes']} min")
print()

print("🎉 ¡Todo listo para usar los templates!")

