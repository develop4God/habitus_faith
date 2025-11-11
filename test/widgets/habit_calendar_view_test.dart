import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/habit_calendar_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('HabitCalendarView no overflow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HabitCalendarView(),
        ),
      ),
    );
    // Espera a que se renderice
    await tester.pumpAndSettle();
    // Verifica que no haya errores de overflow en pantalla
    expect(find.byType(HabitCalendarView), findsOneWidget);
    expect(find.textContaining('overflow'), findsNothing);
  });
}

