import unittest
import importlib.util
import json

spec = importlib.util.spec_from_file_location('gen', 'generate_habit_templates_onboarding_V1.0.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

class TestValidateEnrich(unittest.TestCase):
    def test_trivial_respiration_transforms(self):
        h = {'name': 'Respirar 5 min', 'category': 'mental', 'emoji': '🧘'}
        out = mod.validate_and_enrich_habit(h, 'pattern_test', 0)
        self.assertIsNotNone(out)
        self.assertIn('Respiración guiada', out['name'])
        self.assertGreaterEqual(out['target_minutes'], 5)

    def test_beber_agua_dropped(self):
        h = {'name': 'Beber agua 2 min', 'category': 'physical', 'emoji': '💧'}
        out = mod.validate_and_enrich_habit(h, 'pattern_test', 1)
        self.assertIsNone(out)

    def test_no_duration_assign_min(self):
        h = {'name': 'Orar', 'category': 'spiritual', 'emoji': '🙏'}
        out = mod.validate_and_enrich_habit(h, 'pattern_test', 2)
        self.assertIsNotNone(out)
        self.assertEqual(out['target_minutes'], mod.MIN_DURATION_BY_CATEGORY['spiritual'])

    def test_subtasks_added_for_long(self):
        h = {'name': 'Caminar 20 min', 'category': 'physical', 'emoji': '🚶'}
        out = mod.validate_and_enrich_habit(h, 'pattern_test', 3)
        self.assertIsNotNone(out)
        self.assertTrue(len(out['subtasks']) >= 1)

if __name__ == '__main__':
    unittest.main()

