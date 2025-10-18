/// String extensions for Bible reader
extension StringExtensions on String {
  /// Simple translation placeholder - returns key as-is for now
  /// TODO: Integrate with proper i18n system
  String tr() {
    // For now, return a simplified version without the prefix
    if (contains('.')) {
      return split('.').last.replaceAll('_', ' ').capitalize();
    }
    return this;
  }
  
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
