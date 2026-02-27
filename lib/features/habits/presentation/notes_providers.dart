import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/general_note_model.dart';
import '../data/storage/storage_providers.dart';
import '../data/storage/json_storage_service.dart';

final jsonGeneralNotesRepositoryProvider = Provider<JsonGeneralNotesRepository>(
  (ref) {
    final storage = ref.watch(jsonStorageServiceProvider);
    return JsonGeneralNotesRepository(storage: storage, userId: 'local_user');
  },
);

final generalNotesStreamProvider = StreamProvider<List<GeneralNote>>((ref) {
  final repository = ref.watch(jsonGeneralNotesRepositoryProvider);
  return repository.watchNotes();
});

class JsonGeneralNotesRepository {
  final JsonStorageService _storage;
  final String _userId;
  static const String _notesKey = 'general_notes';
  late final StreamController<List<GeneralNote>> _controller;

  JsonGeneralNotesRepository({
    required JsonStorageService storage,
    required String userId,
  })  : _storage = storage,
        _userId = userId {
    _controller = StreamController<List<GeneralNote>>.broadcast(
      onListen: () {
        debugPrint(
          'JsonGeneralNotesRepository: first listener - emitting initial notes',
        );
        _emit();
      },
    );

    // Immediate initial emission
    Future.microtask(() => _emit());
  }

  void _emit() {
    if (_controller.isClosed) return;
    try {
      final list = _load();
      debugPrint(
        'JsonGeneralNotesRepository._emit: emitting ${list.length} notes',
      );
      _controller.add(list);
    } catch (e) {
      debugPrint('JsonGeneralNotesRepository._emit error: $e');
    }
  }

  List<GeneralNote> _load() {
    try {
      final jsonList = _storage.getJsonList(_notesKey);
      return jsonList
          .map((json) => GeneralNote.fromJson(json))
          .where((n) => n.userId == _userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('JsonGeneralNotesRepository._load error: $e');
      return [];
    }
  }

  Stream<List<GeneralNote>> watchNotes() => _controller.stream;

  Future<void> addNote(String content, {String? petId}) async {
    final list = _load();
    final newNote = GeneralNote(
      id: const Uuid().v4(),
      userId: _userId,
      content: content,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      petId: petId,
    );
    list.add(newNote);
    await _save(list);
  }

  Future<void> updateNote(String id, String content) async {
    final list = _load();
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(content: content);
      await _save(list);
    }
  }

  Future<void> deleteNote(String id) async {
    final list = _load();
    list.removeWhere((n) => n.id == id);
    await _save(list);
  }

  Future<void> _save(List<GeneralNote> list) async {
    final jsonList = list.map((n) => n.toJson()).toList();
    await _storage.saveJsonList(_notesKey, jsonList);
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}
