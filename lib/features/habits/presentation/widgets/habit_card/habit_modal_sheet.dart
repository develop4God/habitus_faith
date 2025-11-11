import 'dart:ui';
import 'package:flutter/material.dart';

class HabitModalSheet extends StatelessWidget {
  final Widget child;
  final double? maxHeight;

  const HabitModalSheet({
    super.key,
    required this.child,
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: 0.35), // fondo claro desenfocado
      enableDrag: true,
      isDismissible: true,
      builder: (ctx) => HabitModalSheet(
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo desenfocado
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.white.withValues(alpha: 0.15), // fondo claro desenfocado
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: maxHeight != null
                ? BoxConstraints(maxHeight: maxHeight!)
                : const BoxConstraints(maxHeight: 480),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.10), // sombra clara
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

// Widget de prueba para el modal
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
                  setState(() {
                    completed = val ?? false;
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
          StatefulBuilder(
            builder: (context, setBarState) {
              return Column(
                children: [
                  if (!showInput)
                    GestureDetector(
                      onTap: () => setState(() => showInput = true),
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
                                if (text.trim().isNotEmpty) {
                                  setState(() {
                                    subtasks.add(text.trim());
                                    _subtaskController.clear();
                                    showInput = false;
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
                              if (text.isNotEmpty) {
                                setState(() {
                                  subtasks.add(text);
                                  _subtaskController.clear();
                                  showInput = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          ...subtasks.map((s) => ListTile(
                title: Text(s),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      subtasks.remove(s);
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }
}

// Ejemplo de cómo mostrar el modal para pruebas
void showTestHabitModal(BuildContext context) {
  HabitModalSheet.show(
    context: context,
    child: HabitModalContent(),
    maxHeight: 400,
  );
}
