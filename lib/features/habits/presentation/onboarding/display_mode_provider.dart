import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import '../../data/storage/storage_providers.dart';
import '../../domain/models/display_mode.dart';

/// Key used to store display mode in SharedPreferences
const String _displayModeKey = 'display_mode';

/// Provider to check if display mode has been selected
final displayModeSelectedProvider = Provider<bool>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  return storage.containsKey(_displayModeKey);
});

/// Provider for the current display mode
/// Reads from SharedPreferences and provides the current mode
final displayModeProvider =
    StateNotifierProvider<DisplayModeNotifier, DisplayMode>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  final savedMode = storage.getString(_displayModeKey);
  final initialMode = savedMode != null
      ? DisplayMode.fromStorageString(savedMode)
      : DisplayMode.compact;

  return DisplayModeNotifier(ref, initialMode);
});

/// Notifier for managing display mode state
class DisplayModeNotifier extends StateNotifier<DisplayMode> {
  final Ref _ref;

  DisplayModeNotifier(this._ref, DisplayMode initialMode) : super(initialMode);

  /// Set the display mode and persist to storage
  Future<void> setDisplayMode(DisplayMode mode) async {
    state = mode;
    debugPrint('Provider: displayMode cambiado a $mode');
    final storage = _ref.read(jsonStorageServiceProvider);
    await storage.setString(_displayModeKey, mode.toStorageString());
  }

  /// Get the current display mode
  DisplayMode get currentMode => state;

  /// Check if current mode is compact
  bool get isCompactMode => state == DisplayMode.compact;

  /// Check if current mode is advanced
  bool get isAdvancedMode => state == DisplayMode.advanced;
}
