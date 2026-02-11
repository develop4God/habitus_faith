import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/auth_provider.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/features/habits/presentation/household_spinner/household_spinner_page.dart';

void main() {
  testWidgets('Household spinner page screenshot', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(800, 1400);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    final mockHouseholdHabits = [
      Habit(
        id: '1',
        userId: 'test-user',
        name: 'Lavar los platos',
        category: HabitCategory.household,
        emoji: '🍽️',
        createdAt: DateTime(2024, 10, 1),
        completedToday: false,
        currentStreak: 0,
        longestStreak: 0,
        completionHistory: const [],
      ),
      Habit(
        id: '2',
        userId: 'test-user',
        name: 'Aspirar la sala',
        category: HabitCategory.household,
        emoji: '🧹',
        createdAt: DateTime(2024, 10, 1),
        completedToday: false,
        currentStreak: 0,
        longestStreak: 0,
        completionHistory: const [],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userIdProvider.overrideWithValue('test-user'),
          habitsStreamProvider.overrideWith(
            (ref) => Stream.value(mockHouseholdHabits),
          ),
        ],
        child: const MaterialApp(
          home: HouseholdSpinnerPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HouseholdSpinnerPage),
      matchesGoldenFile('../../screenshots/household_spinner_update.png'),
    );
  });
}
