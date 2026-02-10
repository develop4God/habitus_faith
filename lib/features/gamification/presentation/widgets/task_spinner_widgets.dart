import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/models/task_spinner.dart';

/// Simple task spinner widget with animation
class TaskSpinnerWheel extends StatefulWidget {
  final List<TaskSpinnerItem> tasks;
  final TaskSpinnerItem? selectedTask;
  final VoidCallback onSpin;
  final bool isSpinning;

  const TaskSpinnerWheel({
    super.key,
    required this.tasks,
    this.selectedTask,
    required this.onSpin,
    this.isSpinning = false,
  });

  @override
  State<TaskSpinnerWheel> createState() => _TaskSpinnerWheelState();
}

class _TaskSpinnerWheelState extends State<TaskSpinnerWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(TaskSpinnerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Spinner wheel
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 4 * pi,
              child: child,
            );
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: widget.selectedTask != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.selectedTask!.emoji ?? '🎯',
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                widget.selectedTask!.taskName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          Icons.question_mark,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Spin button
        ElevatedButton(
          onPressed: widget.isSpinning ? null : widget.onSpin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 48,
              vertical: 16,
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: widget.isSpinning
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Spin!'),
        ),
      ],
    );
  }
}

/// Widget to display task spinner items list
class TaskSpinnerList extends StatelessWidget {
  final List<TaskSpinnerItem> tasks;
  final Function(TaskSpinnerItem) onComplete;
  final Function(TaskSpinnerItem) onToggleActive;
  final Function(TaskSpinnerItem) onDelete;

  const TaskSpinnerList({
    super.key,
    required this.tasks,
    required this.onComplete,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No tasks yet. Add some tasks to get started!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskItem(
          task: task,
          onComplete: () => onComplete(task),
          onToggleActive: () => onToggleActive(task),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskSpinnerItem task;
  final VoidCallback onComplete;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onComplete,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Text(
          task.emoji ?? '📝',
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          task.taskName,
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: task.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          'Priority: ${task.priority} | Completed: ${task.timesCompleted}x',
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'complete',
              child: const Row(
                children: [
                  Icon(Icons.check_circle),
                  SizedBox(width: 8),
                  Text('Complete'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(task.isActive ? Icons.pause : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(task.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'complete':
                onComplete();
                break;
              case 'toggle':
                onToggleActive();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ),
    );
  }
}
