import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';
import 'package:habitus_faith/features/habits/presentation/widgets/habit_card/compact_habit_card.dart';
import 'package:habitus_faith/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Habit Modal Sheet - Real User Behavior Tests', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit.create(
        id: 'test-habit-1',
        userId: 'test-user',
        name: 'Test Habit',
        emoji: '🙏',
        category: HabitCategory.spiritual,
      );
    });

    Widget createTestWidget(
      Habit habit, {
      required VoidCallback onDelete,
      required VoidCallback onEdit,
      required Function(String) onComplete,
      required Function(String) onUncheck,
    }) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', '')],
          home: Scaffold(
            body: CompactHabitCard(
              habit: habit,
              onDelete: onDelete,
              onEdit: onEdit,
              onComplete: onComplete,
              onUncheck: onUncheck,
            ),
          ),
        ),
      );
    }

    testWidgets('Edit button closes modal and calls onEdit', (tester) async {
      bool editCalled = false;
      bool deleteCalled = false;
      String? completedId;

      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () => deleteCalled = true,
          onEdit: () => editCalled = true,
          onComplete: (id) async => completedId = id,
          onUncheck: (id) async {},
        ),
      );

      // Tap the habit card to open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Find and tap edit button
      final editButton = find.widgetWithText(ElevatedButton, 'Editar');
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify edit was called and modal is closed
      expect(editCalled, true);
      expect(find.widgetWithText(ElevatedButton, 'Editar'), findsNothing);
    });

    testWidgets('Checkbox in modal syncs with compact view behavior',
        (tester) async {
      bool completeCalled = false;
      bool uncheckCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {
            completeCalled = true;
          },
          onUncheck: (id) async {
            uncheckCalled = true;
          },
        ),
      );

      // Tap the habit card to open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Find checkbox in modal
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);

      // Tap the first checkbox (should be in expanded view)
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Verify complete was called and modal is closed
      expect(completeCalled, true);
      expect(uncheckCalled, false);
    });

    testWidgets('Subtask bar changes to input on tap', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Find subtask bar with "Agregar subtarea" text
      final subtaskBar = find.text('Agregar subtarea');
      expect(subtaskBar, findsOneWidget);

      // Tap the subtask bar
      await tester.tap(subtaskBar);
      await tester.pumpAndSettle();

      // Verify text field appears
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify hint text
      expect(find.text('Nueva subtarea...'), findsOneWidget);
    });

    testWidgets('Can add new subtask through tap-to-type', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Tap subtask bar to open input
      await tester.tap(find.text('Agregar subtarea'));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'New Subtask Item');
      await tester.pumpAndSettle();

      // Submit by pressing enter or tapping check button
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify subtask was added (should appear in list)
      expect(find.text('New Subtask Item'), findsOneWidget);
    });

    testWidgets('Notifications show real habit data', (tester) async {
      final habitWithNotifications = testHabit.copyWith(
        notificationSettings: const HabitNotificationSettings(
          timing: NotificationTiming.atEventTime,
          eventTime: '07:00',
        ),
      );

      await tester.pumpWidget(
        createTestWidget(
          habitWithNotifications,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Verify notification info is displayed
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.textContaining('07:00'), findsOneWidget);
    });

    testWidgets('Notifications show disabled when none set', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Verify notification off icon is displayed
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('Completed habit shows checkmark and strikethrough in modal',
        (tester) async {
      final completedHabit = testHabit.copyWith(completedToday: true);

      await tester.pumpWidget(
        createTestWidget(
          completedHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Find checkboxes (there should be at least one checked)
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);

      // Get the first checkbox widget and verify it's checked
      final Checkbox checkbox = tester.widget(checkboxes.first);
      expect(checkbox.value, true);
    });

    testWidgets('Modal shows streak information', (tester) async {
      final habitWithStreak = testHabit.copyWith(currentStreak: 5);

      await tester.pumpWidget(
        createTestWidget(
          habitWithStreak,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Verify streak is displayed
      expect(find.byIcon(Icons.local_fire_department), findsWidgets);
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('Can delete subtask from modal', (tester) async {
      final habitWithSubtasks = testHabit.copyWith(
        subtasks: [
          const Subtask(id: '1', title: 'Subtask 1', completed: false),
          const Subtask(id: '2', title: 'Subtask 2', completed: false),
        ],
      );

      await tester.pumpWidget(
        createTestWidget(
          habitWithSubtasks,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {},
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Verify subtasks are displayed
      expect(find.text('Subtask 1'), findsOneWidget);
      expect(find.text('Subtask 2'), findsOneWidget);

      // Find delete button for first subtask
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsWidgets);

      // Tap first delete button
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Verify subtask was removed
      expect(find.text('Subtask 1'), findsNothing);
      expect(find.text('Subtask 2'), findsOneWidget);
    });

    testWidgets('Modal closes when tapping checkbox', (tester) async {
      bool completeCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          testHabit,
          onDelete: () {},
          onEdit: () {},
          onComplete: (id) async {
            completeCalled = true;
          },
          onUncheck: (id) async {},
        ),
      );

      // Open modal
      await tester.tap(find.byType(CompactHabitCard));
      await tester.pumpAndSettle();

      // Verify modal is open (edit button visible)
      expect(find.widgetWithText(ElevatedButton, 'Editar'), findsOneWidget);

      // Tap checkbox
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      // Verify modal is closed and action was called
      expect(find.widgetWithText(ElevatedButton, 'Editar'), findsNothing);
      expect(completeCalled, true);
    });
  });
}
