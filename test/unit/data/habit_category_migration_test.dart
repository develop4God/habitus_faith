import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/data/habit_model.dart';

void main() {
  group('HabitCategory Migration', () {
    test('migrates legacy "prayer" to spiritual', () {
      final json = {
        'id': 'test-1',
        'userId': 'user-1',
        'name': 'Morning Prayer',
        'description': 'Pray every morning',
        'category': 'prayer', // Legacy value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.spiritual);
    });

    test('migrates legacy "bibleReading" to spiritual', () {
      final json = {
        'id': 'test-2',
        'userId': 'user-1',
        'name': 'Read Bible',
        'description': 'Daily reading',
        'category': 'bibleReading', // Legacy value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.spiritual);
    });

    test('migrates legacy "service" to relational', () {
      final json = {
        'id': 'test-3',
        'userId': 'user-1',
        'name': 'Volunteer',
        'description': 'Help others',
        'category': 'service', // Legacy value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.relational);
    });

    test('migrates legacy "gratitude" to mental', () {
      final json = {
        'id': 'test-4',
        'userId': 'user-1',
        'name': 'Gratitude Journal',
        'description': 'Write daily',
        'category': 'gratitude', // Legacy value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.mental);
    });

    test('preserves new "spiritual" category', () {
      final json = {
        'id': 'test-5',
        'userId': 'user-1',
        'name': 'Meditation',
        'description': 'Daily meditation',
        'category': 'spiritual', // New value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.spiritual);
    });

    test('preserves new "physical" category', () {
      final json = {
        'id': 'test-6',
        'userId': 'user-1',
        'name': 'Exercise',
        'description': 'Daily workout',
        'category': 'physical', // New value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.physical);
    });

    test('defaults unknown category to spiritual', () {
      final json = {
        'id': 'test-7',
        'userId': 'user-1',
        'name': 'Unknown',
        'description': 'Test',
        'category': 'unknown_category', // Invalid value
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.spiritual);
    });

    test('handles null category with default', () {
      final json = {
        'id': 'test-8',
        'userId': 'user-1',
        'name': 'No Category',
        'description': 'Test',
        // category not provided
        'createdAt': DateTime.now().toIso8601String(),
      };

      final habit = HabitModel.fromJson(json);
      expect(habit.category, HabitCategory.spiritual);
    });
  });
}
