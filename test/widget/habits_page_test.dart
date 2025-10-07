import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:habitus_fe/pages/habits_page.dart';
import 'package:habitus_fe/features/habits/models/habit_model.dart';
import '../helpers/test_providers.dart';

void main() {
  group('HabitsPage Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ProviderContainer container;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      container = createTestContainer(firestore: fakeFirestore);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Muestra "No tienes hábitos" si lista vacía', (WidgetTester tester) async {
      // Arrange & Act
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

    testWidgets('Muestra lista con hábitos existentes', (WidgetTester tester) async {
      // Arrange
      final habit1 = HabitModel.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Oración',
        description: 'Orar diariamente',
      );

      final habit2 = HabitModel.create(
        id: 'habit-2',
        userId: 'test-user',
        name: 'Lectura',
        description: 'Leer la Biblia',
      );

      await fakeFirestore.collection('habits').doc(habit1.id).set(habit1.toFirestore());
      await fakeFirestore.collection('habits').doc(habit2.id).set(habit2.toFirestore());

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
      expect(find.byKey(const Key('habit_card_habit-1')), findsOneWidget);
      expect(find.byKey(const Key('habit_card_habit-2')), findsOneWidget);
    });

    testWidgets('Tap en checkbox → completa hábito (verifica Firestore)', (WidgetTester tester) async {
      // Arrange
      final habit = HabitModel.create(
        id: 'habit-1',
        userId: 'test-user',
        name: 'Oración',
        description: 'Orar diariamente',
      );

      await fakeFirestore.collection('habits').doc(habit.id).set(habit.toFirestore());

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
      await tester.tap(find.byKey(const Key('habit_checkbox_habit-1')));
      await tester.pumpAndSettle();

      // Assert - Verify in Firestore
      final doc = await fakeFirestore.collection('habits').doc('habit-1').get();
      expect(doc.data()!['completedToday'], true);
      expect(doc.data()!['currentStreak'], 1);
    });

    testWidgets('Tap FAB → abre dialog', (WidgetTester tester) async {
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

    testWidgets('Llenar dialog + confirmar → crea hábito (verifica Firestore)', (WidgetTester tester) async {
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

      // Fill in the form
      await tester.enterText(find.byKey(const Key('habit_name_input')), 'Nueva Oración');
      await tester.enterText(find.byKey(const Key('habit_description_input')), 'Orar por la mañana');
      
      // Confirm
      await tester.tap(find.byKey(const Key('confirm_add_habit_button')));
      await tester.pumpAndSettle();

      // Assert - Verify in Firestore
      final snapshot = await fakeFirestore.collection('habits').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Nueva Oración');
      expect(snapshot.docs.first.data()['description'], 'Orar por la mañana');
      
      // Verify UI updated
      expect(find.text('Nueva Oración'), findsOneWidget);
    });

    testWidgets('Tap delete + confirmar → elimina hábito (verifica Firestore)', (WidgetTester tester) async {
      // Arrange
      final habit = HabitModel.create(
        id: 'habit-to-delete',
        userId: 'test-user',
        name: 'To Delete',
        description: 'Will be deleted',
      );

      await fakeFirestore.collection('habits').doc(habit.id).set(habit.toFirestore());

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

      // Verify UI updated
      expect(find.text('To Delete'), findsNothing);
      expect(find.text('No tienes hábitos'), findsOneWidget);
    });
  });
}
