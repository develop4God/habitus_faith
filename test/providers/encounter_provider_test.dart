// test/providers/encounter_provider_test.dart
//
// Tests for EncounterState and EncounterNotifier (Riverpod).

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/models/encounter_card_model.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/core/models/encounter_study.dart';
import 'package:habitus_faith/core/services/encounters/encounter_repository.dart';
import 'package:habitus_faith/providers/encounter_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockEncounterRepository extends Mock implements EncounterRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EncounterIndexEntry _fakeEntry({
  String id = 'peter_water_001',
  String status = 'published',
  String version = '1.0',
}) =>
    EncounterIndexEntry(
      id: id,
      version: version,
      emoji: '🌊',
      status: status,
      files: {'en': '$id.json', 'es': '${id}_es.json'},
      titles: {'en': 'Test Encounter', 'es': 'Encuentro de Prueba'},
      subtitles: {'en': 'Test Subtitle', 'es': 'Subtítulo de Prueba'},
      scriptureReference: {'en': 'Matthew 14:22-33'},
      estimatedReadingMinutes: {'en': 8},
    );

EncounterStudy _fakeStudy({String id = 'peter_water_001'}) => EncounterStudy(
      id: id,
      language: 'en',
      version: '1.0',
      cards: [
        const EncounterCard(order: 1, type: 'cinematic_scene', title: 'Scene 1'),
        const EncounterCard(order: 2, type: 'scripture_moment', title: 'The Verse'),
        const EncounterCard(order: 3, type: 'completion', title: 'Done'),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(_fakeEntry());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ---------------------------------------------------------------------------
  // EncounterState
  // ---------------------------------------------------------------------------

  group('EncounterState', () {
    test('initial state has correct defaults', () {
      const state = EncounterState();

      expect(state.index, isEmpty);
      expect(state.loadedStudies, isEmpty);
      expect(state.completedIds, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('copyWith updates specified fields', () {
      const initial = EncounterState();
      final updated = initial.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.index, isEmpty); // unchanged
      expect(updated.errorMessage, isNull); // unchanged
    });

    test('copyWith clearError removes errorMessage', () {
      const withError = EncounterState(errorMessage: 'Some error');
      final cleared = withError.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
    });

    test('getStudy returns null when not loaded', () {
      const state = EncounterState();
      expect(state.getStudy('unknown'), isNull);
    });

    test('isStudyLoaded returns false when not in map', () {
      const state = EncounterState();
      expect(state.isStudyLoaded('test_id'), false);
    });

    test('isCompleted returns false for new encounter', () {
      const state = EncounterState();
      expect(state.isCompleted('peter_water_001'), false);
    });

    test('isCompleted returns true after completing encounter', () {
      final state = EncounterState(
        completedIds: const {'peter_water_001'},
      );
      expect(state.isCompleted('peter_water_001'), true);
    });

    test('getStudy returns study from map', () {
      final study = _fakeStudy();
      final state = EncounterState(
        loadedStudies: {'peter_water_001': study},
      );

      expect(state.getStudy('peter_water_001'), isNotNull);
      expect(state.getStudy('peter_water_001')!.id, 'peter_water_001');
    });
  });

  // ---------------------------------------------------------------------------
  // EncounterNotifier — with mock repository
  // ---------------------------------------------------------------------------

  group('EncounterNotifier', () {
    late MockEncounterRepository mockRepo;

    setUp(() {
      mockRepo = MockEncounterRepository();
    });

    ProviderContainer _makeContainer() {
      return ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo),
          ),
        ],
      );
    }

    // ── loadIndex ────────────────────────────────────────────────────────────

    test('loadIndex: sets isLoading then populates index on success', () async {
      when(() => mockRepo.fetchIndex(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [_fakeEntry()]);

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadIndex();

      final state = container.read(encounterProvider);
      expect(state.index.length, 1);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('loadIndex: sets errorMessage on failure', () async {
      when(() => mockRepo.fetchIndex(forceRefresh: any(named: 'forceRefresh')))
          .thenThrow(Exception('network error'));

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadIndex();

      final state = container.read(encounterProvider);
      expect(state.index, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNotNull);
    });

    test('loadIndex: loaded index contains correct entries', () async {
      final entries = [
        _fakeEntry(id: 'enc_001'),
        _fakeEntry(id: 'enc_002', status: 'coming_soon'),
      ];
      when(() => mockRepo.fetchIndex(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => entries);

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadIndex();

      final state = container.read(encounterProvider);
      expect(state.index.length, 2);
      expect(state.index.first.id, 'enc_001');
      expect(state.index.last.id, 'enc_002');
    });

    test('loadIndex forceRefresh calls repository with forceRefresh=true', () async {
      when(() => mockRepo.fetchIndex(forceRefresh: true))
          .thenAnswer((_) async => [_fakeEntry()]);

      final container = _makeContainer();
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadIndex(forceRefresh: true);

      verify(() => mockRepo.fetchIndex(forceRefresh: true)).called(1);
    });

    // ── loadStudy ────────────────────────────────────────────────────────────

    test('loadStudy: adds study to loadedStudies on success', () async {
      when(() => mockRepo.fetchStudy(
            'peter_water_001',
            'en',
            filename: any(named: 'filename'),
            entry: any(named: 'entry'),
          )).thenAnswer((_) async => _fakeStudy());

      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(index: [_fakeEntry()]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadStudy('peter_water_001', 'en');

      final state = container.read(encounterProvider);
      expect(state.isStudyLoaded('peter_water_001'), true);
      expect(state.getStudy('peter_water_001')!.cardCount, 3);
    });

    test('loadStudy: no-op when study already loaded', () async {
      final study = _fakeStudy();

      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(
                index: [_fakeEntry()],
                loadedStudies: {'peter_water_001': study},
              ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadStudy('peter_water_001', 'en');

      verifyNever(() => mockRepo.fetchStudy(
            any(),
            any(),
            filename: any(named: 'filename'),
            entry: any(named: 'entry'),
          ));
    });

    test('loadStudy: sets errorMessage on failure', () async {
      when(() => mockRepo.fetchStudy(
            any(),
            any(),
            filename: any(named: 'filename'),
            entry: any(named: 'entry'),
          )).thenThrow(Exception('not found'));

      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(index: [_fakeEntry()]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(encounterProvider.notifier)
          .loadStudy('peter_water_001', 'en');

      final state = container.read(encounterProvider);
      expect(state.isStudyLoaded('peter_water_001'), false);
      expect(state.errorMessage, isNotNull);
    });

    // ── completeEncounter ────────────────────────────────────────────────────

    test('completeEncounter: adds id to completedIds', () {
      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(index: [_fakeEntry()]),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(encounterProvider.notifier)
          .completeEncounter('peter_water_001');

      expect(
        container.read(encounterProvider).isCompleted('peter_water_001'),
        true,
      );
    });

    test('completeEncounter: completing twice keeps only one entry', () {
      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(index: [_fakeEntry()]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(encounterProvider.notifier);
      notifier.completeEncounter('peter_water_001');
      notifier.completeEncounter('peter_water_001');

      expect(
        container.read(encounterProvider).completedIds.length,
        1,
      );
    });

    test('completeEncounter: multiple encounters tracked independently', () {
      final container = ProviderContainer(
        overrides: [
          encounterProvider.overrideWith(
            (ref) => EncounterNotifier(repository: mockRepo)
              ..state = EncounterState(index: [
                _fakeEntry(id: 'enc_001'),
                _fakeEntry(id: 'enc_002'),
              ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(encounterProvider.notifier);
      notifier.completeEncounter('enc_001');
      notifier.completeEncounter('enc_002');

      final state = container.read(encounterProvider);
      expect(state.isCompleted('enc_001'), true);
      expect(state.isCompleted('enc_002'), true);
      expect(state.completedIds.length, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // EncounterNotifier — default provider (no overrides)
  // ---------------------------------------------------------------------------

  group('EncounterNotifier — default provider', () {
    test('initial state from encounterProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(encounterProvider);

      expect(state.index, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });
  });
}
