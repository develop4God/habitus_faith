import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/goal_model.dart';
import '../data/storage/storage_providers.dart';
import '../data/storage/json_storage_service.dart';

final jsonGoalsRepositoryProvider = Provider<JsonGoalsRepository>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  return JsonGoalsRepository(storage: storage, userId: 'local_user');
});

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final repository = ref.watch(jsonGoalsRepositoryProvider);
  return repository.watchGoals();
});

class JsonGoalsRepository {
  final JsonStorageService _storage;
  final String _userId;
  static const String _goalsKey = 'goals';
  late final StreamController<List<Goal>> _controller;

  JsonGoalsRepository({
    required JsonStorageService storage,
    required String userId,
  }) : _storage = storage,
       _userId = userId {
    _controller = StreamController<List<Goal>>.broadcast(
      onListen: () {
        debugPrint(
          'JsonGoalsRepository: first listener - emitting initial goals',
        );
        _emit();
      },
    );

    // Ensure initial emission for any late listeners or quick rebuilds
    Future.microtask(() => _emit());
  }

  void _emit() {
    if (_controller.isClosed) return;
    try {
      final list = _load();
      debugPrint('JsonGoalsRepository._emit: emitting ${list.length} goals');
      _controller.add(list);
    } catch (e) {
      debugPrint('JsonGoalsRepository._emit: error -> $e');
    }
  }

  List<Goal> _load() {
    try {
      final jsonList = _storage.getJsonList(_goalsKey);
      return jsonList
          .map((json) => Goal.fromJson(json))
          .where((g) => g.userId == _userId)
          .toList();
    } catch (e) {
      debugPrint('JsonGoalsRepository._load: error -> $e');
      return [];
    }
  }

  Stream<List<Goal>> watchGoals() => _controller.stream;

  Future<void> addGoal(Goal goal) async {
    final list = _load();
    list.add(goal);
    await _save(list);
  }

  Future<void> updateGoal(Goal goal) async {
    final list = _load();
    final index = list.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      list[index] = goal;
      await _save(list);
    }
  }

  Future<void> deleteGoal(String id) async {
    final list = _load();
    list.removeWhere((g) => g.id == id);
    await _save(list);
  }

  Future<void> _save(List<Goal> list) async {
    final jsonList = list.map((g) => g.toJson()).toList();
    await _storage.saveJsonList(_goalsKey, jsonList);
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}
