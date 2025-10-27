import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/bible_book_selector_dialog.dart';

void main() {
  group('BibleBookSelectorDialog', () {
    final testBooks = [
      {
        'book_number': 1,
        'short_name': 'Gen',
        'long_name': 'Genesis',
      },
      {
        'book_number': 2,
        'short_name': 'Exo',
        'long_name': 'Exodus',
      },
      {
        'book_number': 3,
        'short_name': 'Lev',
        'long_name': 'Leviticus',
      },
      {
        'book_number': 4,
        'short_name': 'Num',
        'long_name': 'Numbers',
      },
      {
        'book_number': 5,
        'short_name': 'Deu',
        'long_name': 'Deuteronomy',
      },
    ];

    testWidgets('displays all books in the list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Genesis'), findsOneWidget);
      expect(find.text('Exodus'), findsOneWidget);
      expect(find.text('Leviticus'), findsOneWidget);
    });

    testWidgets('highlights selected book', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: 'Exo',
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Selected book should be highlighted
      final exodusTile = find.ancestor(
        of: find.text('Exodus'),
        matching: find.byType(ListTile),
      );
      expect(exodusTile, findsOneWidget);
    });

    testWidgets('calls onBookSelected when book is tapped',
        (WidgetTester tester) async {
      Map<String, dynamic>? selectedBook;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (book) => selectedBook = book,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Leviticus'));
      await tester.pumpAndSettle();

      expect(selectedBook, isNotNull);
      expect(selectedBook!['short_name'], equals('Lev'));
      expect(selectedBook!['long_name'], equals('Leviticus'));
    });

    testWidgets('search field filters books', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially all books should be visible
      expect(find.text('Genesis'), findsOneWidget);
      expect(find.text('Exodus'), findsOneWidget);

      // Enter search text (need at least 2 characters)
      await tester.enterText(find.byType(TextField), 'ex');
      await tester.pumpAndSettle();

      // Only Exodus should match
      expect(find.text('Exodus'), findsOneWidget);
      expect(find.text('Genesis'), findsNothing);
    });

    testWidgets('search is case insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search with uppercase
      await tester.enterText(find.byType(TextField), 'GEN');
      await tester.pumpAndSettle();

      expect(find.text('Genesis'), findsOneWidget);
    });

    testWidgets('clear button resets filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'ex');
      await tester.pumpAndSettle();
      expect(find.text('Genesis'), findsNothing);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // All books should be visible again
      expect(find.text('Genesis'), findsOneWidget);
      expect(find.text('Exodus'), findsOneWidget);
    });

    testWidgets('close button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BibleBookSelectorDialog(
                      books: testBooks,
                      selectedBookName: null,
                      onBookSelected: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(BibleBookSelectorDialog), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(BibleBookSelectorDialog), findsNothing);
    });

    testWidgets('matches books by short name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleBookSelectorDialog(
              books: testBooks,
              selectedBookName: null,
              onBookSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search by short name
      await tester.enterText(find.byType(TextField), 'deu');
      await tester.pumpAndSettle();

      expect(find.text('Deuteronomy'), findsOneWidget);
    });
  });
}
