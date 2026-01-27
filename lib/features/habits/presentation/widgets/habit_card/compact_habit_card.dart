import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habit_modal_sheet.dart';
import '../../../domain/habit.dart';
import '../../../domain/models/habit_notification.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../constants/habit_colors.dart';

/// Compact habit card with tap-to-expand details
/// Shows only essential info: name, emoji, streak, completion button
class CompactHabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Future<void> Function(String) onComplete;
  final Future<void> Function(String) onUncheck;

  const CompactHabitCard({
    super.key,
    required this.habit,
    required this.onDelete,
    required this.onEdit,
    required this.onComplete,
    required this.onUncheck,
  });

  @override
  ConsumerState<CompactHabitCard> createState() => _CompactHabitCardState();
}

class _CompactHabitCardState extends ConsumerState<CompactHabitCard> {
  final bool _isExpanded = false;
  bool _isCompleting = false;
  List<Subtask> _subtasks = [];
  bool _showLottieTick = false;
  // --- CAMBIO: variables persistentes para subtareas ---
  bool _showSubtaskInput = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subtasks = List<Subtask>.from(widget.habit.subtasks);
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      if (widget.habit.completedToday) {
        debugPrint('Desmarcando hábito: ${widget.habit.id}');
        await widget.onUncheck(widget.habit.id);
        debugPrint('Happy path: onUncheck completado para ${widget.habit.id}');
        setState(() {
          _showLottieTick = false;
        });
      } else {
        debugPrint('Marcando hábito: ${widget.habit.id}');
        await widget.onComplete(widget.habit.id);
        debugPrint('Happy path: onComplete completado para ${widget.habit.id}');
        setState(() {
          _showLottieTick = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant CompactHabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
        'didUpdateWidget: habit.id=${widget.habit.id}, completedToday=${widget.habit.completedToday} (anterior: ${oldWidget.habit.completedToday})');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'CompactHabitCard.build: habit.id=${widget.habit.id}, completedToday=${widget.habit.completedToday}');
    debugPrint(
        'CompactHabitCard.build: checkbox value=${widget.habit.completedToday}, tachado=${widget.habit.completedToday}');
    final l10n = AppLocalizations.of(context)!;
    final habitColor = HabitColors.getHabitColor(widget.habit);
    final isTached = widget.habit.completedToday || _showLottieTick;
    debugPrint(
        'CompactHabitCard.build: checkbox value=${widget.habit.completedToday}, tachado=$isTached');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: habitColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact view - always visible
          InkWell(
            onTap: () async {
              await HabitModalSheet.show(
                context: context,
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return _buildExpandedContent(
                        context, l10n, habitColor, setModalState);
                  },
                ),
                maxHeight: 480,
              );
              // Aquí puedes refrescar la lista de hábitos si es necesario
              setState(() {});
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Emoji a la izquierda
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.emoji ?? '✓',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nombre y racha centrados
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.habit.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration:
                                widget.habit.completedToday || _showLottieTick
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                            decorationThickness: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        if (!_isExpanded) // Mostrar racha solo en vista compacta
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: widget.habit.currentStreak > 0
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.habit.currentStreak} ${l10n.days}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Check box a la derecha
                  InkWell(
                    onTap: _isCompleting ? null : _handleComplete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      child: _isCompleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  habitColor,
                                ),
                              ),
                            )
                          : Transform.scale(
                              scale:
                                  1.5, // Aumenta el tamaño visual del checkbox
                              child: Checkbox(
                                value: widget.habit.completedToday,
                                onChanged: (val) {
                                  debugPrint(
                                      'Checkbox tapped. Valor actual: ${widget.habit.completedToday}. Nuevo valor: $val');
                                  if (!_isCompleting) {
                                    _handleComplete();
                                    debugPrint('Llamando a _handleComplete()');
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                activeColor: habitColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: 0),
                                side: BorderSide(width: 2, color: habitColor),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, AppLocalizations l10n,
      Color habitColor, StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarea igual que en la vista compacta
          Row(
            children: [
              // Emoji a la izquierda
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.habit.emoji ?? '✓',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y racha centrados
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: widget.habit.completedToday
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: widget.habit.currentStreak > 0
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.habit.currentStreak} ${l10n.days}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Check box a la derecha
              InkWell(
                onTap: _isCompleting
                    ? null
                    : () async {
                        // Close modal and perform action
                        Navigator.of(context).pop();
                        await _handleComplete();
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  child: _isCompleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              habitColor,
                            ),
                          ),
                        )
                      : Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            value: widget.habit.completedToday,
                            onChanged: (val) async {
                              if (!_isCompleting) {
                                Navigator.of(context).pop();
                                await _handleComplete();
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            activeColor: habitColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity:
                                const VisualDensity(horizontal: 0, vertical: 0),
                            side: BorderSide(width: 2, color: habitColor),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 16),
          // Iconos y estado de notificaciones y repetición
          // Línea de notificaciones reales
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  widget.habit.notificationSettings != null &&
                          widget.habit.notificationSettings!.timing !=
                              NotificationTiming.none
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: widget.habit.notificationSettings != null &&
                          widget.habit.notificationSettings!.timing !=
                              NotificationTiming.none
                      ? Colors.orange
                      : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.habit.notificationSettings != null &&
                          widget.habit.notificationSettings!.timing !=
                              NotificationTiming.none
                      ? Text(
                          '${widget.habit.notificationSettings!.eventTime ?? ''} · ${widget.habit.notificationSettings!.timing.displayName}',
                          style: const TextStyle(fontSize: 15),
                        )
                      : Text(
                          l10n.notificationsOff,
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                ),
              ],
            ),
          ),
          // Línea de repetición real
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  widget.habit.recurrence != null &&
                          widget.habit.recurrence!.enabled
                      ? Icons.repeat
                      : Icons.repeat,
                  color: widget.habit.recurrence != null &&
                          widget.habit.recurrence!.enabled
                      ? Colors.green
                      : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.habit.recurrence != null &&
                          widget.habit.recurrence!.enabled
                      ? Text(
                          '${widget.habit.recurrence!.frequency.displayName} · Cada ${widget.habit.recurrence!.interval} ${_getFrequencyUnit(widget.habit.recurrence!.frequency)}',
                          style: const TextStyle(fontSize: 15),
                        )
                      : Text(
                          l10n.noRepetition,
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Subtasks section (solo en vista expandida)
          if (_subtasks.isNotEmpty || true) ...[
            Text(
              l10n.subtasks,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Subtask input - tap to add new
            Column(
              children: [
                InkWell(
                  onTap: () {
                    setModalState(() {
                      _showSubtaskInput = !_showSubtaskInput;
                    });
                  },
                  child: _showSubtaskInput
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _subtaskController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Nueva subtarea...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (text) {
                                    if (text.trim().isNotEmpty) {
                                      setModalState(() {
                                        _subtasks.add(Subtask(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          title: text.trim(),
                                          completed: false,
                                        ));
                                      });
                                      _subtaskController.clear();
                                      setModalState(() {
                                        _showSubtaskInput = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.purple, size: 28),
                                onPressed: () {
                                  final text = _subtaskController.text.trim();
                                  if (text.isNotEmpty) {
                                    setModalState(() {
                                      _subtasks.add(Subtask(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        title: text,
                                        completed: false,
                                      ));
                                    });
                                    _subtaskController.clear();
                                    setModalState(() {
                                      _showSubtaskInput = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.purple.shade100,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.purple, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Agregar subtarea',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.purple.shade700,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                // Lista de subtareas
                Column(
                  children: [
                    ..._subtasks.map((subtask) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          leading: Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: subtask.completed,
                              onChanged: (val) {
                                setModalState(() {
                                  final idx = _subtasks.indexOf(subtask);
                                  _subtasks[idx] =
                                      subtask.copyWith(completed: val ?? false);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              activeColor: Colors.purple,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: 0),
                              side: const BorderSide(
                                  width: 2, color: Colors.purple),
                            ),
                          ),
                          title: Text(
                            subtask.title,
                            style: TextStyle(
                              fontSize: 15,
                              decoration: subtask.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: subtask.completed
                                  ? Colors.green
                                  : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setModalState(() {
                                _subtasks.remove(subtask);
                              });
                            },
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                // Botón para editar la tarea
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.edit, size: 20),
                    label:
                        Text(l10n.edit, style: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close modal first
                      widget.onEdit(); // Then call edit
                    },
                  ),
                ),
              ],
            ),
          ],
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade700,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    widget.onEdit();
                  } else if (value == 'delete') {
                    widget.onDelete();
                  } else if (value == 'uncheck' &&
                      widget.habit.completedToday) {
                    widget.onUncheck(widget.habit.id);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  if (widget.habit.completedToday)
                    PopupMenuItem<String>(
                      value: 'uncheck',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.undo,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.uncheck),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFrequencyUnit(RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'día';
      case RecurrenceFrequency.weekly:
        return 'semana';
      case RecurrenceFrequency.monthly:
        return 'mes';
    }
  }
}
