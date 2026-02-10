import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/presentation/household_spinner/household_spinner_page.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';
import 'package:habitus_faith/core/providers/auth_provider.dart';

void main() {
  group('HouseholdSpinnerPage - User Behavior Tests', () {
    late List<Habit> mockHouseholdHabits;

    setUp(() {
      mockHouseholdHabits = [
        Habit(
          id: '1',
          userId: 'test-user',
          name: 'Lavar los platos',
          category: HabitCategory.household,
          emoji: '🍽️',
          createdAt: DateTime.now(),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        ),
        Habit(
          id: '2',
          userId: 'test-user',
          name: 'Aspirar la sala',
          category: HabitCategory.household,
          emoji: '🧹',
          createdAt: DateTime.now(),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        ),
        Habit(
          id: '3',
          userId: 'test-user',
          name: 'Limpiar el baño',
          category: HabitCategory.household,
          emoji: '🚿',
          createdAt: DateTime.now(),
          completedToday: false,
          currentStreak: 0,
          longestStreak: 0,
          completionHistory: [],
        ),
      ];
    });

    testWidgets(
      'User can see household spinner page when household tasks exist',
      (WidgetTester tester) async {
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

        // Verify page elements
        expect(find.text('🏠 Girar Tareas del Hogar'), findsOneWidget);
        expect(find.text('¡GIRAR!'), findsOneWidget);
        expect(
          find.text('Tareas disponibles (${mockHouseholdHabits.length})'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'User sees empty state when no household tasks exist',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userIdProvider.overrideWithValue('test-user'),
              habitsStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
            ],
            child: const MaterialApp(
              home: HouseholdSpinnerPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify empty state
        expect(find.text('No hay tareas del hogar'), findsOneWidget);
        expect(find.text('Agregar tareas'), findsOneWidget);
      },
    );

    testWidgets(
      'User can tap spin button to select a random task',
      (WidgetTester tester) async {
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

        // Find and tap the spin button
        final spinButton = find.text('¡GIRAR!');
        expect(spinButton, findsOneWidget);

        await tester.tap(spinButton);
        await tester.pump(); // Start animation

        // Verify spinning state
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        // Wait for spin animation (3 seconds)
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Verify dialog appears with a task
        expect(find.text('¡Es hora de esta tarea!'), findsOneWidget);
        expect(find.text('Otro momento'), findsOneWidget);
        expect(find.text('¡Vamos!'), findsOneWidget);
      },
    );

    testWidgets(
      'User can decline task and return to spinner',
      (WidgetTester tester) async {
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

        // Spin to get a task
        await tester.tap(find.text('¡GIRAR!'));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Decline the task
        await tester.tap(find.text('Otro momento'));
        await tester.pumpAndSettle();

        // Verify back to spinner view
        expect(find.text('¡GIRAR!'), findsOneWidget);
      },
    );

    testWidgets(
      'User can start task and see working view with hourglass',
      (WidgetTester tester) async {
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

        // Spin to get a task
        await tester.tap(find.text('¡GIRAR!'));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Start the task
        await tester.tap(find.text('¡Vamos!'));
        await tester.pumpAndSettle();

        // Verify working view
        expect(find.text('Trabajando en la tarea...'), findsOneWidget);
        expect(find.text('Completar'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
      },
    );

    testWidgets(
      'User can cancel task from working view',
      (WidgetTester tester) async {
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

        // Spin and start task
        await tester.tap(find.text('¡GIRAR!'));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        await tester.tap(find.text('¡Vamos!'));
        await tester.pumpAndSettle();

        // Cancel the task
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // Verify back to spinner
        expect(find.text('¡GIRAR!'), findsOneWidget);
      },
    );

    testWidgets(
      'User sees all household tasks in available tasks list',
      (WidgetTester tester) async {
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

        // Verify all tasks are displayed
        for (final task in mockHouseholdHabits) {
          expect(find.text(task.name), findsOneWidget);
        }

        // Verify task count
        expect(
          find.text('Tareas disponibles (${mockHouseholdHabits.length})'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Spinner wheel shows selected task after spinning',
      (WidgetTester tester) async {
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

        // Initial state - home icon
        expect(find.byIcon(Icons.home_rounded), findsWidgets);

        // Spin
        await tester.tap(find.text('¡GIRAR!'));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Close dialog to see spinner wheel result
        await tester.tap(find.text('Otro momento'));
        await tester.pumpAndSettle();

        // Verify a task name appears on the wheel
        // At least one of the tasks should be visible
        final taskNamesOnWheel = mockHouseholdHabits
            .where((task) => find.text(task.name).evaluate().isNotEmpty)
            .toList();
        expect(taskNamesOnWheel.length, greaterThan(0));
      },
    );

    testWidgets(
      'UI is responsive and modern with proper styling',
      (WidgetTester tester) async {
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

        // Verify modern UI elements
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(ElevatedButton), findsWidgets);
        
        // Check for gradient containers (spinner wheel)
        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasGradient = containers.any((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
              decoration.gradient != null;
        });
        expect(hasGradient, isTrue);
      },
    );

    testWidgets(
      'Empty add button navigates back to add tasks',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userIdProvider.overrideWithValue('test-user'),
              habitsStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
            ],
            child: const MaterialApp(
              home: HouseholdSpinnerPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap add tasks button
        final addButton = find.text('Agregar tareas');
        expect(addButton, findsOneWidget);

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should pop the page (navigation tested separately)
        expect(find.text('No hay tareas del hogar'), findsNothing);
      },
    );
  });

  group('HouseholdSpinnerPage - Integration Tests', () {
    testWidgets(
      'Complete user flow: spin -> start -> complete -> celebrate',
      (WidgetTester tester) async {
        final mockHabits = <Habit>[
          Habit(
            id: 'task-1',
            userId: 'user-1',
            name: 'Test Task',
            category: HabitCategory.household,
            emoji: '🧽',
            createdAt: DateTime.now(),
            completedToday: false,
            currentStreak: 0,
            longestStreak: 0,
            completionHistory: [],
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userIdProvider.overrideWithValue('user-1'),
              habitsStreamProvider.overrideWith(
                (ref) => Stream.value(mockHabits),
              ),
            ],
            child: const MaterialApp(
              home: HouseholdSpinnerPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Step 1: Spin
        await tester.tap(find.text('¡GIRAR!'));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // Step 2: Start task
        await tester.tap(find.text('¡Vamos!'));
        await tester.pumpAndSettle();

        expect(find.text('Trabajando en la tarea...'), findsOneWidget);

        // Step 3: Complete task
        await tester.tap(find.text('Completar'));
        await tester.pump(const Duration(seconds: 2)); // Celebration animation
        await tester.pumpAndSettle();

        // Step 4: Verify celebration
        expect(find.text('¡Excelente trabajo!'), findsOneWidget);
        expect(find.text('Tarea completada: Test Task'), findsOneWidget);
      },
    );
  });
}

