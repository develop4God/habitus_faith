import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/task_spinner.dart';

/// Repository for managing task spinner items
class TaskSpinnerRepository {
  final SharedPreferences _prefs;
  static const String _tasksKey = 'spinner_tasks';

  TaskSpinnerRepository(this._prefs);

  /// Get all tasks for a user
  Future<List<TaskSpinnerItem>> getTasks(String userId) async {
    final jsonString = _prefs.getString('${_tasksKey}_$userId');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => TaskSpinnerItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new task
  Future<void> addTask(TaskSpinnerItem task) async {
    final tasks = await getTasks(task.userId);
    tasks.add(task);
    await _saveTasks(task.userId, tasks);
  }

  /// Update an existing task
  Future<void> updateTask(TaskSpinnerItem task) async {
    final tasks = await getTasks(task.userId);
    final index = tasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(task.userId, tasks);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String userId, String taskId) async {
    final tasks = await getTasks(userId);
    tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks(userId, tasks);
  }

  /// Get active tasks for spinning
  Future<List<TaskSpinnerItem>> getActiveTasks(String userId) async {
    final tasks = await getTasks(userId);
    return tasks.where((t) => t.isActive).toList();
  }

  Future<void> _saveTasks(String userId, List<TaskSpinnerItem> tasks) async {
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await _prefs.setString('${_tasksKey}_$userId', json.encode(jsonList));
  }

  /// Clear all tasks (for testing)
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tasksKey)) {
        await _prefs.remove(key);
      }
    }
  }
}
