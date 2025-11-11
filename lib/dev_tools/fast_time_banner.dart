import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/providers/clock_provider.dart';

/// Visual indicator banner shown when FAST_TIME mode is active
///
/// This widget displays a prominent banner at the top of the screen
/// when the app is running with time acceleration enabled via
/// --dart-define=FAST_TIME=true
///
/// The banner shows:
/// - Current simulated date/time
/// - Time acceleration multiplier
/// - Real-time update every second
///
/// This helps developers understand the accelerated timeline during
/// dogfooding and testing.
class FastTimeBanner extends ConsumerStatefulWidget {
  const FastTimeBanner({super.key});

  @override
  ConsumerState<FastTimeBanner> createState() => _FastTimeBannerState();
}

class _FastTimeBannerState extends ConsumerState<FastTimeBanner> {
  // Track if FAST_TIME is enabled
  static const bool _fastTimeEnabled = bool.fromEnvironment('FAST_TIME');

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode with FAST_TIME flag
    if (!kDebugMode || !_fastTimeEnabled) {
      return const SizedBox.shrink();
    }

    final clock = ref.watch(clockProvider);
    final now = clock.now();

    return Material(
      color: Colors.orange.shade700,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.fast_forward, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FAST TIME MODE ACTIVE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    Text(
                      'Simulated: ${DateFormat('MMM d, y HH:mm:ss').format(now)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '288x',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that adds FastTimeBanner above the child widget
///
/// Use this to wrap your MaterialApp to show the FAST_TIME banner:
///
/// ```dart
/// runApp(
///   ProviderScope(
///     child: WithFastTimeBanner(
///       child: MaterialApp(
///         home: HomePage(),
///       ),
///     ),
///   ),
/// );
/// ```
class WithFastTimeBanner extends StatelessWidget {
  final Widget child;

  const WithFastTimeBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FastTimeBanner(),
        Expanded(child: child),
      ],
    );
  }
}
