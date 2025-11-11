import 'package:flutter/material.dart';

class HabitModalSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      enableDrag: true,
      isDismissible: true,
      builder: (ctx) => Container(
        constraints: maxHeight != null
            ? BoxConstraints(maxHeight: maxHeight!)
            : const BoxConstraints(maxHeight: 480),
        child: child,
      ),
    );
  }
}

class HabitModalContent extends StatefulWidget {
  @override
  State<HabitModalContent> createState() => _HabitModalContentState();
}

class _HabitModalContentState extends State<HabitModalContent> {
  bool completed = false;
  List<String> subtasks = [];
  bool showInput = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    debugPrint('HabitModalContent build ejecutado. completed: $completed, subtasks: $subtasks, showInput: $showInput');
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: completed,
                onChanged: (val) {
                  debugPrint('Checkbox tapped. Valor: $val');
                  setState(() {
                    completed = val ?? false;
                    debugPrint('Checkbox setState ejecutado. completed: $completed');
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ejemplo de tarea',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!showInput)
            GestureDetector(
              onTap: () {
                debugPrint('Barra de subtareas tocada');
                setState(() {
                  showInput = true;
                  debugPrint('Barra de subtareas setState ejecutado. showInput: $showInput');
                });
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade100, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.purple, size: 24),
                    const SizedBox(width: 8),
                    Text('Subtareas', style: TextStyle(fontSize: 16, color: Colors.purple.shade700)),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          if (showInput)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Nueva subtarea...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (text) {
                        debugPrint('onSubmitted subtarea: $text');
                        if (text.trim().isNotEmpty) {
                          setState(() {
                            subtasks.add(text.trim());
                            _subtaskController.clear();
                            showInput = false;
                            debugPrint('Subtarea agregada por Enter. subtasks: $subtasks, showInput: $showInput');
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.purple, size: 28),
                    onPressed: () {
                      final text = _subtaskController.text.trim();
                      debugPrint('IconButton check subtarea: $text');
                      if (text.isNotEmpty) {
                        setState(() {
                          subtasks.add(text);
                          _subtaskController.clear();
                          showInput = false;
                          debugPrint('Subtarea agregada por botón. subtasks: $subtasks, showInput: $showInput');
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          ...subtasks.map((s) => ListTile(
                title: Text(s),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    debugPrint('Eliminar subtarea: $s');
                    setState(() {
                      subtasks.remove(s);
                      debugPrint('Subtarea eliminada. subtasks: $subtasks');
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }
}

void showTestHabitModal(BuildContext context) {
  HabitModalSheet.show(
    context: context,
    child: HabitModalContent(),
    maxHeight: 400,
  );
}
