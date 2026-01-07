# Quick Start: Devotional Background Image Feature

## For Developers

### 🚀 Usage in 30 seconds

Replace any `Card` widget with `BackgroundImageCard`:

```dart
// Before
Card(
  child: YourContent(),
)

// After
BackgroundImageCard(
  child: YourContent(),
)
```

That's it! The widget handles everything automatically.

### 🎨 Customization Examples

#### Custom border and style
```dart
BackgroundImageCard(
  borderSide: BorderSide(color: Colors.blue, width: 2),
  borderRadius: 30,
  child: YourContent(),
)
```

#### Stronger blur effect
```dart
BackgroundImageCard(
  blurSigma: 20,          // Default: 10
  overlayOpacity: 0.3,    // Default: 0.15
  child: YourContent(),
)
```

#### Custom padding
```dart
BackgroundImageCard(
  padding: EdgeInsets.all(40),
  child: YourContent(),
)
```

### 🧪 Testing Your Code

```dart
testWidgets('my widget test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override the image provider for testing
        dailyDevotionalImageProvider.overrideWith(
          (ref) async => 'https://example.com/test.jpg',
        ),
      ],
      child: MaterialApp(
        home: YourWidget(),
      ),
    ),
  );
});
```

### 📝 Example: Full Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/background_image_card.dart';

class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: BackgroundImageCard(
          borderSide: BorderSide(
            color: Colors.green.shade300,
            width: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 48),
              SizedBox(height: 16),
              Text(
                'My Content',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 🔧 Advanced: Using the Repository Directly

If you need to fetch images programmatically:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the repository
    final imageRepo = ref.watch(devotionalImageRepositoryProvider);
    
    return FutureBuilder<String>(
      future: imageRepo.getRandomImageUrl(width: 800, height: 600),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(snapshot.data!);
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### 📚 API Reference

#### BackgroundImageCard Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | Content to display in the card |
| `borderRadius` | `double` | `22` | Corner radius |
| `padding` | `EdgeInsets` | `EdgeInsets.all(26)` | Internal padding |
| `backgroundColor` | `Color` | `Colors.white` | Card background color |
| `borderSide` | `BorderSide?` | `null` | Border styling |
| `elevation` | `double` | `2` | Shadow elevation |
| `blurSigma` | `double` | `10` | Blur intensity |
| `overlayOpacity` | `double` | `0.15` | Overlay transparency |

#### Repository Methods

```dart
// Get random image
Future<String> getRandomImageUrl({int width = 600, int height = 400})

// Get today's cached image
Future<String> getImageForToday({int width = 600, int height = 400})
```

### 🐛 Troubleshooting

#### Image not showing?
1. Check network connectivity
2. Check if GitHub API is accessible
3. Look for debug logs: `[ImageRepository]` prefix

#### Placeholder showing instead of image?
- The widget automatically hides background for placeholder URLs
- Check if the GitHub repository has valid images

#### Want to disable background temporarily?
```dart
// Just use a regular Card instead
Card(child: YourContent())
```

### 💡 Tips

1. **Performance**: Images are cached automatically by Flutter
2. **Consistency**: Daily images persist throughout the day
3. **Fallback**: Widget gracefully handles errors (shows plain card)
4. **Testing**: Always override the provider in tests for predictable results

---

Need help? Check:
- `docs/DEVOTIONAL_IMAGE_FEATURE.md` - Full documentation
- `docs/IMPLEMENTATION_SUMMARY_BACKGROUND_IMAGE.md` - Implementation details
- `test/widgets/background_image_card_test.dart` - Usage examples

