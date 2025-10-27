/// String extensions for Bible reader
extension StringExtensions on String {
  /// Simple translation placeholder - returns key as-is for now
  /// TODO: Integrate with proper i18n system
  /// Supports parameters: 'key'.tr({'param': 'value'})
  String tr([Map<String, dynamic>? params]) {
    // For now, return a simplified version without the prefix
    String result;
    if (contains('.')) {
      result = split('.').last.replaceAll('_', ' ').capitalize();
    } else {
      result = this;
    }

    // Replace parameters if provided
    if (params != null) {
      params.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
    }

    return result;
  }

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
