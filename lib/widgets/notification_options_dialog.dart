import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Dialog shown when user taps on an active notification bell
/// Provides options to turn off notification or change the time
class NotificationOptionsDialog extends StatelessWidget {
  final String currentTime;

  const NotificationOptionsDialog({
    super.key,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Semantics(
      label: l10n.notificationOptions,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Active notification',
                child: Icon(
                  Icons.notifications_active,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l10n.notificationOptions,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.currentTime}: $currentTime',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Option A: Turn off notification
            _buildOption(
              context,
              icon: Icons.notifications_off,
              title: l10n.turnOffNotification,
              subtitle: l10n.turnOffNotificationDesc,
              color: Colors.grey,
              onTap: () => Navigator.of(context).pop('turnOff'),
            ),
            const SizedBox(height: 12),
            // Option B: Change notification time
            _buildOption(
              context,
              icon: Icons.schedule,
              title: l10n.changeNotificationTime,
              subtitle: l10n.changeNotificationTimeDesc,
              color: Colors.blue,
              onTap: () => Navigator.of(context).pop('changeTime'),
            ),
            const SizedBox(height: 16),
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
