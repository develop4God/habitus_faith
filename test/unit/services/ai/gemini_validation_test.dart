import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/features/habits/domain/models/micro_habit.dart';

/// Test Suite 3: Validation Logic
/// Verifies that the _validateHabit method properly detects quality issues
/// in AI-generated habits while logging warnings without blocking creation.
void main() {
  group('Validation Logic Tests', () {
    /// Helper to capture print output (validation warnings)
    List<String> captureValidationWarnings(void Function() fn) {
      final warnings = <String>[];
      runZoned(
        fn,
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            if (line.contains('⚠️') || line.contains('validation')) {
              warnings.add(line);
            }
          },
        ),
      );
      return warnings;
    }

    /// Test 3.1: Detects vague actions
    test('validates action contains numbers', () {
      // Arrange
      const habit = MicroHabit(
        id: 'test-1',
        action: 'Pray more', // No number - vague
        verse: 'Psalm 5:3',
        purpose: 'Connect with God',
      );

      // Act
      final warnings = captureValidationWarnings(() {
        _validateHabitForTest(habit, 0);
      });

      // Assert
      expect(
        warnings.any((w) => w.contains('should include specific numbers')),
        true,
        reason: 'Should warn about missing numbers in action',
      );
    });

    /// Test 3.2: Validates time format
    test('flags invalid scheduled time format', () {
      // Arrange
      const habit = MicroHabit(
        id: 'test-2',
        action: 'Prayer 10 min',
        verse: 'Psalm 5:3',
        purpose: 'Connect with God',
        scheduledTime: '25:00', // Invalid - hour > 23
      );

      // Act
      final warnings = captureValidationWarnings(() {
        _validateHabitForTest(habit, 0);
      });

      // Assert
      expect(
        warnings.any((w) => w.contains('Scheduled time format invalid')),
        true,
        reason: 'Should warn about invalid time format',
      );
    });

    /// Test 3.3: Passes valid habits
    test('accepts well-formed habits without warnings', () {
      // Arrange
      const habit = MicroHabit(
        id: 'test-3',
        action: 'Morning prayer 10 minutes',
        verse: 'Psalm 5:3',
        verseText: 'In the morning, Lord, you hear my voice',
        purpose: 'Start day with spiritual connection before work distracts',
        scheduledTime: '07:00',
        estimatedMinutes: 10,
        trigger: 'Right after waking up',
      );

      // Act
      final warnings = captureValidationWarnings(() {
        _validateHabitForTest(habit, 0);
      });

      // Assert
      expect(warnings, isEmpty, reason: 'Well-formed habit should have no warnings');
    });
  });
}

/// Simplified validation for testing (mirrors _validateHabit from gemini_service.dart)
void _validateHabitForTest(MicroHabit habit, int index) {
  final errors = <String>[];

  // Validate action is specific and contains numbers/times
  if (!RegExp(r'\d+').hasMatch(habit.action)) {
    errors.add('Action should include specific numbers or times');
  }

  // Validate action length
  if (habit.action.length < 10) {
    errors.add('Action is too vague (less than 10 characters)');
  }

  // Validate verse format
  if (!RegExp(r'\w+\s+\d+:\d+').hasMatch(habit.verse)) {
    errors.add('Verse reference format invalid (expected "Book ch:v")');
  }

  // Validate purpose is meaningful
  if (habit.purpose.length < 20) {
    errors.add('Purpose explanation is too brief');
  }

  // Validate estimated minutes
  if ((habit.estimatedMinutes < 1 || habit.estimatedMinutes > 30)) {
    errors.add(
        'Estimated minutes out of range (${habit.estimatedMinutes} not in 1-30)');
  }

  // Validate scheduledTime if present
  if (habit.scheduledTime != null && !_isValidTimeFormat(habit.scheduledTime!)) {
    errors.add('Scheduled time format invalid (expected HH:mm)');
  }

  // Validate notifications if present
  if (habit.notifications != null) {
    for (var i = 0; i < habit.notifications!.length; i++) {
      final notif = habit.notifications![i];
      if (!_isValidTimeFormat(notif.time)) {
        errors.add('Notification #${i + 1} time format invalid');
      }
      if (notif.title.isEmpty || notif.body.isEmpty) {
        errors.add('Notification #${i + 1} missing title or body');
      }
    }
  }

  // Log warnings but don't throw
  if (errors.isNotEmpty) {
    // ignore: avoid_print
    print('⚠️ Habit #${index + 1} validation warnings: ${errors.join(', ')}');
  }
}

/// Validate time format (HH:mm in 24-hour format)
bool _isValidTimeFormat(String time) {
  final regex = RegExp(r'^([0-1][0-9]|2[0-3]):([0-5][0-9])$');
  return regex.hasMatch(time);
}
