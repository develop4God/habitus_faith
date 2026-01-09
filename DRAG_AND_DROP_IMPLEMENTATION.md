# Drag-and-Drop Habit Reordering Implementation

## Overview
Implemented drag-and-drop functionality for reordering habits with automatic sorting:
- **Pending habits** (including skipped/failed) appear at the **top**
- **Completed habits** appear at the **bottom**
- Users can freely reorder habits **within their section** (pending or completed)
- When checking/unchecking a habit, it **automatically moves** between sections

## Changes Made

### 1. Domain Layer - Habit Model (`lib/features/habits/domain/habit.dart`)
- **Added `order` field** (int) to the Habit class for storing user-defined position
- Updated `copyWith` method to include order parameter
- Default value: `0`

### 2. Repository Interface (`lib/features/habits/domain/habits_repository.dart`)
- **Added `reorderHabits` method**: `Future<Result<void, HabitFailure>> reorderHabits(List<String> habitIds)`
- Takes a list of habit IDs in the desired order
- Updates the `order` field for each habit based on its position in the list

### 3. Data Layer

#### HabitModel (`lib/features/habits/data/habit_model.dart`)
- Added `order` field to `fromJson` deserialization (defaults to 0)
- Added `order` field to `toJson` serialization

#### JsonHabitsRepository (`lib/features/habits/data/storage/json_habits_repository.dart`)
- **Implemented `reorderHabits`**:
  - Creates a map for quick habit lookup
  - Updates each habit's order based on its position in the new list
  - Saves all updated habits
  - Emits updated habits stream

#### FirestoreHabitsRepository (`lib/features/habits/data/firestore_habits_repository.dart`)
- **Implemented `reorderHabits`**:
  - Uses batch write for efficient updates
  - Updates `order` field for all habits in one transaction

### 4. Presentation Layer

#### HabitsNotifier (`lib/features/habits/presentation/habits_providers.dart`)
- **Added `reorderHabits` method**:
  - Calls repository's reorderHabits
  - Updates AsyncNotifier state
  - Logs success/failure

#### UnifiedHabitList Widget (`lib/widgets/unified_habit_list.dart`)
- **Replaced `ListView`** with **`ReorderableListView.builder`**
- **Implemented automatic sorting**:
  ```dart
  sortedHabits.sort((a, b) {
    final aCompleted = a.dailyStatus == HabitDailyStatus.completed;
    final bCompleted = b.dailyStatus == HabitDailyStatus.completed;
    
    // Pending/skipped/failed first, completed last
    if (aCompleted != bCompleted) {
      return aCompleted ? 1 : -1;
    }
    
    // Within same section, sort by order
    return a.order.compareTo(b.order);
  });
  ```

- **Implemented `onReorder` callback**:
  - Adjusts indices to account for title element
  - **Prevents cross-section moves**: Users cannot drag pending habits to completed section or vice versa
  - Finds the boundary between pending and completed habits
  - Reorders habits within their section
  - Calls `reorderHabits` to persist changes

- **itemBuilder logic**:
  - Index 0: "Plan Your Day" title (non-draggable)
  - Indices 1 to N: Habit cards (draggable)
  - Last index: Swipe hint (non-draggable)

## User Experience

### Drag-and-Drop Behavior
1. **Long press** on any habit card to start dragging
2. **Drag up or down** to reorder within the same section
3. **Cannot cross boundaries**: Pending habits stay in pending section, completed stay in completed
4. **Visual feedback**: Cards animate smoothly during reordering
5. **Persistence**: Order is saved immediately when dropping

### Automatic Sorting
- **On check**: Habit moves from pending section → completed section (bottom)
- **On uncheck**: Habit moves from completed section → pending section (top)
- **Within section**: Habits maintain their custom order set by drag-and-drop

### Sections
- **Pending Section** (top):
  - Pending habits
  - Skipped habits
  - Failed habits
  - All sorted by `order` field
  
- **Completed Section** (bottom):
  - Completed habits
  - Sorted by `order` field

## Technical Details

### ReorderableListView.builder
- Uses `itemCount = sortedHabits.length + 2` (title + habits + swipe hint)
- Each item needs a unique `Key` for drag-and-drop to work
- Title and swipe hint use constant keys (not draggable)
- Habit cards use `Key('habit_${habit.id}')` (draggable)

### Index Adjustments
- Display indices include title offset
- Drag indices adjusted to skip title
- Logic prevents dragging title or swipe hint
- Boundary detection prevents cross-section moves

### Order Field
- Integer value representing position in list
- Lower values appear first
- Updated via batch when reordering
- Preserved when completing/uncompleting habits

## Migration Notes
- Existing habits without `order` field default to `0`
- No migration script needed - handled gracefully in deserialization
- First drag-and-drop will assign proper order values

## Future Enhancements
- Add visual separator between pending and completed sections
- Add section headers ("Pending", "Completed")
- Add haptic feedback during drag
- Add animations when habits move between sections on check/uncheck
- Consider adding "Collapse completed" option

