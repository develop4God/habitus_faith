import 'package:flutter/material.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../l10n/app_localizations.dart';

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
    final text = _newSubtaskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      subtasks.add(
        Subtask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: text,
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
        if (widget.showAddButton) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _addSubtask,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _newSubtaskController,
                    onSubmitted: (_) => _addSubtask(),
                    decoration: InputDecoration(
                      hintText: l10n.addSubtask,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subtasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final subtask = subtasks[index];
            return Container(
              decoration: BoxDecoration(
                color: subtask.completed ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: subtask.completed ? Colors.green.shade100 : Colors.grey.shade200,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 8, right: 4),
                leading: Checkbox(
                  value: subtask.completed,
                  onChanged: (_) => _toggleSubtask(index),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: Colors.green,
                ),
                title: Text(
                  subtask.title,
                  style: TextStyle(
                    decoration: subtask.completed ? TextDecoration.lineThrough : null,
                    color: subtask.completed ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _deleteSubtask(index),
                  color: Colors.grey.shade400,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
