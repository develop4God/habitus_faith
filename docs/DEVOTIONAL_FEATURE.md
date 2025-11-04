# Devotional Discovery Feature

## Overview
The Devotional Discovery feature allows users to browse, search, and read daily devotionals with Bible verse integration.

## Features

### 1. Devotional Browsing
- Browse devotionals organized by date
- Search across devotional content (reflection, verses, prayers)
- Multi-language support (Spanish, English, Portuguese, French)
- Multi-version Bible support per language

### 2. Favorites System
- Mark devotionals as favorites with a heart icon
- Access favorite devotionals easily
- Favorites are persisted locally

### 3. Verse-First Reading
Each devotional includes:
- **Bible Verse Reference** - The main scripture for meditation
- **"Read Verse First" Button** - Opens the Bible reader to the referenced verse
- **Reflection** - Devotional reflection text
- **Meditation Points** - Additional scriptures and thoughts
- **Prayer** - Closing prayer

### 4. Detail View
Tap any devotional card to open a full-screen detail view with:
- Complete devotional content
- Formatted meditation points with scripture references
- Highlighted prayer section
- Quick access to Bible verse

## Architecture

### State Management
Uses **Riverpod** for clean, testable state management:
- `DevotionalState` - Immutable state class
- `DevotionalNotifier` - State controller
- `devotionalProvider` - Global provider

### Data Models
- `Devocional` - Main devotional model
- `ParaMeditar` - Meditation point model

### API Integration
Devotionals are fetched from GitHub repository:
- Format: `Devocional_year_{year}_{language}_{version}.json`
- Backward compatible with Spanish RVR1960
- Automatic language detection based on device locale

## Usage

### Accessing Devotionals
1. Open the app
2. Tap the "Devotionals" tab in the bottom navigation
3. Browse or search for devotionals

### Reading a Devotional
1. Tap on any devotional card
2. Read the verse reference
3. Optionally tap "Read Verse First" to view in Bible reader
4. Read the reflection and meditation points
5. Conclude with the prayer

### Managing Favorites
- Tap the heart icon on any devotional card to add/remove favorites
- Favorite status is preserved across app restarts

### Changing Language
1. Tap the language icon in the app bar
2. Select your preferred language
3. Devotionals will reload in the selected language

## Configuration

### Supported Languages & Versions

#### Spanish (es)
- RVR1960 (default)
- NVI

#### English (en)
- KJV (default)
- NIV

#### Portuguese (pt)
- ARC (default)
- NVI

#### French (fr)
- LSG1910 (default)
- TOB

### API Endpoints
Configured in `lib/core/config/devotional_constants.dart`:
```dart
DevotionalConstants.getDevocionalesApiUrlMultilingual(year, language, version)
```

## Testing

### Unit Tests
Located in `test/providers/devotional_providers_test.dart`:
- State management tests
- Model serialization tests
- Filter and search tests
- Favorites management tests

Run tests:
```bash
flutter test test/providers/devotional_providers_test.dart
```

## Future Enhancements

### Planned
- [ ] Verse parsing for direct Bible navigation from devotional
- [ ] Offline mode with cached devotionals
- [ ] Share devotional content
- [ ] Daily notifications for new devotionals
- [ ] Reading history tracking
- [ ] Bookmarking specific devotionals

### Localization
- [ ] Add translations for all UI strings
- [ ] Support for more languages

## Integration with Bible Reader

The devotional feature is designed to work seamlessly with the existing Bible reader:
1. User selects a devotional
2. Taps "Read Verse First"
3. Bible reader opens (implementation can be enhanced to navigate to specific verse)
4. User returns to complete reading the devotional

## Developer Notes

### Adding New Languages
1. Update `DevotionalConstants.supportedLanguages`
2. Add versions in `DevotionalConstants.bibleVersionsByLanguage`
3. Set default version in `DevotionalConstants.defaultVersionByLanguage`
4. Ensure API has corresponding JSON files

### Modifying UI
The main UI component is in `lib/pages/devotional_discovery_page.dart`:
- `_buildDevocionalCard()` - Card design
- `_buildDevocionalDetailContent()` - Detail view
- Customize styling using Material 3 ColorScheme

### State Updates
Modify `lib/providers/devotional_providers.dart`:
- Add new state properties to `DevotionalState`
- Implement new methods in `DevotionalNotifier`
- Update tests accordingly

---

*Last updated: 2025-11-04*
