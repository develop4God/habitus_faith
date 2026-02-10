import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskTimer extends StatefulWidget {
  final int targetSeconds;
  final VoidCallback? onCompleted;
  final Color activeColor;

  const TaskTimer({
    super.key,
    this.targetSeconds = 0,
    this.onCompleted,
    this.activeColor = Colors.purple,
  });

  @override
  State<TaskTimer> createState() => _TaskTimerState();
}

class _TaskTimerState extends State<TaskTimer> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _toggleTimer() {
    HapticFeedback.lightImpact();
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    // If we're at or past goal, but target is set, reset if restarting?
    // Actually, just keep counting up.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _seconds++;
        if (widget.targetSeconds > 0 && _seconds >= widget.targetSeconds) {
          if (_seconds == widget.targetSeconds) {
            widget.onCompleted?.call();
            HapticFeedback.heavyImpact();
          }
        }
      });
    });
    setState(() {
      _isRunning = true;
    });
    _pulseController.repeat(reverse: true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null; // Ensure it's cleared
    setState(() {
      _isRunning = false;
    });
    _pulseController.stop();
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    _timer = null;
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
    _pulseController.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If targetSeconds is 0 or less, we don't have a goal progress
    final double? progressValue = (widget.targetSeconds > 0)
        ? (_seconds / widget.targetSeconds).clamp(0.0, 1.0)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progressValue,
                strokeWidth: 8,
                backgroundColor: widget.activeColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.03).animate(_pulseController),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_seconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade900,
                    ),
                  ),
                  if (widget.targetSeconds > 0)
                    Text(
                      'Goal: ${_formatTime(widget.targetSeconds)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.refresh_rounded,
              onPressed: _resetTimer,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _toggleTimer,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.activeColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 24),
            _ActionButton(
              icon: Icons.stop_rounded,
              onPressed: () {
                _resetTimer(); // Stop now also acts as a full reset/stop
              },
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
