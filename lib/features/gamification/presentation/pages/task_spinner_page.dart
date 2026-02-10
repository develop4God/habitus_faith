import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../gamification_providers.dart';
import '../widgets/task_spinner_widgets.dart';
import '../../domain/models/task_spinner.dart';

/// Page for the task spinner feature
class TaskSpinnerPage extends ConsumerStatefulWidget {
  const TaskSpinnerPage({super.key});

  @override
  ConsumerState<TaskSpinnerPage> createState() => _TaskSpinnerPageState();
}

class _TaskSpinnerPageState extends ConsumerState<TaskSpinnerPage> {
  TaskSpinnerItem? _selectedTask;
  bool _isSpinning = false;

  Future<void> _spin() async {
    final userId = ref.read(userIdProvider);
    if (userId == null) return;

    setState(() {
      _isSpinning = true;
      _selectedTask = null;
    });

    final service = ref.read(taskSpinnerServiceProvider);
    final result = await service.spin(userId);

    if (result != null) {
      // Simulate spinner animation delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _selectedTask = result.selectedTask;
        _isSpinning = false;
      });

      // Show result dialog
      if (mounted) {
        _showResultDialog(result.selectedTask);
      }
    } else {
      setState(() {
        _isSpinning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active tasks. Add some tasks first!'),
          ),
        );
      }
    }
  }

  void _showResultDialog(TaskSpinnerItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${task.emoji ?? '🎯'} ${task.taskName}'),
        content: const Text('Ready to tackle this task?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = ref.read(userIdProvider);
              if (userId != null) {
                final service = ref.read(taskSpinnerServiceProvider);
                await service.completeTask(userId, task.id);
                ref.invalidate(spinnerTasksProvider(userId));
              }
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${task.taskName} completed! +10 points'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final taskNameController = TextEditingController();
    final emojiController = TextEditingController();
    int priority = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'e.g., Wash dishes',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji (optional)',
                  hintText: '🍽️',
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Priority:'),
                  Expanded(
                    child: Slider(
                      value: priority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: priority.toString(),
                      onChanged: (value) {
                        setState(() {
                          priority = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(priority.toString()),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (taskNameController.text.isNotEmpty) {
                  final userId = ref.read(userIdProvider);
                  if (userId != null) {
                    final service = ref.read(taskSpinnerServiceProvider);
                    await service.addTask(
                      userId: userId,
                      taskName: taskNameController.text,
                      emoji: emojiController.text.isNotEmpty
                          ? emojiController.text
                          : null,
                      priority: priority,
                    );
                    ref.invalidate(spinnerTasksProvider(userId));
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final tasksAsync = ref.watch(spinnerTasksProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Spinner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                TaskSpinnerWheel(
                  tasks: tasks,
                  selectedTask: _selectedTask,
                  onSpin: _spin,
                  isSpinning: _isSpinning,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your Tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TaskSpinnerList(
                  tasks: tasks,
                  onComplete: (task) async {
                    final service = ref.read(taskSpinnerServiceProvider);
                    await service.completeTask(userId, task.id);
                    ref.invalidate(spinnerTasksProvider(userId));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${task.taskName} completed!'),
                        ),
                      );
                    }
                  },
                  onToggleActive: (task) async {
                    final service = ref.read(taskSpinnerServiceProvider);
                    await service.toggleTaskActive(userId, task.id);
                    ref.invalidate(spinnerTasksProvider(userId));
                  },
                  onDelete: (task) async {
                    final service = ref.read(taskSpinnerServiceProvider);
                    await service.deleteTask(userId, task.id);
                    ref.invalidate(spinnerTasksProvider(userId));
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
