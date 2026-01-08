import 'package:flutter/foundation.dart';

/// Service to normalize devotional image URLs for optimal size and format.
///
/// This service can be extended to support different CDN providers
/// or image transformation services in the future.
class DevotionalImageNormalizer {
  /// Normalizes the image URL for the requested size and format.
  ///
  /// If the backend/CDN supports query parameters for resizing,
  /// they will be added. Otherwise, the original URL is returned.
  ///
  /// [url] The original image URL
  /// [width] Desired width in pixels (default: 600)
  /// [height] Desired height in pixels (default: 400)
  String normalize(String url, {int width = 600, int height = 400}) {
    debugPrint('[ImageNormalizer] Received URL: $url');
    debugPrint('[ImageNormalizer] Requested size: ${width}x$height');

    if (url.isEmpty) {
      debugPrint('[ImageNormalizer] Empty URL, returning as-is');
      return url;
    }

    // GitHub raw content URLs don't support resizing
    if (url.contains('githubusercontent.com') || url.contains('github.com')) {
      debugPrint('[ImageNormalizer] GitHub URL detected - no resize support');
      return url;
    }

    // Future: Add support for other CDNs (Cloudinary, imgix, etc.)
    // Example for Cloudinary:
    // if (url.contains('cloudinary.com')) {
    //   return url.replaceFirst('/upload/', '/upload/w_$width,h_$height,c_fill/');
    // }

    debugPrint('[ImageNormalizer] Unknown provider, returning original URL');
    return url;
  }
}
