import importlib.util
spec = importlib.util.spec_from_file_location('gen', 'generate_habit_templates_onboarding_V2.0.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# build a stub scenario and call generate_template but bypass model by stubbing response
scenario = {'intent': 'both', 'spiritual': 'closerToGod', 'wellness': 'betterSleep', 'challenge': 'lackOfTime'}
scenario_id = mod.generate_scenario_id(scenario)
pattern_id = f"stub_{scenario_id}"

# Create a raw model-like output with some trivial and some good habits
raw = {
    'pattern_id': pattern_id,
    'habits': [
        {'name': 'Respirar 3 min', 'category': 'mental', 'emoji': '🧘'},
        {'name': 'Beber agua 1 min', 'category': 'physical', 'emoji': '💧'},
        {'name': 'Orar 5 min', 'category': 'spiritual', 'emoji': '🙏'},
        {'name': 'Caminar 5 min', 'category': 'physical', 'emoji': '🚶'},
        {'name': 'Planificar 10 min', 'category': 'mental', 'emoji': '🗓️'},
        {'name': 'Llamar a un amigo 5 min', 'category': 'relational', 'emoji': '📞'},
    ]
}

# Emulate post-processing: validate each habit
enriched = []
for idx, h in enumerate(raw['habits']):
    e = mod.validate_and_enrich_habit(h, raw['pattern_id'], idx)
    if e:
        enriched.append(e)

# If less than 6, fill with fallbacks
if len(enriched) < 6:
    needed = 6 - len(enriched)
    for i in range(needed):
        enriched.append(mod.pick_fallback_for_category(['spiritual','physical','mental','relational'][i%4], raw['pattern_id'], len(enriched)+i))

final = {
    'pattern_id': raw['pattern_id'],
    'habits': enriched,
    'scenario_id': scenario_id,
    'fingerprint': {
        'primaryIntent': scenario.get('intent'),
        'motivations': ['closerToGod', 'betterSleep'],
        'challenge': scenario.get('challenge')
    }
}

import json
print(json.dumps(final, ensure_ascii=False, indent=2))

