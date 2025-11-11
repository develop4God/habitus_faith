import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/habits/domain/models/habit_notification.dart';
import '../l10n/app_localizations.dart';

class ReminderConfigDialog extends ConsumerStatefulWidget {
  final HabitNotificationSettings? initialSettings;
  final String? eventTime;

  const ReminderConfigDialog({
    super.key,
    this.initialSettings,
    this.eventTime,
  });

  @override
  ConsumerState<ReminderConfigDialog> createState() =>
      _ReminderConfigDialogState();
}

class _ReminderConfigDialogState extends ConsumerState<ReminderConfigDialog> {
  late NotificationTiming selectedTiming;
  int? customMinutes;
  String? customMinutesError;

  @override
  void initState() {
    super.initState();
    selectedTiming = widget.initialSettings?.timing ?? NotificationTiming.none;
    customMinutes = widget.initialSettings?.customMinutesBefore;
  }

  bool _validateCustomMinutes(String value) {
    final minutes = int.tryParse(value);
    if (minutes == null || minutes < 1 || minutes > 1440) {
      setState(() {
        customMinutesError = AppLocalizations.of(context)!.invalidMinutes;
      });
      return false;
    }
    setState(() {
      customMinutesError = null;
    });
    return true;
  }

  String _getEffectiveTime(NotificationTiming timing) {
    if (widget.eventTime == null) return '';

    final parts = widget.eventTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final totalMinutes = hour * 60 + minute;
    int? adjustedMinutes;

    if (timing == NotificationTiming.custom && customMinutes != null) {
      adjustedMinutes = totalMinutes - customMinutes!;
    } else if (timing.minutesBefore != null) {
      adjustedMinutes = totalMinutes - timing.minutesBefore!;
    } else {
      adjustedMinutes = totalMinutes;
    }

    if (adjustedMinutes < 0) adjustedMinutes += 24 * 60;

    final adjustedHour = (adjustedMinutes ~/ 60) % 24;
    final adjustedMinute = adjustedMinutes % 60;

    return '(${adjustedHour.toString().padLeft(2, '0')}:${adjustedMinute.toString().padLeft(2, '0')})';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reminderConfig,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildTimingOption(
              timing: NotificationTiming.none,
              title: NotificationTiming.none.displayName,
              isSelected: selectedTiming == NotificationTiming.none,
            ),
            _buildTimingOption(
              timing: NotificationTiming.atEventTime,
              title: NotificationTiming.atEventTime.displayName,
              effectiveTime: widget.eventTime ?? '',
              isSelected: selectedTiming == NotificationTiming.atEventTime,
            ),
            _buildTimingOption(
              timing: NotificationTiming.tenMinutesBefore,
              title: NotificationTiming.tenMinutesBefore.displayName,
              effectiveTime:
                  _getEffectiveTime(NotificationTiming.tenMinutesBefore),
              isSelected: selectedTiming == NotificationTiming.tenMinutesBefore,
            ),
            _buildTimingOption(
              timing: NotificationTiming.thirtyMinutesBefore,
              title: NotificationTiming.thirtyMinutesBefore.displayName,
              effectiveTime:
                  _getEffectiveTime(NotificationTiming.thirtyMinutesBefore),
              isSelected:
                  selectedTiming == NotificationTiming.thirtyMinutesBefore,
            ),
            _buildTimingOption(
              timing: NotificationTiming.oneHourBefore,
              title: NotificationTiming.oneHourBefore.displayName,
              effectiveTime:
                  _getEffectiveTime(NotificationTiming.oneHourBefore),
              isSelected: selectedTiming == NotificationTiming.oneHourBefore,
            ),
            _buildTimingOption(
              timing: NotificationTiming.custom,
              title: NotificationTiming.custom.displayName,
              isSelected: selectedTiming == NotificationTiming.custom,
              showCustomInput: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate custom minutes if that option is selected
                  if (selectedTiming == NotificationTiming.custom) {
                    if (customMinutes == null ||
                        customMinutes! < 1 ||
                        customMinutes! > 1440) {
                      setState(() {
                        customMinutesError =
                            AppLocalizations.of(context)!.invalidMinutes;
                      });
                      return;
                    }
                  }

                  final settings = HabitNotificationSettings(
                    timing: selectedTiming,
                    customMinutesBefore: customMinutes,
                    eventTime: widget.eventTime,
                  );
                  Navigator.of(context).pop(settings);
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
    );
  }

  Widget _buildTimingOption({
    required NotificationTiming timing,
    required String title,
    String? effectiveTime,
    required bool isSelected,
    bool showCustomInput = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTiming = timing;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (effectiveTime != null && effectiveTime.isNotEmpty)
                    Text(
                      effectiveTime,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (showCustomInput && isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.minutesBefore,
                          border: const OutlineInputBorder(),
                          isDense: true,
                          errorText: customMinutesError,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _validateCustomMinutes(value);
                            setState(() {
                              customMinutes = int.tryParse(value);
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            Radio<NotificationTiming>(
              value: timing,
              groupValue: selectedTiming,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTiming = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
