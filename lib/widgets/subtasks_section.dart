import 'package:flutter/material.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../l10n/app_localizations.dart';

class SubtasksSection extends StatefulWidget {
  final List<Subtask> initialSubtasks;
  final Function(List<Subtask>) onSubtasksChanged;

  const SubtasksSection({
    super.key,
    required this.initialSubtasks,
    required this.onSubtasksChanged,
  });

  @override
  State<SubtasksSection> createState() => _SubtasksSectionState();
}

class _SubtasksSectionState extends State<SubtasksSection> {
  late List<Subtask> subtasks;
  final TextEditingController _newSubtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    subtasks = List.from(widget.initialSubtasks);
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_newSubtaskController.text.trim().isEmpty) return;

    setState(() {
      subtasks.add(
        Subtask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _newSubtaskController.text.trim(),
          completed: false,
        ),
      );
      _newSubtaskController.clear();
      widget.onSubtasksChanged(subtasks);
    });
  }

  void _toggleSubtask(int index) {
    setState(() {
      final subtask = subtasks[index];
      subtasks[index] = subtask.copyWith(completed: !subtask.completed);
      widget.onSubtasksChanged(subtasks);
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      subtasks.removeAt(index);
      widget.onSubtasksChanged(subtasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.subtasks,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // List of subtasks
        if (subtasks.isNotEmpty)
          ...subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: subtask.completed,
                    onChanged: (_) => _toggleSubtask(index),
                  ),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: TextStyle(
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteSubtask(index),
                  ),
                ],
              ),
            );
          }),
        // Add new subtask
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSubtaskController,
                decoration: InputDecoration(
                  hintText: l10n.addSubtask,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle),
              color: Colors.blue,
              onPressed: _addSubtask,
            ),
          ],
        ),
      ],
    );
  }
}
