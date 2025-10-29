import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../features/habits/domain/models/completion_record.dart';

/// Service for storing ML training data using GitHub Issues API
/// This provides zero-cost storage for training data collection
class GitHubMLStorage {
  static const _repo = 'develop4God/habitus_faith';
  
  // Token from environment or runtime config
  final String _token = const String.fromEnvironment('GITHUB_TOKEN');
  
  /// Save a completion record to GitHub Issues
  /// Each record is stored as an issue with ml-training-data label
  /// Fails silently if no token or network error
  Future<void> saveRecord(CompletionRecord record) async {
    if (_token.isEmpty) {
      debugPrint('GitHubMLStorage: No token, skipping upload');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('https://api.github.com/repos/$_repo/issues'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github.v3+json',
        },
        body: jsonEncode({
          'title': 'ML-${record.habitId.substring(0, 8)}-${record.completedAt.millisecondsSinceEpoch}',
          'body': jsonEncode(record.toJson()),
          'labels': ['ml-training-data', 'automated'],
        }),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 201) {
        debugPrint('GitHubMLStorage: Record saved successfully');
      } else {
        debugPrint('GitHubMLStorage: Failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('GitHubMLStorage: Failed to save: $e');
      // Non-critical - fail silently
    }
  }
}
