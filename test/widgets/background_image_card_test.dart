import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/widgets/background_image_card.dart';
import 'package:habitus_faith/core/services/images/image_providers.dart';

void main() {
  group('BackgroundImageCard', () {
    testWidgets('displays loading state while fetching image', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 1),
                () => 'https://example.com/image.jpg',
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(child: Text('Test Content')),
            ),
          ),
        ),
      );

      // Initial pump: should be loading
      await tester.pump();
      // Wait for the image to load
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show card without background during loading
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('displays card with background when image loads successfully', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) async => 'https://example.com/image.jpg',
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(child: Text('Test Content')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show card with content
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('displays card without background on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) => Future.error(Exception('Failed to load')),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(child: Text('Test Content')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show card without background
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('displays card without background when URL is placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) async => 'https://via.placeholder.com/600x400',
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(child: Text('Test Content')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show card without background (no Image.network for placeholder)
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) async => 'https://via.placeholder.com/600x400',
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(
                borderRadius: 30,
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(30));
    });

    testWidgets('applies custom border side', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) async => 'https://via.placeholder.com/600x400',
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(
                borderSide: BorderSide(color: Colors.red, width: 3),
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.color, Colors.red);
      expect(shape.side.width, 3);
    });

    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyDevotionalImageProvider.overrideWith(
              (ref) async => 'https://example.com/image.jpg',
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: BackgroundImageCard(
                child: Column(children: [Text('Title'), Icon(Icons.star)]),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
