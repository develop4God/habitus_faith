// test/providers/devotional_providers_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/providers/devotional_providers.dart';
import 'package:habitus_faith/core/models/devocional_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DevotionalState', () {
    test('copyWith creates new instance with updated values', () {
      const initialState = DevotionalState(
        all: [],
        filtered: [],
        favorites: [],
        isLoading: false,
        selectedLanguage: 'es',
        selectedVersion: 'RVR1960',
        isOfflineMode: false,
      );

      final newState = initialState.copyWith(
        isLoading: true,
        selectedLanguage: 'en',
      );

      expect(newState.isLoading, true);
      expect(newState.selectedLanguage, 'en');
      expect(newState.selectedVersion, 'RVR1960'); // unchanged
    });
  });

  group('DevotionalNotifier', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(devotionalProvider);

      expect(state.all, isEmpty);
      expect(state.filtered, isEmpty);
      expect(state.favorites, isEmpty);
      expect(state.isLoading, false);
      expect(state.selectedLanguage, 'es');
      expect(state.selectedVersion, 'RVR1960');
      expect(state.isOfflineMode, false);
    });

    test('isFavorite returns false for non-favorite devotional', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(devotionalProvider.notifier);
      final result = notifier.isFavorite('test-id');

      expect(result, false);
    });

    test('filterBySearch with empty term shows all devotionals', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(devotionalProvider.notifier);
      
      // Create test devotionals
      final testDevocionales = [
        Devocional(
          id: '1',
          versiculo: 'John 3:16',
          reflexion: 'For God so loved the world',
          paraMeditar: [],
          oracion: 'Lord, thank you',
          date: DateTime(2024, 1, 1),
        ),
      ];

      // Manually set the state for testing
      container.read(devotionalProvider.notifier).state = 
          container.read(devotionalProvider).copyWith(
            all: testDevocionales,
            filtered: [],
          );

      notifier.filterBySearch('');

      final state = container.read(devotionalProvider);
      expect(state.filtered, equals(testDevocionales));
    });

    test('filterBySearch filters devotionals by search term', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testDevocionales = [
        Devocional(
          id: '1',
          versiculo: 'John 3:16',
          reflexion: 'For God so loved the world',
          paraMeditar: [],
          oracion: 'Lord, thank you',
          date: DateTime(2024, 1, 1),
        ),
        Devocional(
          id: '2',
          versiculo: 'Romans 8:28',
          reflexion: 'All things work together for good',
          paraMeditar: [],
          oracion: 'Father, we trust you',
          date: DateTime(2024, 1, 2),
        ),
      ];

      container.read(devotionalProvider.notifier).state = 
          container.read(devotionalProvider).copyWith(
            all: testDevocionales,
            filtered: testDevocionales,
          );

      container.read(devotionalProvider.notifier).filterBySearch('loved');

      final state = container.read(devotionalProvider);
      expect(state.filtered.length, 1);
      expect(state.filtered.first.id, '1');
    });

    test('getDevocionalById returns correct devotional', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testDevocional = Devocional(
        id: 'test-123',
        versiculo: 'John 3:16',
        reflexion: 'For God so loved the world',
        paraMeditar: [],
        oracion: 'Lord, thank you',
        date: DateTime(2024, 1, 1),
      );

      container.read(devotionalProvider.notifier).state = 
          container.read(devotionalProvider).copyWith(
            all: [testDevocional],
          );

      final result = container.read(devotionalProvider.notifier)
          .getDevocionalById('test-123');

      expect(result, isNotNull);
      expect(result?.id, 'test-123');
    });

    test('getDevocionalById returns null for non-existent id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(devotionalProvider.notifier)
          .getDevocionalById('non-existent');

      expect(result, isNull);
    });
  });

  group('Devocional model', () {
    test('fromJson creates valid Devocional', () {
      final json = {
        'id': 'test-1',
        'versiculo': 'John 3:16',
        'reflexion': 'Test reflection',
        'para_meditar': [
          {'cita': 'Romans 8:28', 'texto': 'Test meditation'},
        ],
        'oracion': 'Test prayer',
        'date': '2024-01-01',
        'version': 'RVR1960',
        'language': 'es',
        'tags': ['faith', 'love'],
      };

      final devocional = Devocional.fromJson(json);

      expect(devocional.id, 'test-1');
      expect(devocional.versiculo, 'John 3:16');
      expect(devocional.reflexion, 'Test reflection');
      expect(devocional.paraMeditar.length, 1);
      expect(devocional.oracion, 'Test prayer');
      expect(devocional.version, 'RVR1960');
      expect(devocional.language, 'es');
      expect(devocional.tags?.length, 2);
    });

    test('toJson serializes Devocional correctly', () {
      final devocional = Devocional(
        id: 'test-1',
        versiculo: 'John 3:16',
        reflexion: 'Test reflection',
        paraMeditar: [
          ParaMeditar(cita: 'Romans 8:28', texto: 'Test meditation'),
        ],
        oracion: 'Test prayer',
        date: DateTime(2024, 1, 1),
        version: 'RVR1960',
        language: 'es',
        tags: ['faith', 'love'],
      );

      final json = devocional.toJson();

      expect(json['id'], 'test-1');
      expect(json['versiculo'], 'John 3:16');
      expect(json['para_meditar'], isList);
      expect(json['date'], '2024-01-01');
    });
  });
}
