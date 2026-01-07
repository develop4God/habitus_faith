import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/images/devotional_image_normalizer.dart';

void main() {
  group('DevotionalImageNormalizer', () {
    late DevotionalImageNormalizer normalizer;

    setUp(() {
      normalizer = DevotionalImageNormalizer();
    });

    group('normalize', () {
      test('returns empty string when URL is empty', () {
        final result = normalizer.normalize('');
        expect(result, '');
      });

      test('returns original URL for GitHub raw content URLs', () {
        const url =
            'https://raw.githubusercontent.com/user/repo/main/image.jpg';
        final result = normalizer.normalize(url);
        expect(result, url);
      });

      test('returns original URL for GitHub URLs', () {
        const url = 'https://github.com/user/repo/blob/main/image.jpg';
        final result = normalizer.normalize(url);
        expect(result, url);
      });

      test('returns original URL for unknown providers', () {
        const url = 'https://example.com/image.jpg';
        final result = normalizer.normalize(url);
        expect(result, url);
      });

      test('accepts custom width and height parameters', () {
        const url = 'https://example.com/image.jpg';
        final result = normalizer.normalize(url, width: 1200, height: 800);
        // For unknown providers, should return original URL
        expect(result, url);
      });

      test('uses default width and height when not specified', () {
        const url = 'https://example.com/image.jpg';
        final result = normalizer.normalize(url);
        expect(result, url);
      });
    });
  });
}
