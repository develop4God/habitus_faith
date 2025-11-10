import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../l10n/app_localizations.dart';

class RecurrenceConfigDialog extends ConsumerStatefulWidget {
  final HabitRecurrence? initialRecurrence;

  const RecurrenceConfigDialog({
    super.key,
    this.initialRecurrence,
  });

  @override
  ConsumerState<RecurrenceConfigDialog> createState() =>
      _RecurrenceConfigDialogState();
}

class _RecurrenceConfigDialogState
    extends ConsumerState<RecurrenceConfigDialog> {
  late bool repeatEnabled;
  late RecurrenceFrequency frequency;
  late int interval;
  bool hasEndDate = false;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    repeatEnabled = widget.initialRecurrence?.enabled ?? false;
    frequency =
        widget.initialRecurrence?.frequency ?? RecurrenceFrequency.daily;
    interval = widget.initialRecurrence?.interval ?? 1;
    endDate = widget.initialRecurrence?.endDate;
    hasEndDate = endDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Repeticiones cada día',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              // Repeat toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Repetir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Fija un ciclo para tu plan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: repeatEnabled,
                      onChanged: (value) {
                        setState(() {
                          repeatEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (repeatEnabled) ...[
                const SizedBox(height: 24),
                // Frequency tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFrequencyTab(
                          RecurrenceFrequency.daily,
                          'Diario',
                        ),
                      ),
                      Expanded(
                        child: _buildFrequencyTab(
                          RecurrenceFrequency.weekly,
                          'Semanal',
                        ),
                      ),
                      Expanded(
                        child: _buildFrequencyTab(
                          RecurrenceFrequency.monthly,
                          'Mensual',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Interval
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Intervalo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Cada $interval ${_getFrequencyUnit()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // End date
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Fecha de finalización',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: hasEndDate,
                        onChanged: (value) {
                          setState(() {
                            hasEndDate = value;
                            if (value && endDate == null) {
                              endDate =
                                  DateTime.now().add(const Duration(days: 30));
                            } else if (!value) {
                              endDate = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (hasEndDate && endDate != null) ...[
                  const SizedBox(height: 16),
                  // Calendar view (simplified)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_getMonthName(endDate!.month)}, ${endDate!.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate!,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                          child: Text(
                            '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final recurrence = HabitRecurrence(
                      enabled: repeatEnabled,
                      frequency: frequency,
                      interval: interval,
                      endDate: hasEndDate ? endDate : null,
                    );
                    Navigator.of(context).pop(recurrence);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyTab(RecurrenceFrequency freq, String label) {
    final isSelected = frequency == freq;
    return GestureDetector(
      onTap: () {
        setState(() {
          frequency = freq;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue.shade900 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  String _getFrequencyUnit() {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return 'día';
      case RecurrenceFrequency.weekly:
        return 'semana';
      case RecurrenceFrequency.monthly:
        return 'mes';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return months[month];
  }
}
