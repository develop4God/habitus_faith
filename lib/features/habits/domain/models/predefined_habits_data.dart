import '../habit.dart';
import 'predefined_habit.dart';
import 'verse_reference.dart';

/// Centralized list of all predefined habits.
/// To add a new habit, simply append to this list.
final List<PredefinedHabit> predefinedHabits = [
  // ===== SPIRITUAL (4) =====
  const PredefinedHabit(
    id: 'morning_prayer',
    emoji: '🙏',
    nameKey: 'predefinedHabit_morningPrayer_name',
    descriptionKey: 'predefinedHabit_morningPrayer_description',
    category: PredefinedHabitCategory.spiritual,
    verse: VerseReference(book: 'Psalm', chapter: 5, verse: 3),
    suggestedTime: 'morning',
  ),
  const PredefinedHabit(
    id: 'bible_reading',
    emoji: '📖',
    nameKey: 'predefinedHabit_bibleReading_name',
    descriptionKey: 'predefinedHabit_bibleReading_description',
    category: PredefinedHabitCategory.spiritual,
    verse: VerseReference(book: 'Joshua', chapter: 1, verse: 8),
    suggestedTime: 'morning',
  ),
  const PredefinedHabit(
    id: 'worship',
    emoji: '🎵',
    nameKey: 'predefinedHabit_worship_name',
    descriptionKey: 'predefinedHabit_worship_description',
    category: PredefinedHabitCategory.spiritual,
    verse: VerseReference(book: 'Psalm', chapter: 95, verse: 1, endVerse: '2'),
    suggestedTime: 'anytime',
  ),
  const PredefinedHabit(
    id: 'gratitude',
    emoji: '✨',
    nameKey: 'predefinedHabit_gratitude_name',
    descriptionKey: 'predefinedHabit_gratitude_description',
    category: PredefinedHabitCategory.spiritual,
    verse: VerseReference(book: '1 Thessalonians', chapter: 5, verse: 18),
    suggestedTime: 'evening',
  ),

  // ===== PHYSICAL (3) =====
  const PredefinedHabit(
    id: 'exercise',
    emoji: '💪',
    nameKey: 'predefinedHabit_exercise_name',
    descriptionKey: 'predefinedHabit_exercise_description',
    category: PredefinedHabitCategory.physical,
    verse: VerseReference(
      book: '1 Corinthians',
      chapter: 6,
      verse: 19,
      endVerse: '20',
    ),
    suggestedTime: 'morning',
  ),
  const PredefinedHabit(
    id: 'healthy_eating',
    emoji: '🥗',
    nameKey: 'predefinedHabit_healthyEating_name',
    descriptionKey: 'predefinedHabit_healthyEating_description',
    category: PredefinedHabitCategory.physical,
    verse: VerseReference(book: '1 Corinthians', chapter: 10, verse: 31),
    suggestedTime: 'anytime',
  ),
  const PredefinedHabit(
    id: 'sleep',
    emoji: '😴',
    nameKey: 'predefinedHabit_sleep_name',
    descriptionKey: 'predefinedHabit_sleep_description',
    category: PredefinedHabitCategory.physical,
    verse: VerseReference(book: 'Psalm', chapter: 127, verse: 2),
    suggestedTime: 'evening',
  ),

  // ===== MENTAL (3) =====
  const PredefinedHabit(
    id: 'meditation',
    emoji: '🧘',
    nameKey: 'predefinedHabit_meditation_name',
    descriptionKey: 'predefinedHabit_meditation_description',
    category: PredefinedHabitCategory.mental,
    verse: VerseReference(book: 'Philippians', chapter: 4, verse: 8),
    suggestedTime: 'morning',
  ),
  const PredefinedHabit(
    id: 'learning',
    emoji: '📚',
    nameKey: 'predefinedHabit_learning_name',
    descriptionKey: 'predefinedHabit_learning_description',
    category: PredefinedHabitCategory.mental,
    verse: VerseReference(book: 'Proverbs', chapter: 18, verse: 15),
    suggestedTime: 'anytime',
  ),
  const PredefinedHabit(
    id: 'creativity',
    emoji: '🎨',
    nameKey: 'predefinedHabit_creativity_name',
    descriptionKey: 'predefinedHabit_creativity_description',
    category: PredefinedHabitCategory.mental,
    verse: VerseReference(
      book: 'Exodus',
      chapter: 35,
      verse: 31,
      endVerse: '32',
    ),
    suggestedTime: 'anytime',
  ),

  // ===== RELATIONAL (2) =====
  const PredefinedHabit(
    id: 'family_time',
    emoji: '👨‍👩‍👧‍👦',
    nameKey: 'predefinedHabit_familyTime_name',
    descriptionKey: 'predefinedHabit_familyTime_description',
    category: PredefinedHabitCategory.relational,
    verse: VerseReference(
      book: 'Ephesians',
      chapter: 6,
      verse: 2,
      endVerse: '3',
    ),
    suggestedTime: 'evening',
  ),
  const PredefinedHabit(
    id: 'service',
    emoji: '❤️',
    nameKey: 'predefinedHabit_service_name',
    descriptionKey: 'predefinedHabit_service_description',
    category: PredefinedHabitCategory.relational,
    verse: VerseReference(book: 'Galatians', chapter: 5, verse: 13),
    suggestedTime: 'anytime',
  ),
];

extension PredefinedHabitCategoryX on PredefinedHabitCategory {
  HabitCategory toDomainCategory() {
    switch (this) {
      case PredefinedHabitCategory.spiritual:
        return HabitCategory.spiritual;
      case PredefinedHabitCategory.physical:
        return HabitCategory.physical;
      case PredefinedHabitCategory.mental:
        return HabitCategory.mental;
      case PredefinedHabitCategory.relational:
        return HabitCategory.relational;
    }
  }
}
