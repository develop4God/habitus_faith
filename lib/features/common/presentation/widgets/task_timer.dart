import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../../../l10n/app_localizations.dart';

class TaskTimer extends StatefulWidget {
  final int initialSeconds;
  final String habitName;
  final VoidCallback? onCompleted;
  final VoidCallback? onReset;
  final VoidCallback? onFinish;
  final Color activeColor;

  const TaskTimer({
    super.key,
    required this.habitName,
    this.initialSeconds = 0,
    this.onCompleted,
    this.onReset,
    this.onFinish,
    this.activeColor = Colors.purple,
  });

  @override
  State<TaskTimer> createState() => _TaskTimerState();
}

class _TaskTimerState extends State<TaskTimer> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 0;
  int _totalDuration = 0;
  bool _isRunning = false;
  bool _isCompleted = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _totalDuration = widget.initialSeconds > 0 ? widget.initialSeconds : 300;
    _secondsRemaining = _totalDuration;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _toggleTimer() {
    if (_isCompleted) {
      HapticFeedback.mediumImpact();
      widget.onFinish?.call();
      return;
    }
    if (_secondsRemaining <= 0) return;
    
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          HapticFeedback.selectionClick();
        } else {
          _timer?.cancel();
          _timer = null;
          _isRunning = false;
          _isCompleted = true;
          _pulseController.stop();
          widget.onCompleted?.call();
          HapticFeedback.heavyImpact();
        }
      });
    });
    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });
    _pulseController.repeat(reverse: true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
    _pulseController.stop();
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _timer = null;
    setState(() {
      _secondsRemaining = _totalDuration;
      _isRunning = false;
      _isCompleted = false;
    });
    _pulseController.reset();
    widget.onReset?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressValue = _totalDuration > 0 
        ? (_secondsRemaining / _totalDuration).clamp(0.0, 1.0) 
        : 0.0;

    final ringColor = _isCompleted ? Colors.green : (_isRunning ? widget.activeColor : Colors.grey.shade300);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Info
            if (_isCompleted) ...[
              Text(
                l10n.habitCompleted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Text(
                l10n.timeToFocus,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            Text(
              widget.habitName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 40),

            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 260,
                    height: 260,
                    child: CircularProgressIndicator(
                      value: _isCompleted ? 1.0 : progressValue,
                      strokeWidth: _isCompleted ? 8 : 4,
                      backgroundColor: ringColor.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _isCompleted 
                        ? _buildCelebrationDisplay()
                        : (_isRunning || (_secondsRemaining < _totalDuration && _secondsRemaining > 0)
                            ? _buildCountdownDisplay()
                            : _buildPickerDisplay()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildControls(),
            const SizedBox(height: 16), // Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationDisplay() {
    return SizedBox(
      key: const ValueKey('celebration'),
      height: 160,
      width: 160,
      child: Lottie.asset(
        'assets/lottie/Congratulation _ Success batch.json',
        repeat: false,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    return ScaleTransition(
      key: const ValueKey('countdown'),
      scale: Tween(begin: 1.0, end: 1.02).animate(_pulseController),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_secondsRemaining),
            style: TextStyle(
              fontSize: 84,
              fontWeight: FontWeight.w200,
              fontFamily: 'monospace',
              color: Colors.grey.shade900,
              letterSpacing: -4,
              height: 0.9,
            ),
          ),
          SizedBox(
            height: 110,
            width: 110,
            child: Lottie.asset(
              'assets/lottie/sand_hourglass_pink.json',
              animate: _isRunning,
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerDisplay() {
    return SizedBox(
      key: const ValueKey('picker'),
      width: 200,
      height: 200,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: widget.activeColor,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.ms,
          initialTimerDuration: Duration(seconds: _totalDuration),
          onTimerDurationChanged: (Duration duration) {
            HapticFeedback.selectionClick();
            setState(() {
              _totalDuration = duration.inSeconds;
              _secondsRemaining = _totalDuration;
            });
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlCircle(
          onTap: _resetTimer,
          icon: Icons.refresh_rounded,
          color: Colors.grey.shade100,
          iconColor: Colors.grey.shade600,
        ),
        const SizedBox(width: 40),
        
        GestureDetector(
          onTap: _toggleTimer,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _isCompleted 
                  ? Colors.green.withValues(alpha: 0.1)
                  : (_isRunning 
                      ? Colors.orange.withValues(alpha: 0.1) 
                      : widget.activeColor.withValues(alpha: 0.1)),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isCompleted 
                    ? Colors.green 
                    : (_isRunning ? Colors.orange : widget.activeColor),
                width: 2,
              ),
            ),
            child: Icon(
              _isCompleted 
                  ? Icons.check_rounded
                  : (_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
              size: 48,
              color: _isCompleted 
                  ? Colors.green 
                  : (_isRunning ? Colors.orange : widget.activeColor),
            ),
          ),
        ),
        
        const SizedBox(width: 40),
        const SizedBox(width: 56),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _ControlCircle extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _ControlCircle({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
