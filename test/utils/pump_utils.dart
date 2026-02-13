import 'package:flutter_test/flutter_test.dart';

extension TestPumpExtensions on WidgetTester {
  /// Pump multiple frames to allow UI to render without waiting for animations
  /// Use this instead of pumpAndSettle when Lottie animations are present
  Future<void> pumpTestFrames([int frames = 10]) async {
    for (int i = 0; i < frames; i++) {
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Pump until widget tree is built, with timeout protection
  Future<void> pumpWithTimeout([Duration? duration]) async {
    await pump(duration ?? Duration.zero);
    // Give a few frames for initial render
    await pump(const Duration(milliseconds: 100));
    await pump(const Duration(milliseconds: 100));
  }
}
