import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/bible_reader_core/bible_reader_core.dart';
import 'package:habitus_faith/providers/bible_providers.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('bibleVersionsProvider', () {
    test('provides list of Bible versions', () {
      final versions = container.read(bibleVersionsProvider);

      expect(versions, isNotEmpty);
      expect(versions.length, greaterThan(0));
      expect(versions.first.name, isNotNull);
      expect(versions.first.languageCode, isNotNull);
    });

    test('all versions have required properties', () {
      final versions = container.read(bibleVersionsProvider);

      for (final version in versions) {
        expect(version.id, isNotEmpty);
        expect(version.name, isNotEmpty);
        expect(version.language, isNotEmpty);
        expect(version.languageCode, isNotEmpty);
        expect(version.assetPath, isNotEmpty);
        expect(version.dbFileName, isNotEmpty);
      }
    });

    test('versions have unique IDs', () {
      final versions = container.read(bibleVersionsProvider);
      final ids = versions.map((v) => v.id).toSet();

      expect(ids.length, equals(versions.length));
    });
  });

  group('currentBibleVersionProvider', () {
    test('loads initial version', () async {
      // Give more time for async initialization and use addPostFrameCallback pattern
      await container.read(sharedPreferencesProvider.future);

      // Trigger provider read which starts initialization
      final _ = container.read(currentBibleVersionProvider.notifier);

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 200));

      final currentVersion = container.read(currentBibleVersionProvider);
      expect(currentVersion, isNotNull);
    });

    test('setVersion updates state', () async {
      await container.read(sharedPreferencesProvider.future);
      final notifier = container.read(currentBibleVersionProvider.notifier);
      final versions = container.read(bibleVersionsProvider);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 200));

      // Set to specific version
      await notifier.setVersion(versions[1]);

      final currentVersion = container.read(currentBibleVersionProvider);
      expect(currentVersion?.id, equals(versions[1].id));
      expect(currentVersion?.name, equals(versions[1].name));
    });

    test('setVersion persists to SharedPreferences', () async {
      await container.read(sharedPreferencesProvider.future);
      final notifier = container.read(currentBibleVersionProvider.notifier);
      final versions = container.read(bibleVersionsProvider);
      final testVersion = versions.first;

      await notifier.setVersion(testVersion);

      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('current_bible_version');
      expect(savedName, equals(testVersion.name));
    });

    test('loads saved version from SharedPreferences', () async {
      final versions = container.read(bibleVersionsProvider);
      final savedVersion = versions[1];

      // Save version to preferences first
      SharedPreferences.setMockInitialValues({
        'current_bible_version': savedVersion.name,
      });

      // Create new container to trigger reload
      final newContainer = ProviderContainer();
      await newContainer.read(sharedPreferencesProvider.future);

      // Trigger initialization
      newContainer.read(currentBibleVersionProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));

      final loaded = newContainer.read(currentBibleVersionProvider);
      expect(loaded?.name, equals(savedVersion.name));

      newContainer.dispose();
    });

    test('falls back to first version if saved not found', () async {
      SharedPreferences.setMockInitialValues({
        'current_bible_version': 'NonExistentVersion',
      });

      final newContainer = ProviderContainer();
      await newContainer.read(sharedPreferencesProvider.future);

      // Trigger initialization
      newContainer.read(currentBibleVersionProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));

      final loaded = newContainer.read(currentBibleVersionProvider);
      final versions = newContainer.read(bibleVersionsProvider);

      expect(loaded, isNotNull);
      expect(loaded?.id, equals(versions.first.id));

      newContainer.dispose();
    });
  });

  group('bibleDbServiceProvider', () {
    test('creates service for valid version ID', () async {
      final versions = container.read(bibleVersionsProvider);
      final versionId = versions.first.id;

      // Note: This will attempt initialization but may fail without actual database file
      // The provider itself should not throw when created
      final provider = bibleDbServiceProvider(versionId);
      expect(provider, isNotNull);
    });

    test('provider throws for invalid version ID during resolution', () async {
      // The provider itself doesn't throw until we try to read it
      final provider = bibleDbServiceProvider('invalid_id');

      // Attempting to read should eventually throw
      expect(
        () async => await container.read(provider.future),
        throwsA(isA<Exception>()),
      );
    });

    test('each version ID gets its own provider family instance', () {
      final versions = container.read(bibleVersionsProvider);

      final provider1 = bibleDbServiceProvider(versions[0].id);
      final provider2 = bibleDbServiceProvider(versions[1].id);

      // Different version IDs = different provider families
      expect(identical(provider1, provider2), isFalse);
    });
  });

  group('biblePreferencesServiceProvider', () {
    test('provides BiblePreferencesService instance', () {
      final service = container.read(biblePreferencesServiceProvider);
      expect(service, isA<BiblePreferencesService>());
    });
  });

  group('bibleReadingPositionServiceProvider', () {
    test('provides BibleReadingPositionService instance', () {
      final service = container.read(bibleReadingPositionServiceProvider);
      expect(service, isA<BibleReadingPositionService>());
    });
  });

  group('bibleReaderServiceProvider', () {
    test('provides BibleReaderService instance', () {
      final service = container.read(bibleReaderServiceProvider);
      expect(service, isA<BibleReaderService>());
    });
  });

  group('bibleReaderProvider', () {
    test('provides BibleReaderController instance', () {
      final controller = container.read(bibleReaderProvider.notifier);
      expect(controller, isA<BibleReaderController>());
    });

    test('provides BibleReaderState', () {
      final state = container.read(bibleReaderProvider);
      expect(state, isA<BibleReaderState>());
    });

    test('initial state is not loading', () {
      final state = container.read(bibleReaderProvider);
      expect(state.isLoading, isFalse);
    });
  });
}
