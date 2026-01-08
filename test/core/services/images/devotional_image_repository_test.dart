import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/core/services/images/devotional_image_normalizer.dart';
import 'package:habitus_faith/core/services/images/devotional_image_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockDevotionalImageNormalizer extends Mock
    implements DevotionalImageNormalizer {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('DevotionalImageRepository', () {
    late MockHttpClient mockHttpClient;
    late MockDevotionalImageNormalizer mockNormalizer;
    late MockSharedPreferences mockPrefs;
    late DevotionalImageRepository repository;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockNormalizer = MockDevotionalImageNormalizer();
      mockPrefs = MockSharedPreferences();

      repository = DevotionalImageRepository(
        httpClient: mockHttpClient,
        normalizer: mockNormalizer,
        sharedPreferences: mockPrefs,
      );
    });

    group('getRandomImageUrl', () {
      test('returns normalized URL when images are successfully fetched',
          () async {
        final mockResponse = MockResponse();
        const testImageUrl = 'https://example.com/test.jpg';
        const normalizedUrl = 'https://example.com/test_normalized.jpg';

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "test.jpg", "download_url": "$testImageUrl"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn(normalizedUrl);

        final result = await repository.getRandomImageUrl();

        expect(result, normalizedUrl);
        verify(() =>
                mockNormalizer.normalize(testImageUrl, width: 600, height: 400))
            .called(1);
      });

      test('filters out non-image files', () async {
        final mockResponse = MockResponse();
        const testImageUrl = 'https://example.com/test.jpg';
        const normalizedUrl = 'https://example.com/test_normalized.jpg';

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "readme.md", "download_url": "https://example.com/readme.md"},
            {"type": "file", "name": "test.jpg", "download_url": "$testImageUrl"},
            {"type": "file", "name": "config.json", "download_url": "https://example.com/config.json"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn(normalizedUrl);

        final result = await repository.getRandomImageUrl();

        expect(result, normalizedUrl);
        verify(() =>
                mockNormalizer.normalize(testImageUrl, width: 600, height: 400))
            .called(1);
      });

      test('supports various image formats (jpg, jpeg, png, avif, webp)',
          () async {
        final mockResponse = MockResponse();

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "test1.jpg", "download_url": "https://example.com/test1.jpg"},
            {"type": "file", "name": "test2.JPEG", "download_url": "https://example.com/test2.JPEG"},
            {"type": "file", "name": "test3.png", "download_url": "https://example.com/test3.png"},
            {"type": "file", "name": "test4.avif", "download_url": "https://example.com/test4.avif"},
            {"type": "file", "name": "test5.webp", "download_url": "https://example.com/test5.webp"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn('normalized');

        final result = await repository.getRandomImageUrl();

        expect(result, 'normalized');
        verify(() => mockNormalizer.normalize(any(), width: 600, height: 400))
            .called(1);
      });

      test('returns placeholder when HTTP request fails', () async {
        when(() => mockHttpClient.get(any()))
            .thenThrow(Exception('Network error'));

        final result = await repository.getRandomImageUrl();

        expect(result, 'https://via.placeholder.com/600x400?text=Devocional');
      });

      test('returns placeholder when no images are found', () async {
        final mockResponse = MockResponse();

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('[]');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);

        final result = await repository.getRandomImageUrl();

        expect(result, 'https://via.placeholder.com/600x400?text=Devocional');
      });

      test('returns placeholder when status code is not 200', () async {
        final mockResponse = MockResponse();

        when(() => mockResponse.statusCode).thenReturn(404);
        when(() => mockResponse.body).thenReturn('Not found');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);

        final result = await repository.getRandomImageUrl();

        expect(result, 'https://via.placeholder.com/600x400?text=Devocional');
      });

      test('uses custom width and height', () async {
        final mockResponse = MockResponse();
        const testImageUrl = 'https://example.com/test.jpg';

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "test.jpg", "download_url": "$testImageUrl"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn('normalized');

        await repository.getRandomImageUrl(width: 1200, height: 800);

        verify(() => mockNormalizer.normalize(testImageUrl,
            width: 1200, height: 800)).called(1);
      });
    });

    group('getImageForToday', () {
      test('returns cached URL if valid', () async {
        const cachedUrl = 'https://example.com/cached.jpg';
        final todayKey =
            'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';

        when(() => mockPrefs.getString(todayKey)).thenReturn(cachedUrl);

        final result = await repository.getImageForToday();

        expect(result, cachedUrl);
        verifyNever(() => mockHttpClient.get(any()));
      });

      test('fetches new image if cache contains placeholder', () async {
        const placeholderUrl = 'https://via.placeholder.com/600x400';
        const newImageUrl = 'https://example.com/new.jpg';
        const normalizedUrl = 'https://example.com/new_normalized.jpg';
        final todayKey =
            'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';
        final mockResponse = MockResponse();

        when(() => mockPrefs.getString(todayKey)).thenReturn(placeholderUrl);
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "new.jpg", "download_url": "$newImageUrl"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn(normalizedUrl);
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        final result = await repository.getImageForToday();

        expect(result, normalizedUrl);
        verify(() => mockPrefs.setString(todayKey, normalizedUrl)).called(1);
      });

      test('fetches new image if cache is null', () async {
        const newImageUrl = 'https://example.com/new.jpg';
        const normalizedUrl = 'https://example.com/new_normalized.jpg';
        final todayKey =
            'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';
        final mockResponse = MockResponse();

        when(() => mockPrefs.getString(todayKey)).thenReturn(null);
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.body).thenReturn('''
          [
            {"type": "file", "name": "new.jpg", "download_url": "$newImageUrl"}
          ]
        ''');
        when(() => mockHttpClient.get(any()))
            .thenAnswer((_) async => mockResponse);
        when(() => mockNormalizer.normalize(any(),
            width: any(named: 'width'),
            height: any(named: 'height'))).thenReturn(normalizedUrl);
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        final result = await repository.getImageForToday();

        expect(result, normalizedUrl);
        verify(() => mockPrefs.setString(todayKey, normalizedUrl)).called(1);
      });

      test('returns placeholder when fetching fails', () async {
        final todayKey =
            'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';

        when(() => mockPrefs.getString(todayKey)).thenReturn(null);
        when(() => mockHttpClient.get(any()))
            .thenThrow(Exception('Network error'));

        final result = await repository.getImageForToday();

        expect(result, 'https://via.placeholder.com/600x400?text=Devocional');
      });

      test('uses custom width and height for placeholder', () async {
        final todayKey =
            'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';

        when(() => mockPrefs.getString(todayKey)).thenReturn(null);
        when(() => mockHttpClient.get(any()))
            .thenThrow(Exception('Network error'));

        final result =
            await repository.getImageForToday(width: 1200, height: 800);

        expect(result, 'https://via.placeholder.com/1200x800?text=Devocional');
      });
    });
  });
}
