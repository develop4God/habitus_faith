import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitus_faith/features/gamification/data/task_spinner_repository.dart';
import 'package:habitus_faith/features/gamification/domain/services/task_spinner_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('TaskSpinnerService', () {
    late TaskSpinnerRepository repository;
    late TaskSpinnerService service;
    late SharedPreferences prefs;
    const testUserId = 'test-user-123';

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = TaskSpinnerRepository(prefs);
      service = TaskSpinnerService(
        repository: repository,
        uuid: const Uuid(),
      );
    });

    tearDown(() async {
      await repository.clearAll();
    });

    test('addTask creates and saves task', () async {
      // Act
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Wash dishes',
        emoji: '🍽️',
        priority: 4,
      );

      // Assert
      expect(task.userId, testUserId);
      expect(task.taskName, 'Wash dishes');
      expect(task.emoji, '🍽️');
      expect(task.priority, 4);
      expect(task.isActive, true);
      expect(task.timesCompleted, 0);

      // Verify saved
      final tasks = await repository.getTasks(testUserId);
      expect(tasks.length, 1);
      expect(tasks[0].taskName, 'Wash dishes');
    });

    test('spin returns null when no active tasks', () async {
      // Act
      final result = await service.spin(testUserId);

      // Assert
      expect(result, null);
    });

    test('spin selects a task using weighted random', () async {
      // Arrange - Add tasks
      await service.addTask(
        userId: testUserId,
        taskName: 'Task 1',
        priority: 3,
      );

      // Act
      final result = await service.spin(testUserId);

      // Assert
      expect(result, isNotNull);
      expect(result!.selectedTask.taskName, 'Task 1');
      expect(result.pointsAwarded, 10);
    });

    test('spin considers task weights based on completion', () async {
      // Arrange - Add multiple tasks with different priorities
      final task1 = await service.addTask(
        userId: testUserId,
        taskName: 'High Priority',
        priority: 5,
      );

      await service.addTask(
        userId: testUserId,
        taskName: 'Low Priority',
        priority: 1,
      );

      // Act - Spin multiple times and check distribution
      final results = <String>[];
      for (int i = 0; i < 10; i++) {
        final result = await service.spin(testUserId);
        results.add(result!.selectedTask.taskName);
      }

      // Assert - High priority should appear more often
      final highPriorityCount =
          results.where((name) => name == 'High Priority').length;
      expect(highPriorityCount, greaterThan(3)); // At least some high priority
    });

    test('completeTask updates task and increments completion count', () async {
      // Arrange
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Test Task',
        priority: 3,
      );

      // Act
      final completed = await service.completeTask(testUserId, task.id);

      // Assert
      expect(completed.timesCompleted, 1);
      expect(completed.lastCompletedAt, isNotNull);

      // Verify saved
      final tasks = await repository.getTasks(testUserId);
      expect(tasks[0].timesCompleted, 1);
    });

    test('toggleTaskActive changes active status', () async {
      // Arrange
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Test Task',
      );

      expect(task.isActive, true);

      // Act
      final toggled = await service.toggleTaskActive(testUserId, task.id);

      // Assert
      expect(toggled.isActive, false);

      // Verify only active tasks are returned
      final activeTasks = await service.getActiveTasks(testUserId);
      expect(activeTasks.length, 0);
    });

    test('deleteTask removes task from repository', () async {
      // Arrange
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Test Task',
      );

      // Act
      await service.deleteTask(testUserId, task.id);

      // Assert
      final tasks = await service.getTasks(testUserId);
      expect(tasks.length, 0);
    });

    test('updateTaskPriority changes priority and clamps to valid range',
        () async {
      // Arrange
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Test Task',
        priority: 3,
      );

      // Act - Try to set invalid priority (should clamp)
      final updated = await service.updateTaskPriority(
        userId: testUserId,
        taskId: task.id,
        priority: 10, // Should clamp to 5
      );

      // Assert
      expect(updated.priority, 5);
    });

    test('getActiveTasks returns only active tasks', () async {
      // Arrange
      final task1 = await service.addTask(
        userId: testUserId,
        taskName: 'Active Task',
      );

      final task2 = await service.addTask(
        userId: testUserId,
        taskName: 'Inactive Task',
      );

      // Deactivate task2
      await service.toggleTaskActive(testUserId, task2.id);

      // Act
      final activeTasks = await service.getActiveTasks(testUserId);

      // Assert
      expect(activeTasks.length, 1);
      expect(activeTasks[0].taskName, 'Active Task');
    });

    test('task weight calculation boosts unfinished tasks', () async {
      // Arrange
      final task = await service.addTask(
        userId: testUserId,
        taskName: 'Test Task',
        priority: 3,
      );

      // Act - Check initial weight (never completed, should be boosted)
      final tasks = await repository.getTasks(testUserId);
      final initialWeight = tasks[0].spinnerWeight;
      expect(initialWeight, 6.0); // priority 3 * 2 (never completed boost)

      // Complete the task
      await service.completeTask(testUserId, task.id);

      // Check weight after completion (today)
      final updatedTasks = await repository.getTasks(testUserId);
      final newWeight = updatedTasks[0].spinnerWeight;
      expect(newWeight, 1.5); // priority 3 * 0.5 (completed today)
    });
  });
}
