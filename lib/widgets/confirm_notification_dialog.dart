import 'package:flutter/material.dart';
import 'package:habitus_faith/core/services/notifications/notification_validator.dart';

/// Shows a simple, modern confirmation dialog for a proposed notification time.
/// Returns the confirmed [TimeOfDay] if the user confirms, or null if canceled/edited.
Future<TimeOfDay?> showConfirmNotificationDialog(
  BuildContext context, {
  required TimeOfDay proposedTime,
  List<TimeOfDay>? existingTimes,
  String? userTimezone,
}) {
  existingTimes ??= const [];

  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return _ConfirmNotificationDialogContent(
        proposedTime: proposedTime,
        existingTimes: existingTimes!,
        userTimezone: userTimezone,
      );
    },
  );
}

class _ConfirmNotificationDialogContent extends StatefulWidget {
  final TimeOfDay proposedTime;
  final List<TimeOfDay> existingTimes;
  final String? userTimezone;

  const _ConfirmNotificationDialogContent({
    Key? key,
    required this.proposedTime,
    required this.existingTimes,
    this.userTimezone,
  }) : super(key: key);

  @override
  State<_ConfirmNotificationDialogContent> createState() => _ConfirmNotificationDialogContentState();
}

class _ConfirmNotificationDialogContentState extends State<_ConfirmNotificationDialogContent> {
  late TimeOfDay _current;
  ValidationResult? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _current = widget.proposedTime;
    _validate();
  }

  Future<void> _validate() async {
    setState(() => _loading = true);
    final r = await NotificationValidator.validate(
      requestedTime: _current,
      existingScheduledTimes: widget.existingTimes,
      userTimezone: widget.userTimezone,
      clockHourOnly: true,
    );
    setState(() {
      _result = r;
      _loading = false;
    });
  }

  void _applySuggestion(TimeOfDay t) {
    setState(() => _current = t);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _current.format(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                timeStr,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '¿Desea ajustar la hora de notificación a $timeStr?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const LinearProgressIndicator()
            else if (_result != null && _result!.status != ValidationStatus.valid)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_result!.message ?? '')),
                  ],
                ),
              ),
            if (!_loading && _result != null && _result!.suggestedTimes.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _result!.suggestedTimes
                    .map((t) => ActionChip(
                          label: Text(t.format(context)),
                          onPressed: () => _applySuggestion(t),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!_loading && _result != null && _result!.status == ValidationStatus.valid)
                        ? () => Navigator.of(context).pop(_current)
                        : null,
                    child: const Text('Confirmar hora'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

