import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:habitus_faith/pages/habits_page.dart';
import 'package:habitus_faith/features/habits/domain/habit.dart';
import 'package:habitus_faith/features/habits/data/habit_model.dart';
import '../helpers/test_providers.dart';

void main() {
  group('HabitsPage Widget Tests - Complete User Flows', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer container;
    int idCounter = 0;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      idCounter = 0;
      container = createTestContainer(
        firestore: fakeFirestore,
        idGenerator: () => 'test-id-${idCounter++}',
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Shows empty state when no habits exist',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No tienes hábitos'), findsOneWidget);
    });

    testWidgets('Displays list of existing habits with streaks',
        (WidgetTester tester) async {
      // Arrange
      final habit1 = Habit.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Oración',
        description: 'Orar diariamente',
      ).copyWith(currentStreak: 5, longestStreak: 10);

      final habit2 = Habit.create(
        id: 'habit-2',
        userId: 'test-user',
        name: 'Lectura',
        description: 'Leer la Biblia',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit1.id)
          .set(HabitModel.toFirestore(habit1));
      await fakeFirestore
          .collection('habits')
          .doc(habit2.id)
          .set(HabitModel.toFirestore(habit2));

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Oración'), findsOneWidget);
      expect(find.text('Lectura'), findsOneWidget);
      expect(find.text('Racha: 5 días | Mejor: 10'), findsOneWidget);
      expect(find.byKey(const Key('habit_card_habit-1')), findsOneWidget);
      expect(find.byKey(const Key('habit_card_habit-2')), findsOneWidget);
    });

    testWidgets('Checkbox disabled after completion (prevents unchecking)',
        (WidgetTester tester) async {
      // Arrange
      final habit = Habit.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Oración',
        description: 'Orar diariamente',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit.id)
          .set(HabitModel.toFirestore(habit));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Complete habit
      await tester.tap(find.byKey(const Key('habit_checkbox_habit-1')));
      await tester.pumpAndSettle();

      // Assert - Verify in Firestore
      final doc = await fakeFirestore.collection('habits').doc('habit-1').get();
      expect(doc.data()!['completedToday'], true);
      expect(doc.data()!['currentStreak'], 1);

      // Assert - Checkbox should be checked and disabled
      final checkbox = tester
          .widget<Checkbox>(find.byKey(const Key('habit_checkbox_habit-1')));
      expect(checkbox.value, true);
      expect(checkbox.onChanged, isNull,
          reason: 'Checkbox should be disabled after completion');
    });

    testWidgets('Opens add habit dialog when FAB is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Agregar hábito'), findsOneWidget);
      expect(find.byKey(const Key('habit_name_input')), findsOneWidget);
      expect(find.byKey(const Key('habit_description_input')), findsOneWidget);
      expect(find.byKey(const Key('confirm_add_habit_button')), findsOneWidget);
    });

    testWidgets('Creates habit successfully and displays in list',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - Open dialog
      await tester.tap(find.byKey(const Key('add_habit_fab')));
      await tester.pumpAndSettle();

      // Fill in form
      await tester.enterText(
          find.byKey(const Key('habit_name_input')), 'Nueva Oración');
      await tester.enterText(find.byKey(const Key('habit_description_input')),
          'Orar por la mañana');

      // Confirm
      await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
      await tester.pumpAndSettle();

      // Assert - Verify in Firestore
      final snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Nueva Oración');
      expect(snapshot.docs.first.data()['description'], 'Orar por la mañana');

      // Assert - Verify UI updated
      expect(find.text('Nueva Oración'), findsOneWidget);
      expect(find.text('Orar por la mañana'), findsOneWidget);
    });

    testWidgets('Deletes habit after confirmation',
        (WidgetTester tester) async {
      // Arrange
      final habit = Habit.create(
        id: 'habit-to-delete',
        userId: 'test-user',
        name: 'To Delete',
        description: 'Will be deleted',
      );

      await fakeFirestore
          .collection('habits')
          .doc(habit.id)
          .set(HabitModel.toFirestore(habit));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HabitsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify habit is displayed
      expect(find.text('To Delete'), findsOneWidget);

      // Act - Tap delete button
      await tester.tap(find.byKey(const Key('habit_delete_habit-to-delete')));
      await tester.pumpAndSettle();

      // Confirm deletion
      expect(find.text('Eliminar hábito'), findsOneWidget);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Assert - Verify in Firestore
      final snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 0);

      // Assert - Verify UI updated
      expect(find.text('To Delete'), findsNothing);
      expect(find.text('No tienes hábitos'), findsOneWidget);
    });
  });
}
