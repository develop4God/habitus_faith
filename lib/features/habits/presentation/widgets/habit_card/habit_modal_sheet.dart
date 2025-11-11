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
