import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/task_spinner_repository.dart';
import '../models/task_spinner.dart';

/// Service for managing the task spinner
class TaskSpinnerService {
  final TaskSpinnerRepository _repository;
  final Uuid _uuid;
  final Random _random;

  TaskSpinnerService({
    required TaskSpinnerRepository repository,
    Uuid? uuid,
    Random? random,
  })  : _repository = repository,
        _uuid = uuid ?? const Uuid(),
        _random = random ?? Random();

  /// Add a new task to the spinner
  Future<TaskSpinnerItem> addTask({
    required String userId,
    required String taskName,
    String? emoji,
    int priority = 3,
  }) async {
    final task = TaskSpinnerItem(
      id: _uuid.v4(),
      userId: userId,
      taskName: taskName,
      emoji: emoji,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _repository.addTask(task);
    return task;
  }

  /// Spin the wheel and select a task
  Future<SpinResult?> spin(String userId) async {
    final activeTasks = await _repository.getActiveTasks(userId);
    
    if (activeTasks.isEmpty) {
      return null; // No tasks to spin
    }

    // Use weighted random selection
    final selectedTask = _selectWeightedRandom(activeTasks);
    
    return SpinResult(
      selectedTask: selectedTask,
      spunAt: DateTime.now(),
    );
  }

  /// Complete a task from the spinner
  Future<TaskSpinnerItem> completeTask(String userId, String taskId) async {
    final tasks = await _repository.getTasks(userId);
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final completedTask = task.complete(DateTime.now());
    await _repository.updateTask(completedTask);
    
    return completedTask;
  }

  /// Toggle task active status
  Future<TaskSpinnerItem> toggleTaskActive(String userId, String taskId) async {
    final tasks = await _repository.getTasks(userId);
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final updatedTask = task.toggleActive();
    await _repository.updateTask(updatedTask);
    
    return updatedTask;
  }

  /// Delete a task
  Future<void> deleteTask(String userId, String taskId) async {
    await _repository.deleteTask(userId, taskId);
  }

  /// Get all tasks for a user
  Future<List<TaskSpinnerItem>> getTasks(String userId) async {
    return await _repository.getTasks(userId);
  }

  /// Get active tasks ready for spinning
  Future<List<TaskSpinnerItem>> getActiveTasks(String userId) async {
    return await _repository.getActiveTasks(userId);
  }

  /// Select a task using weighted random selection
  TaskSpinnerItem _selectWeightedRandom(List<TaskSpinnerItem> tasks) {
    // Calculate total weight
    final totalWeight = tasks.fold(0.0, (sum, task) => sum + task.spinnerWeight);
    
    // Generate random value
    final randomValue = _random.nextDouble() * totalWeight;
    
    // Select task based on weight
    double currentWeight = 0.0;
    for (final task in tasks) {
      currentWeight += task.spinnerWeight;
      if (randomValue <= currentWeight) {
        return task;
      }
    }
    
    // Fallback (should never reach here)
    return tasks.last;
  }

  /// Update task priority
  Future<TaskSpinnerItem> updateTaskPriority({
    required String userId,
    required String taskId,
    required int priority,
  }) async {
    final tasks = await _repository.getTasks(userId);
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    final updatedTask = TaskSpinnerItem(
      id: task.id,
      userId: task.userId,
      taskName: task.taskName,
      emoji: task.emoji,
      priority: priority.clamp(1, 5),
      createdAt: task.createdAt,
      lastCompletedAt: task.lastCompletedAt,
      timesCompleted: task.timesCompleted,
      isActive: task.isActive,
    );
    
    await _repository.updateTask(updatedTask);
    return updatedTask;
  }
}
