// lib/providers/encounter_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/models/encounter_index_entry.dart';
import 'package:habitus_faith/core/models/encounter_study.dart';
import 'package:habitus_faith/core/services/encounters/encounter_repository.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// Immutable state for the encounters feature.
class EncounterState {
  final List<EncounterIndexEntry> index;
  final Map<String, EncounterStudy> loadedStudies;
  final Set<String> completedIds;
  final bool isLoading;
  final String? errorMessage;

  const EncounterState({
    this.index = const [],
    this.loadedStudies = const {},
    this.completedIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  EncounterStudy? getStudy(String id) => loadedStudies[id];
  bool isStudyLoaded(String id) => loadedStudies.containsKey(id);
  bool isCompleted(String id) => completedIds.contains(id);

  EncounterState copyWith({
    List<EncounterIndexEntry>? index,
    Map<String, EncounterStudy>? loadedStudies,
    Set<String>? completedIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EncounterState(
      index: index ?? this.index,
      loadedStudies: loadedStudies ?? this.loadedStudies,
      completedIds: completedIds ?? this.completedIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Riverpod state notifier for the encounters feature.
class EncounterNotifier extends StateNotifier<EncounterState> {
  final EncounterRepository _repository;

  EncounterNotifier({EncounterRepository? repository})
      : _repository =
            repository ?? EncounterRepository(httpClient: http.Client()),
        super(const EncounterState());

  // ── Index ──────────────────────────────────────────────────────────────────

  /// Loads the encounters index from GitHub (cache-first within session).
  Future<void> loadIndex({
    String? languageCode,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final entries = await _repository.fetchIndex(forceRefresh: forceRefresh);
      state = state.copyWith(
        index: entries,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading encounters: $e',
      );
    }
  }

  // ── Study ──────────────────────────────────────────────────────────────────

  /// Loads a specific encounter study by [id] and [lang].
  ///
  /// No-op when the study is already in [loadedStudies].
  /// Uses version from the index entry for cache validation.
  Future<void> loadStudy(String id, String lang, {String? filename}) async {
    // Cache hit — skip network call
    if (state.isStudyLoaded(id)) return;

    // Resolve entry from current index for version-aware cache
    final entry = state.index.where((e) => e.id == id).firstOrNull;

    try {
      final study = await _repository.fetchStudy(
        id,
        lang,
        filename: filename ?? entry?.fileFor(lang),
        entry: entry,
      );

      final updatedStudies = Map<String, EncounterStudy>.from(state.loadedStudies);
      updatedStudies[id] = study;
      state = state.copyWith(loadedStudies: updatedStudies, clearError: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading encounter study: $e',
      );
    }
  }

  // ── Progress ───────────────────────────────────────────────────────────────

  /// Marks an encounter as completed.
  void completeEncounter(String id) {
    final updated = Set<String>.from(state.completedIds)..add(id);
    state = state.copyWith(completedIds: updated);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provider for the encounter state.
final encounterProvider =
    StateNotifierProvider<EncounterNotifier, EncounterState>((ref) {
  return EncounterNotifier();
});
