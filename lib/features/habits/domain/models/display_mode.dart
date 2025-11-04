/// Enumeration for display modes in the app
enum DisplayMode {
  /// Compact mode - shows essential features only with minimalist interface
  compact,

  /// Advanced mode - shows all features and advanced options
  advanced;

  /// Convert to string for storage
  String toStorageString() {
    return name;
  }

  /// Create from storage string
  static DisplayMode fromStorageString(String value) {
    return DisplayMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => DisplayMode.compact,
    );
  }
}
