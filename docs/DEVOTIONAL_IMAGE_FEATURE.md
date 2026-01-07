# Devotional Background Image Feature

## Overview
This feature adds a beautiful blurred devotional image background to the daily progress card on the HomePage. The image is fetched from a GitHub repository and cached for the day to ensure consistency and reduce network requests.

## Architecture

### Components

#### 1. **DevotionalImageNormalizer** (`lib/core/services/images/devotional_image_normalizer.dart`)
- **Responsibility**: Normalizes image URLs for optimal size and format
- **Extensible**: Can be extended to support different CDN providers (Cloudinary, imgix, etc.)
- **Testable**: Pure function with no dependencies

```dart
String normalize(String url, {int width = 600, int height = 400});
```

#### 2. **DevotionalImageRepository** (`lib/core/services/images/devotional_image_repository.dart`)
- **Responsibility**: Fetches devotional images from GitHub repository
- **Dependencies**: 
  - `http.Client` (for HTTP requests)
  - `SharedPreferences` (for caching)
  - `DevotionalImageNormalizer` (for URL normalization)
- **Methods**:
  - `getRandomImageUrl()`: Returns a random image from the repository
  - `getImageForToday()`: Returns a cached image for the day (consistency)

#### 3. **Providers** (`lib/core/services/images/image_providers.dart`)
- **imageNormalizerProvider**: Provides the normalizer instance
- **devotionalImageRepositoryProvider**: Provides the repository with all dependencies injected
- **dailyDevotionalImageProvider**: FutureProvider that fetches the daily image

#### 4. **BackgroundImageCard** (`lib/widgets/background_image_card.dart`)
- **Responsibility**: Reusable widget that wraps content in a card with blurred background image
- **Features**:
  - Async image loading with loading/error states
  - Configurable blur strength, overlay opacity, border radius
  - Graceful fallback when image fails to load
  - Does not show background for placeholder URLs

### Dependency Injection

The implementation follows **Dependency Injection** principles using Riverpod:

1. **Services are injected via providers**:
   ```dart
   final devotionalImageRepositoryProvider = Provider<DevotionalImageRepository>((ref) {
     final normalizer = ref.watch(imageNormalizerProvider);
     final prefs = ref.watch(sharedPreferencesProvider);
     return DevotionalImageRepository(
       normalizer: normalizer,
       sharedPreferences: prefs,
     );
   });
   ```

2. **Constructor injection for testing**:
   ```dart
   DevotionalImageRepository({
     this.apiUrl = '...',
     DevotionalImageNormalizer? normalizer,
     http.Client? httpClient,
     this.sharedPreferences,
   })
   ```

3. **Easy mocking in tests**:
   ```dart
   final repository = DevotionalImageRepository(
     httpClient: mockHttpClient,
     normalizer: mockNormalizer,
     sharedPreferences: mockPrefs,
   );
   ```

## Usage

### In HomePage

```dart
// Import the widget
import '../widgets/background_image_card.dart';

// Use it instead of Card
BackgroundImageCard(
  borderSide: BorderSide(
    color: Colors.green.shade300,
    width: 2,
  ),
  child: Column(
    children: [
      // Your content here
    ],
  ),
)
```

### Custom Configuration

```dart
BackgroundImageCard(
  borderRadius: 30,              // Custom border radius
  padding: EdgeInsets.all(20),   // Custom padding
  blurSigma: 15,                 // Stronger blur
  overlayOpacity: 0.2,           // More opaque overlay
  child: YourWidget(),
)
```

## Testing

### Unit Tests

1. **DevotionalImageNormalizer** (`test/core/services/images/devotional_image_normalizer_test.dart`)
   - Tests URL normalization logic
   - Tests GitHub URL detection
   - Tests empty URL handling

2. **DevotionalImageRepository** (`test/core/services/images/devotional_image_repository_test.dart`)
   - Tests image fetching from GitHub API
   - Tests image filtering (jpg, png, avif, webp)
   - Tests caching logic
   - Tests error handling and fallbacks
   - Tests random selection
   - Uses mocked HTTP client and SharedPreferences

3. **BackgroundImageCard** (`test/widgets/background_image_card_test.dart`)
   - Tests widget rendering with different states (loading, success, error)
   - Tests placeholder URL handling
   - Tests custom properties (border, radius, etc.)

### Running Tests

```bash
# Run all image service tests
flutter test test/core/services/images/

# Run widget tests
flutter test test/widgets/background_image_card_test.dart

# Run all tests
flutter test
```

## Configuration

### Image Repository URL

The default GitHub repository is:
```
https://api.github.com/repos/develop4God/Devocionales-assets/contents/images
```

To use a different repository:

```dart
DevotionalImageRepository(
  apiUrl: 'https://api.github.com/repos/YOUR_USER/YOUR_REPO/contents/images',
)
```

### Supported Image Formats

- `.jpg` / `.jpeg`
- `.png`
- `.avif`
- `.webp`

### Caching Strategy

- Images are cached per day using the key format: `devocional_image_YYYY-MM-DD`
- Cache persists across app restarts
- New image is fetched daily at midnight

## Extensibility

### Adding CDN Support

To add support for a CDN like Cloudinary:

```dart
// In DevotionalImageNormalizer
String normalize(String url, {int width = 600, int height = 400}) {
  if (url.contains('cloudinary.com')) {
    return url.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill/',
    );
  }
  // ... existing logic
}
```

### Using with Other Widgets

The `BackgroundImageCard` is reusable anywhere:

```dart
BackgroundImageCard(
  child: YourCustomWidget(),
)
```

## Performance Considerations

1. **Image Caching**: Uses Flutter's built-in image caching via `Image.network`
2. **Daily Caching**: Reduces API calls to once per day
3. **Lazy Loading**: Image is only fetched when the widget is built
4. **Error Resilience**: Falls back to plain card if image fails to load

## Security

- Uses HTTPS for all image URLs
- Validates image file extensions
- Handles malformed responses gracefully

## Future Enhancements

- [ ] Add image preloading on app startup
- [ ] Add support for custom image playlists
- [ ] Add image animation transitions
- [ ] Add offline image bundling
- [ ] Add analytics for image loading performance

