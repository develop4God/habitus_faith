import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for automatically updating ML models from GitHub releases
/// Checks weekly for new model versions and downloads them silently
class ModelUpdater {
  static const String _lastCheckKey = 'ml_last_check';
  static const Duration _checkInterval = Duration(days: 7);

  // GitHub release URLs for latest model files
  static const String _modelUrl =
      'https://github.com/develop4God/habitus_faith/releases/latest/download/predictor.tflite';
  static const String _scalerUrl =
      'https://github.com/develop4God/habitus_faith/releases/latest/download/scaler_params.json';

  /// Check if model update is needed and download if necessary
  /// This is a background operation that fails silently
  Future<void> checkAndUpdateModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString(_lastCheckKey);

      // Check if we need to update
      final now = DateTime.now();
      if (lastCheck != null) {
        final lastCheckDate = DateTime.parse(lastCheck);
        final timeSinceLastCheck = now.difference(lastCheckDate);

        if (timeSinceLastCheck < _checkInterval) {
          debugPrint(
              'ModelUpdater: Last check was ${timeSinceLastCheck.inDays} days ago, skipping');
          return;
        }
      }

      debugPrint('ModelUpdater: Checking for model updates...');

      // Download new models
      final success = await _downloadModels();

      if (success) {
        debugPrint('ModelUpdater: Models updated successfully');
        // Update last check timestamp
        await prefs.setString(_lastCheckKey, now.toIso8601String());
      } else {
        debugPrint('ModelUpdater: Model update failed');
      }
    } catch (e) {
      // Silent failure - don't block app startup
      debugPrint('ModelUpdater: Update check failed: $e');
    }
  }

  /// Download model files from GitHub releases
  /// Returns true if successful, false otherwise
  Future<bool> _downloadModels() async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final mlDir = Directory('${appDir.path}/ml');

      // Create ml directory if it doesn't exist
      if (!await mlDir.exists()) {
        await mlDir.create(recursive: true);
      }

      // Download predictor.tflite
      debugPrint('ModelUpdater: Downloading predictor.tflite...');
      final modelResponse = await http.get(Uri.parse(_modelUrl));

      if (modelResponse.statusCode != 200) {
        debugPrint(
            'ModelUpdater: Failed to download model, status: ${modelResponse.statusCode}');
        return false;
      }

      final modelFile = File('${mlDir.path}/predictor.tflite');
      await modelFile.writeAsBytes(modelResponse.bodyBytes);
      debugPrint(
          'ModelUpdater: predictor.tflite downloaded (${modelResponse.bodyBytes.length} bytes)');

      // Download scaler_params.json
      debugPrint('ModelUpdater: Downloading scaler_params.json...');
      final scalerResponse = await http.get(Uri.parse(_scalerUrl));

      if (scalerResponse.statusCode != 200) {
        debugPrint(
            'ModelUpdater: Failed to download scaler, status: ${scalerResponse.statusCode}');
        return false;
      }

      final scalerFile = File('${mlDir.path}/scaler_params.json');
      await scalerFile.writeAsString(scalerResponse.body);
      debugPrint('ModelUpdater: scaler_params.json downloaded');

      return true;
    } catch (e) {
      debugPrint('ModelUpdater: Download failed: $e');
      return false;
    }
  }

  /// Get the path to the downloaded model file
  /// Returns null if file doesn't exist
  static Future<String?> getDownloadedModelPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelFile = File('${appDir.path}/ml/predictor.tflite');

      if (await modelFile.exists()) {
        return modelFile.path;
      }
      return null;
    } catch (e) {
      debugPrint('ModelUpdater: Error getting model path: $e');
      return null;
    }
  }

  /// Get the path to the downloaded scaler params file
  /// Returns null if file doesn't exist
  static Future<String?> getDownloadedScalerPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final scalerFile = File('${appDir.path}/ml/scaler_params.json');

      if (await scalerFile.exists()) {
        return scalerFile.path;
      }
      return null;
    } catch (e) {
      debugPrint('ModelUpdater: Error getting scaler path: $e');
      return null;
    }
  }
}
