# Household Tasks Spinner Feature

## Overview
A modern, intuitive household task spinner feature that gamifies household chores and makes them fun and engaging. This feature adds a new "Household" category to the habit tracking system with a dedicated spinner interface.

## Features

### 1. New Household Category
- **Category Type**: `HabitCategory.household`
- **Icon**: 🏠 (home icon)
- **Color**: Orange (#FF9800)
- **Purpose**: Track and manage household tasks like cleaning, organizing, laundry, etc.

### 2. Modern Spinner Interface
The household spinner provides an engaging way to select which task to do next:

#### Key Components:
- **Animated Spinner Wheel**: 3-second spin animation with smooth rotation
- **Task Selection**: Randomly picks a household task from available tasks
- **Visual Feedback**: Modern gradient design with orange/deep-orange theme
- **Lottie Animations**: 
  - Hourglass timer during task execution
  - Celebration animation on completion

#### User Flow:
1. **View Available Tasks**: See all household tasks in a modern chip layout
2. **Spin**: Tap the "¡GIRAR!" button to spin for a random task
3. **Task Dialog**: Modal shows selected task with options:
   - "Otro momento" - Decline and return to spinner
   - "¡Vamos!" - Start the task
4. **Working View**: Shows hourglass animation with:
   - Task name and emoji
   - "Completar" button to mark done
   - "Cancelar" button to abandon task
5. **Celebration**: Success animation and completion message

### 3. Smart FAB Integration
The habits page now shows a dynamic floating action button setup:

- **Without household tasks**: Single purple "+" button for adding habits
- **With household tasks**: Two FABs stacked:
  - Orange spinner button (top) - Opens household spinner
  - Purple add button (bottom) - Add new habits

### 4. Predefined Household Habits
Five ready-to-use household task templates:

| Task | Emoji | Description |
|------|-------|-------------|
| Wash Dishes | 🍽️ | Clean dishes after meals |
| Clean Room | 🧹 | Tidy up and sweep/vacuum room |
| Do Laundry | 👕 | Wash, dry, and fold clothes |
| Organize Space | 📦 | Declutter and organize areas |
| Clean Bathroom | 🚿 | Clean toilet, sink, shower |

### 5. Modern UX Design
Following world-class app design principles:

#### Visual Design:
- **Gradient backgrounds** for depth
- **Smooth animations** for engagement
- **Modern shadows** for elevation
- **Rounded corners** (16-28px radius) for friendliness
- **Color consistency** with orange theme

#### User Experience:
- **Clear hierarchy**: Important actions prominently displayed
- **Immediate feedback**: Loading states and animations
- **Non-intrusive**: Easy to dismiss or cancel
- **Celebratory**: Positive reinforcement on completion
- **Accessible**: Large tap targets, clear labels

## Implementation Details

### Files Created:
1. `lib/features/habits/presentation/household_spinner/household_spinner_page.dart`
   - Main spinner page with animations and user flow
   - ~650 lines of modern Flutter UI

2. `test/widget/household_spinner_test.dart`
   - Comprehensive widget tests
   - Real user behavior validation
   - ~300 lines of test coverage

### Files Modified:
1. `lib/features/habits/domain/habit.dart`
   - Added `household` to `HabitCategory` enum
   
2. `lib/features/habits/presentation/constants/habit_colors.dart`
   - Added household color, icon, and display name
   
3. `lib/features/habits/presentation/ai_generator/generated_habits_page.dart`
   - Added household emoji and category name
   - Added household keywords for AI inference
   
4. `lib/features/habits/data/habit_model.dart`
   - Added household to migration map
   
5. `lib/core/services/ai/gemini_service.dart`
   - Added household category parsing
   
6. `lib/features/habits/domain/models/predefined_habit.dart`
   - Added household to PredefinedHabitCategory enum
   
7. `lib/features/habits/domain/models/predefined_habits_data.dart`
   - Added 5 household habit templates
   - Added household category mapping
   
8. `lib/widgets/add_habit_dialog.dart`
   - Added household category conversion
   
9. `lib/pages/habits_page.dart`
   - Added dynamic FAB with household spinner button

### Dependencies Used:
- `lottie: ^3.1.0` - For animations (already in pubspec.yaml)
- Existing assets:
  - `assets/lottie/sand_hourglass_pink.json` - Timer animation
  - `assets/lottie/Congratulation _ Success batch.json` - Celebration

## Testing

### Test Coverage:
The feature includes comprehensive tests validating real user behavior:

1. **View Tests**: Verify UI elements render correctly
2. **Empty State**: Handle no household tasks gracefully
3. **Spin Flow**: Test random task selection
4. **Task Decline**: Allow users to skip tasks
5. **Task Start**: Transition to working view
6. **Task Cancel**: Allow task abandonment
7. **Task Complete**: Full flow with celebration
8. **Task List**: Display all available tasks
9. **Visual Tests**: Verify modern design elements
10. **Integration**: End-to-end user journey

### Running Tests:
```bash
flutter test test/widget/household_spinner_test.dart
```

## Usage

### For Users:
1. **Add Household Tasks**:
   - Tap "+" button on habits page
   - Select "Predefined Habits" or "Custom"
   - Choose household category tasks

2. **Use the Spinner**:
   - Orange spinner FAB appears when household tasks exist
   - Tap to open spinner page
   - Spin to get a random task
   - Start or decline the task
   - Mark complete when done

3. **Track Progress**:
   - Completed tasks count toward streaks
   - View history in habit calendar
   - Build consistency over time

### For Developers:
```dart
// Navigate to household spinner
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const HouseholdSpinnerPage(),
  ),
);

// Check for household tasks
final hasHouseholdTasks = habits.any(
  (h) => h.category == HabitCategory.household,
);

// Filter household tasks
final householdTasks = habits
    .where((h) => h.category == HabitCategory.household)
    .toList();
```

## Future Enhancements (Optional)

### Customization:
- [ ] Custom Lottie animations per task
- [ ] Configurable spin duration
- [ ] Sound effects toggle
- [ ] Haptic feedback
- [ ] Task difficulty weighting in spin algorithm

### Features:
- [ ] Task history and analytics
- [ ] Streak bonuses for household category
- [ ] Family/roommate collaboration
- [ ] Task scheduling suggestions
- [ ] Photo proof of completion

### Gamification:
- [ ] Points system for household tasks
- [ ] Achievements/badges
- [ ] Leaderboards
- [ ] Task chains and combos
- [ ] Seasonal events

## Design Philosophy

This feature embodies modern app design principles:

1. **User-Centric**: Solves the "what chore should I do?" problem
2. **Delightful**: Makes mundane tasks fun with animations
3. **Intuitive**: Clear flow from spin to completion
4. **Rewarding**: Celebrates user accomplishments
5. **Flexible**: Easy to add more tasks or skip tasks
6. **Consistent**: Matches app's existing design language
7. **Performant**: Smooth animations and quick responses

## Technical Excellence

- **Type Safety**: Full Dart type checking
- **State Management**: Riverpod for reactive updates
- **Error Handling**: Graceful degradation and error states
- **Accessibility**: Semantic labels and large touch targets
- **Testing**: Comprehensive widget test coverage
- **Code Quality**: Clean architecture, documented code
- **Maintainability**: Modular design, easy to extend

---

**Created**: February 10, 2026  
**Status**: ✅ Complete and tested  
**Compatibility**: Flutter 3.x, Dart 3.x

