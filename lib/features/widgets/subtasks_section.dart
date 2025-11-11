import 'package:flutter/material.dart';
import 'package:habitus_faith/features/habits/domain/models/habit_notification.dart';

class SubtasksSection extends StatefulWidget {
  final List<Subtask> initialSubtasks;
  final Function(List<Subtask>) onSubtasksChanged;
  final bool showAddButton;
  final ButtonStyle? addButtonStyle;

  const SubtasksSection({
    super.key,
    required this.initialSubtasks,
    required this.onSubtasksChanged,
    this.showAddButton = false,
    this.addButtonStyle,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: subtask.completed ? Colors.green.shade50 : Colors.white,
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              leading: Checkbox(
                value: subtask.completed,
                onChanged: (_) => _toggleSubtask(index),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                activeColor: Colors.purple,
              ),
              title: Text(subtask.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteSubtask(index),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        if (widget.showAddButton)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSubtaskController,
                  decoration: InputDecoration(
                    labelText: 'Agregar subtarea',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: widget.addButtonStyle ??
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                    ),
                onPressed: _addSubtask,
                child: const Icon(Icons.add, size: 24),
              ),
            ],
          ),
      ],
    );
  }
}
