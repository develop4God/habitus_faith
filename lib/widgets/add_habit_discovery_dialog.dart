import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import 'add_habit_dialog.dart';

class AddHabitDiscoveryDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const AddHabitDiscoveryDialog({super.key, required this.l10n});

  @override
  State<AddHabitDiscoveryDialog> createState() =>
      _AddHabitDiscoveryDialogState();
}

class _AddHabitDiscoveryDialogState extends State<AddHabitDiscoveryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            // Botón X arriba derecha
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon:
                    const Icon(Icons.close, size: 32, color: Color(0xff1a202c)),
                splashRadius: 26,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Icon(Icons.add_circle_outline,
                      size: 56, color: Color(0xff6366f1)),
                  const SizedBox(height: 16),
                  Text(
                    widget.l10n.addHabit,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo explicativo traducido
                  Text(
                    widget.l10n.addHabitDiscoverySubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Lottie.asset(
                        'assets/lottie/tap_screen.json',
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedBorderButton(
                          animation: _controller,
                          borderColors: const [
                            Color(0xff7c3aed), // Purple
                            Color(0xffc4b5fd), // Light Purple
                            Color(0xff7c3aed),
                          ],
                          backgroundColor: const Color(0xfff3e8ff),
                          icon: Icons.edit_note,
                          label: widget.l10n.custom,
                          textColor: const Color(0xff7c3aed),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddHabitDialog(
                                l10n: widget.l10n,
                                initialTab: 0,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _AnimatedBorderButton(
                          animation: _controller,
                          borderColors: const [
                            Color(0xff06b6d4), // Cyan
                            Color(0xffa5f3fc), // Light Cyan
                            Color(0xff06b6d4),
                          ],
                          backgroundColor: const Color(0xffecfeff),
                          icon: Icons.checklist_outlined,
                          label: widget.l10n.defaultHabit,
                          textColor: const Color(0xff06b6d4),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => AddHabitDialog(
                                l10n: widget.l10n,
                                initialTab: 1,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBorderButton extends StatelessWidget {
  final Animation<double> animation;
  final List<Color> borderColors;
  final Color backgroundColor;
  final IconData icon;
  final String label;
  final Color textColor;
  final VoidCallback onPressed;

  const _AnimatedBorderButton({
    required this.animation,
    required this.borderColors,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double t = animation.value;
        // Gradiente animado alrededor del borde
        final Gradient borderGradient = LinearGradient(
          colors: borderColors,
          stops: [
            (t + 0.0) % 1.0,
            (t + 0.5) % 1.0,
            (t + 1.0) % 1.0,
          ],
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: borderGradient,
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 32, color: textColor),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
