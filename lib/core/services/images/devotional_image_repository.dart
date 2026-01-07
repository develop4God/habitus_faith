import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'devotional_image_normalizer.dart';

/// Repository for fetching devotional images from GitHub repository.
///
/// This service abstracts the image fetching logic and provides
/// methods for getting random images or cached daily images.
class DevotionalImageRepository {
  final String apiUrl;
  final DevotionalImageNormalizer normalizer;
  final http.Client httpClient;
  final SharedPreferences? sharedPreferences;

  DevotionalImageRepository({
    this.apiUrl =
        'https://api.github.com/repos/develop4God/Devocionales-assets/contents/images/habitus',
    DevotionalImageNormalizer? normalizer,
    http.Client? httpClient,
    this.sharedPreferences,
  })  : normalizer = normalizer ?? DevotionalImageNormalizer(),
        httpClient = httpClient ?? http.Client();

  /// Fetches a random image URL from the repository.
  ///
  /// [width] Desired image width (default: 600)
  /// [height] Desired image height (default: 400)
  ///
  /// Returns a normalized image URL or a placeholder if fetching fails.
  Future<String> getRandomImageUrl({int width = 600, int height = 400}) async {
    debugPrint('[ImageRepository] Fetching images from GitHub');
    List<String> imageUrls = [];

    try {
      final response = await httpClient.get(Uri.parse(apiUrl));
      debugPrint('[ImageRepository] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        debugPrint('[ImageRepository] Files received: ${files.length}');

        imageUrls = files
            .where((file) =>
                file['type'] == 'file' &&
                _isImageFile(file['name'] as String))
            .map<String>((file) => file['download_url'] as String)
            .toList();

        debugPrint('[ImageRepository] Filtered images: ${imageUrls.length}');

        if (imageUrls.isNotEmpty) {
          final random = Random();
          final selected = imageUrls[random.nextInt(imageUrls.length)];
          debugPrint('[ImageRepository] Selected image: $selected');

          final normalized =
              normalizer.normalize(selected, width: width, height: height);
          debugPrint('[ImageRepository] Normalized image: $normalized');
          return normalized;
        } else {
          debugPrint('[ImageRepository] No valid images found in GitHub.');
        }
      } else {
        debugPrint('[ImageRepository] HTTP error: ${response.body}');
      }
    } catch (e) {
      debugPrint('[ImageRepository] Error fetching images: $e');
    }

    // Fallback to placeholder
    debugPrint('[ImageRepository] Using placeholder');
    return 'https://via.placeholder.com/${width}x$height?text=Devocional';
  }

  /// Gets the image for today, caching it for consistency.
  ///
  /// This ensures the same image is shown throughout the day.
  ///
  /// Returns a normalized image URL or a placeholder if fetching fails.
  Future<String> getImageForToday({int width = 600, int height = 400}) async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    final todayKey =
        'devocional_image_${DateTime.now().toIso8601String().substring(0, 10)}';
    final savedUrl = prefs.getString(todayKey);

    debugPrint('[ImageRepository] Cached image for today: $savedUrl');

    // Validate cached URL exists and is not default
    if (savedUrl != null &&
        !savedUrl.contains('placeholder') &&
        !savedUrl.contains('devocional_default.jpg')) {
      debugPrint('[ImageRepository] Using valid cached image: $savedUrl');
      return savedUrl;
    }

    debugPrint('[ImageRepository] Fetching new image for today');

    try {
      final response = await httpClient.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        final imageUrls = files
            .where((file) =>
                file['type'] == 'file' &&
                _isImageFile(file['name'] as String))
            .map<String>((file) => file['download_url'] as String)
            .toList();

        if (imageUrls.isNotEmpty) {
          final random = Random();
          final selected = imageUrls[random.nextInt(imageUrls.length)];
          final normalized =
              normalizer.normalize(selected, width: width, height: height);

          await prefs.setString(todayKey, normalized);
          debugPrint('[ImageRepository] Image for today saved: $normalized');
          return normalized;
        }
      }
    } catch (e) {
      debugPrint('[ImageRepository] Error fetching image for today: $e');
    }

    debugPrint('[ImageRepository] Using placeholder for today');
    return 'https://via.placeholder.com/${width}x$height?text=Devocional';
  }

  /// Checks if a filename is a supported image format.
  bool _isImageFile(String filename) {
    final lowercaseName = filename.toLowerCase();
    return lowercaseName.endsWith('.jpg') ||
        lowercaseName.endsWith('.jpeg') ||
        lowercaseName.endsWith('.png') ||
        lowercaseName.endsWith('.avif') ||
        lowercaseName.endsWith('.webp');
  }
}
