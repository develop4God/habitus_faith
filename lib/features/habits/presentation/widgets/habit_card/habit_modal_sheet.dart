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
      backgroundColor: Colors.white, // Fondo blanco detrás del modal
      enableDrag: true,
      isDismissible: true,
      builder: (ctx) => Container(
        constraints: maxHeight != null
            ? BoxConstraints(maxHeight: maxHeight)
            : const BoxConstraints(maxHeight: 480),
        child: child,
      ),
    );
  }
}

class HabitModalContent extends StatefulWidget {
  final String habitName;
  final bool initialCompleted;
  final List<String> initialSubtasks;
  final ValueChanged<bool>? onCompletedChanged;
  final ValueChanged<List<String>>? onSubtasksChanged;

  const HabitModalContent({
    super.key,
    required this.habitName,
    required this.initialCompleted,
    required this.initialSubtasks,
    this.onCompletedChanged,
    this.onSubtasksChanged,
  });

  @override
  State<HabitModalContent> createState() => _HabitModalContentState();
}

class _HabitModalContentState extends State<HabitModalContent> {
  late bool completed;
  late List<String> subtasks;
  bool showInput = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    completed = widget.initialCompleted;
    subtasks = List<String>.from(widget.initialSubtasks);
  }

  @override
  void didUpdateWidget(covariant HabitModalContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('HabitModalContent.didUpdateWidget: INICIO - completed=$completed, widget.initialCompleted=${widget.initialCompleted}');
    if (completed != widget.initialCompleted) {
      debugPrint('HabitModalContent.didUpdateWidget: completed cambiado de '+completed.toString()+" a "+widget.initialCompleted.toString());
      setState(() {
        completed = widget.initialCompleted;
        debugPrint('HabitModalContent.didUpdateWidget: setState ejecutado, completed=$completed');
      });
      debugPrint('HabitModalContent.didUpdateWidget: completed actualizado desde externo');
    }
    if (subtasks != widget.initialSubtasks) {
      debugPrint('HabitModalContent.didUpdateWidget: subtasks cambiadas');
      setState(() {
        subtasks = List<String>.from(widget.initialSubtasks);
        debugPrint('HabitModalContent.didUpdateWidget: setState ejecutado, subtasks=${subtasks.toString()}');
      });
    }
    debugPrint('HabitModalContent.didUpdateWidget: FIN - completed=$completed');
  }

  void _updateCompleted(bool value) {
    debugPrint('HabitModalSheet: Checkbox tapped. Valor actual: $completed. Nuevo valor: $value');
    setState(() {
      completed = value;
      debugPrint('HabitModalSheet: setState ejecutado, completed=$completed');
    });
    debugPrint('HabitModalSheet: Estado actualizado, completed=$completed');
    // Solo notifica el cambio, no espera valor de retorno
    if (widget.onCompletedChanged != null) {
      debugPrint('HabitModalSheet: onCompletedChanged callback disparado con valor $completed');
      widget.onCompletedChanged!(completed);
      debugPrint('HabitModalSheet: callback ejecutado, esperando actualización externa...');
    }
  }

  void _addSubtask(String text) {
    setState(() {
      subtasks.add(text);
      showInput = false;
      _subtaskController.clear();
    });
    widget.onSubtasksChanged?.call(subtasks);
  }

  void _removeSubtask(String text) {
    setState(() {
      subtasks.remove(text);
    });
    widget.onSubtasksChanged?.call(subtasks);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HabitModalSheet.build: habitName=${widget.habitName}, completed=$completed');
    debugPrint('HabitModalSheet.build: checkbox value=$completed, tachado=${completed ? 'true' : 'false'}');
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
                  debugPrint('HabitModalSheet: Checkbox onChanged llamado, valor=${val.toString()}');
                  _updateCompleted(val ?? false);
                  debugPrint('HabitModalSheet: Después de _updateCompleted, completed=$completed');
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.habitName,
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
          // Subtareas: barra tipo botón que se transforma en campo de texto
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showInput
                ? Padding(
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
                              if (text.trim().isNotEmpty) {
                                _addSubtask(text.trim());
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.purple, size: 28),
                          onPressed: () {
                            final text = _subtaskController.text.trim();
                            if (text.isNotEmpty) {
                              _addSubtask(text);
                            }
                          },
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.purple.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.purple.shade100, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        showInput = true;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.add, color: Colors.purple, size: 24),
                        const SizedBox(width: 8),
                        Text('Subtareas', style: TextStyle(fontSize: 16, color: Colors.purple.shade700)),
                        const Spacer(),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          ...subtasks.map((s) => ListTile(
                title: Text(s),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _removeSubtask(s);
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
    child: HabitModalContent(
      habitName: 'Ejemplo de tarea',
      initialCompleted: false,
      initialSubtasks: const [],
      onCompletedChanged: (completed) {
        // Lógica para manejar el cambio de estado de completado
      },
      onSubtasksChanged: (subtasks) {
        // Lógica para manejar el cambio en la lista de subtareas
      },
    ),
    maxHeight: 400,
  );
}
