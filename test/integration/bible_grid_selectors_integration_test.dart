import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/bible_chapter_grid_selector.dart';
import 'package:habitus_faith/widgets/bible_verse_grid_selector.dart';

void main() {
  group('BibleChapterGridSelector Integration Tests', () {
    testWidgets('displays all chapters in grid layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 50,
              selectedChapter: 1,
              onChapterSelected: (chapter) {},
              bookName: 'Genesis',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display chapter numbers in grid
      expect(find.text('1'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);

      // Scroll to see chapter 50
      await tester.dragUntilVisible(
        find.text('50'),
        find.byType(GridView),
        const Offset(0, -100),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('highlights selected chapter correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 50,
              selectedChapter: 25,
              onChapterSelected: (_) {},
              bookName: 'Genesis',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Chapter 25 should be highlighted
      final chapter25Widget = find.text('25');
      expect(chapter25Widget, findsOneWidget);
    });

    testWidgets('calls onChapterSelected when chapter is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 50,
              selectedChapter: 1,
              onChapterSelected: (chapter) {},
              bookName: 'Genesis',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on chapter 10
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
    });

    testWidgets('displays translated chapter count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 150,
              selectedChapter: 1,
              onChapterSelected: (_) {},
              bookName: 'Psalms',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show total chapters text (translated from 'bible.total_chapters')
      // The translation produces "Total chapters {count}"
      final totalChaptersText = find.textContaining('Total chapters');
      expect(totalChaptersText, findsOneWidget);
    });

    testWidgets('displays book name in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 50,
              selectedChapter: 1,
              onChapterSelected: (_) {},
              bookName: 'Genesis',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Genesis'), findsOneWidget);
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
                    builder: (_) => BibleChapterGridSelector(
                      totalChapters: 50,
                      selectedChapter: 1,
                      onChapterSelected: (_) {},
                      bookName: 'Genesis',
                    ),
                  );
                },
                child: const Text('Show Selector'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Selector'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(BibleChapterGridSelector), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(BibleChapterGridSelector), findsNothing);
    });

    testWidgets('grid is scrollable for large chapter counts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 150, // Psalms has 150 chapters
              selectedChapter: 1,
              onChapterSelected: (_) {},
              bookName: 'Psalms',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to find chapter 1
      expect(find.text('1'), findsOneWidget);

      // Scroll to see chapter 150
      await tester.dragUntilVisible(
        find.text('150'),
        find.byType(GridView),
        const Offset(0, -100),
      );

      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('handles single chapter book correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 1,
              selectedChapter: 1,
              onChapterSelected: (_) {},
              bookName: 'Obadiah',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should only show chapter 1
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });
  });

  group('BibleVerseGridSelector Integration Tests', () {
    testWidgets('displays all verses in grid layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 31,
              selectedVerse: 1,
              onVerseSelected: (verse) {},
              bookName: 'Genesis',
              chapterNumber: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display all 31 verses
      expect(find.text('1'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('highlights selected verse correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 31,
              selectedVerse: 16,
              onVerseSelected: (_) {},
              bookName: 'Genesis',
              chapterNumber: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verse 16 should be highlighted
      final verse16Widget = find.text('16');
      expect(verse16Widget, findsOneWidget);
    });

    testWidgets('calls onVerseSelected when verse is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 31,
              selectedVerse: 1,
              onVerseSelected: (verse) {},
              bookName: 'Genesis',
              chapterNumber: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on verse 20
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
    });

    testWidgets('displays translated verse count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 176, // Psalm 119 has 176 verses
              selectedVerse: 1,
              onVerseSelected: (_) {},
              bookName: 'Psalms',
              chapterNumber: 119,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show total verses text (translated from 'bible.total_verses')
      // The translation produces "Total verses {count}"
      final totalVersesText = find.textContaining('Total verses');
      expect(totalVersesText, findsOneWidget);
    });

    testWidgets('displays book name and chapter in header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 31,
              selectedVerse: 1,
              onVerseSelected: (_) {},
              bookName: 'Genesis',
              chapterNumber: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Genesis 1"
      expect(find.text('Genesis 1'), findsOneWidget);
    });

    testWidgets('grid is scrollable for large verse counts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 176,
              selectedVerse: 1,
              onVerseSelected: (_) {},
              bookName: 'Psalms',
              chapterNumber: 119,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to find verse 1
      expect(find.text('1'), findsOneWidget);

      // Scroll to see verse 176
      await tester.dragUntilVisible(
        find.text('176'),
        find.byType(GridView),
        const Offset(0, -100),
      );

      expect(find.text('176'), findsOneWidget);
    });
  });

  group('Grid Selectors - User Workflow Integration', () {
    testWidgets('chapter selection followed by verse selection workflow', (
      WidgetTester tester,
    ) async {
      // First, select a chapter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleChapterGridSelector(
              totalChapters: 50,
              selectedChapter: 1,
              onChapterSelected: (chapter) {},
              bookName: 'Genesis',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select chapter 3
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      // Now show verse selector for that chapter
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BibleVerseGridSelector(
              totalVerses: 24, // Genesis 3 has 24 verses
              selectedVerse: 1,
              onVerseSelected: (verse) {},
              bookName: 'Genesis',
              chapterNumber: 3,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select verse 16
      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();
    });
  });
}
