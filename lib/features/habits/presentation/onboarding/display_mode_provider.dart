import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/storage_providers.dart';
import '../../domain/models/display_mode.dart';

/// Key used to store display mode in SharedPreferences
const String _displayModeKey = 'display_mode';

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

/// Provider that checks if a display mode has been selected
/// Returns true if a display mode is stored, false otherwise
final displayModeSelectedProvider = Provider<bool>((ref) {
  final storage = ref.watch(jsonStorageServiceProvider);
  final savedMode = storage.getString(_displayModeKey);
  return savedMode != null;
});
