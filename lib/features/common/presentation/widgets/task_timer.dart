import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class TaskTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onCompleted;
  final Color activeColor;

  const TaskTimer({
    super.key,
    this.initialSeconds = 0,
    this.onCompleted,
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
          // Modern iOS-style tick feel
          if (_secondsRemaining % 1 == 0) {
            HapticFeedback.selectionClick();
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          _pulseController.stop();
          widget.onCompleted?.call();
          HapticFeedback.heavyImpact();
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
    final progressValue = _totalDuration > 0 
        ? (_secondsRemaining / _totalDuration).clamp(0.0, 1.0) 
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Progress Ring
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 4,
                  backgroundColor: widget.activeColor.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isRunning ? widget.activeColor : Colors.grey.shade300,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              
              // iOS Style Picker or Large Countdown
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isRunning || (_secondsRemaining < _totalDuration && _secondsRemaining > 0)
                    ? _buildCountdownDisplay()
                    : _buildPickerDisplay(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        _buildControls(),
      ],
    );
  }

  Widget _buildCountdownDisplay() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.02).animate(_pulseController),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_secondsRemaining),
            style: TextStyle(
              fontSize: 75, // Bigger font
              fontWeight: FontWeight.w200,
              fontFamily: 'monospace',
              color: Colors.grey.shade900,
              letterSpacing: -4,
              height: 0.9, // Tighter line height to bring Lottie closer
            ),
          ),
          SizedBox(
            height: 110, // Significantly bigger Lottie
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
            HapticFeedback.selectionClick(); // Tick sound/feel
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
        // Reset Button
        _ControlCircle(
          onTap: _resetTimer,
          icon: Icons.refresh_rounded,
          color: Colors.grey.shade100,
          iconColor: Colors.grey.shade600,
        ),
        const SizedBox(width: 40),
        
        // Start/Pause Button
        GestureDetector(
          onTap: _toggleTimer,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _isRunning 
                  ? Colors.orange.withValues(alpha: 0.1) 
                  : widget.activeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRunning ? Colors.orange : widget.activeColor,
                width: 2,
              ),
            ),
            child: Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 48,
              color: _isRunning ? Colors.orange : widget.activeColor,
            ),
          ),
        ),
        
        const SizedBox(width: 40),
        // Stop Button
        _ControlCircle(
          onTap: () {
            if (_secondsRemaining < _totalDuration) {
               _resetTimer();
            }
          },
          icon: Icons.stop_rounded,
          color: Colors.grey.shade100,
          iconColor: Colors.grey.shade400,
        ),
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
