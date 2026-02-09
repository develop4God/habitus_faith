import 'package:flutter/material.dart';
import '../../main.dart' show rootScaffoldMessengerKey;

/// Utility class for showing snackbars globally without needing a BuildContext.
/// This is especially useful after async operations or when the widget is unmounted.
class GlobalSnackbar {
  /// Shows a success snackbar with a green background
  static void showSuccess(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green.shade600,
      duration: duration,
    );
  }

  /// Shows an error snackbar with a red background
  static void showError(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade600,
      duration: duration,
    );
  }

  /// Shows a warning snackbar with an orange background
  static void showWarning(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: Colors.orange.shade600,
      duration: duration,
    );
  }

  /// Shows an info snackbar with a blue background
  static void showInfo(String message, {Duration? duration}) {
    _showSnackbar(
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue.shade600,
      duration: duration,
    );
  }

  /// Shows a custom snackbar with specified icon and color
  static void showCustom({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration? duration,
  }) {
    _showSnackbar(
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  static void _showSnackbar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration? duration,
  }) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

