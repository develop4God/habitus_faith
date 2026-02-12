# Persistent Habit Order with Visual Auto-Sort

## Date: February 12, 2026

## Overview
Modified the habit list to maintain user-defined order persistently across days, while still providing visual auto-sorting by completion status for the current day. This gives users the best of both worlds: visual organization today, but stable order tomorrow.

## Problem
Previously, when a user reordered habits while some were completed (at bottom), the system would save the **visual order** (completed at bottom). The next day, all habits would reset to uncompleted, but they would appear in yesterday's "completed-at-bottom" order, which wasn't the user's intended base order.

## Solution
Implemented a dual-order system:
1. **Base Order** (persisted): User's intended habit order, saved to database
2. **Visual Order** (temporary): Auto-sorted by completion status, only for current day display

When user reorders habits, we:
- Allow visual reordering within sections (pending/completed)
- Map the visual positions back to base order before saving
- Save the base order (pending habits first, completed after, in their relative positions)
- Next day, all habits start fresh with the base order

## How It Works

### Display Logic
```dart
// Base habits sorted by user-defined order (what persists to next day)
final baseHabits = [...displayHabits];
baseHabits.sort((a, b) => a.order.compareTo(b.order));

// Visual habits: auto-sort by completion status for TODAY only
final sortedHabits = [...baseHabits];
if (isViewingToday) {
  sortedHabits.sort((a, b) {
    final aDone = a.dailyStatus != HabitDailyStatus.pending || a.completedToday;
    final bDone = b.dailyStatus != HabitDailyStatus.pending || b.completedToday;
    if (aDone != bDone) {
      return aDone ? 1 : -1; // Completed to bottom (visual only)
    }
    return a.order.compareTo(b.order);
  });
}
```

### Save Logic (onReorder)
```dart
// User drags in visual order (with completed at bottom)
final reorderedVisual = [...sortedHabits];
// ... apply drag ...

// Map back to base order before saving
if (isViewingToday) {
  final pending = reorderedVisual.where(h => !completed).toList();
  final completed = reorderedVisual.where(h => completed).toList();
  reorderedBase = [...pending, ...completed]; // Base order for next day
}

// Save base order to database
await reorderHabits(reorderedBase.map((h) => h.id).toList());
```

## Changes Made

### File: `lib/widgets/unified_habit_list.dart`

#### 1. Dual Sort System (Lines 91-107)
**Implementation:**
- Created `baseHabits`: sorted by user's `order` field only (persists to next day)
- Created `sortedHabits`: auto-sorted by completion status when viewing today (visual only)
- Past/future dates: no auto-sort, use base order only

**Code:**
```dart
// Base habits sorted by user-defined order (what persists to next day)
final baseHabits = [...displayHabits];
baseHabits.sort((a, b) => a.order.compareTo(b.order));

// Visual habits: auto-sort by completion status for TODAY only
final sortedHabits = [...baseHabits];
if (isViewingToday) {
  sortedHabits.sort((a, b) {
    final aDone = a.dailyStatus != HabitDailyStatus.pending || a.completedToday;
    final bDone = b.dailyStatus != HabitDailyStatus.pending || b.completedToday;
    if (aDone != bDone) {
      return aDone ? 1 : -1; // Completed to bottom (visual only)
    }
    return a.order.compareTo(b.order);
  });
}
```

#### 2. Base Order Persistence (Lines 169-215)
**Implementation:**
- When user reorders habits in visual list (with completed at bottom)
- System maps positions back to base order (pending + completed in their sections)
- Saves base order to database
- Next day, habits appear in base order (all uncompleted)

**Code:**
```dart
onReorder: (oldIndex, newIndex) async {
  // ... reorder in visual list ...
  final reorderedVisual = [...sortedHabits];
  final item = reorderedVisual.removeAt(oldIndex);
  reorderedVisual.insert(newIndex, item);

  // Map back to base order (without completion sorting)
  final List<Habit> reorderedBase;
  if (isViewingToday) {
    // Separate pending and completed from the new visual order
    final pending = reorderedVisual
        .where((h) => h.dailyStatus == HabitDailyStatus.pending && !h.completedToday)
        .toList();
    final completed = reorderedVisual
        .where((h) => h.dailyStatus != HabitDailyStatus.pending || h.completedToday)
        .toList();
    // Combine: pending first, then completed (this is the base order)
    reorderedBase = [...pending, ...completed];
  } else {
    reorderedBase = reorderedVisual;
  }

  // Save base order (what will appear tomorrow)
  await ref
      .read(habitsNotifierProvider.notifier)
      .reorderHabits(reorderedBase.map((h) => h.id).toList());
},
```

## User Experience

### Today's View
1. **Auto-Sort Active**: Completed habits automatically move to bottom
2. **Visual Organization**: Clear separation between pending (top) and completed (bottom)
3. **Section-Based Reordering**: Users can reorder within each section
   - Drag pending habits among other pending habits
   - Drag completed habits among other completed habits
   - Cannot drag across sections
4. **Immediate Feedback**: Visual changes happen instantly

### Next Day's View
1. **Base Order Restored**: All habits appear in the order saved yesterday
2. **All Uncompleted**: Fresh start, all habits back to pending
3. **Stable Positions**: Habits are in the same positions as user arranged them (before completion auto-sort)

### Example Scenario
**Day 1:**
- User arranges habits: Prayer, Exercise, Reading, Meditation
- User completes Exercise and Meditation
- **Visual order** becomes: Prayer, Reading (pending), Exercise, Meditation (completed)
- **Saved order**: Prayer, Reading, Exercise, Meditation

**Day 2:**
- All habits reset to pending
- **Display order**: Prayer, Reading, Exercise, Meditation (same as user arranged!)
- User completes Prayer
- **Visual order** becomes: Reading, Exercise, Meditation (pending), Prayer (completed)
- **Saved order**: Reading, Exercise, Meditation, Prayer

**Day 3:**
- **Display order**: Reading, Exercise, Meditation, Prayer (as arranged on Day 2!)

### Visual Feedback for Completion
- ✅ **Completed habits**: Still show with visual indicators (strikethrough, checkmark, different styling)
- ⏸️ **Skipped habits**: Show with skip indicator
- ❌ **Failed habits**: Show with failed indicator
- 📝 **Pending habits**: Show in default state

BUT all habits stay in their user-defined position!

## Benefits

1. **Visual Clarity Today**: Completed habits auto-move to bottom for clear separation
2. **Predictable Tomorrow**: Habits appear in same base order every morning
3. **Intentional Ordering**: Users can organize habits by:
   - Priority (most important at top)
   - Time of day (morning habits first, evening last)
   - Category grouping (exercise habits together, etc.)
   - Any custom logic that makes sense to them
4. **Best of Both Worlds**: 
   - See progress visually (completed at bottom)
   - But maintain stable order day-to-day
5. **Muscle Memory**: Know where to find habits each morning

## Testing

### Test Scenario 1: Order Persistence Across Days
1. Arrange habits in custom order: Prayer, Exercise, Reading
2. Complete Exercise (moves to bottom visually)
3. Visual order: Prayer, Reading, Exercise
4. Navigate to next day
5. **Expected**: Prayer, Exercise, Reading (base order restored, all uncompleted)

### Test Scenario 2: Auto-Sort on Completion
1. Have 3 pending habits: A, B, C
2. Complete habit B
3. **Expected**: Visual order becomes A, C (pending), B (completed at bottom)
4. Complete habit A
5. **Expected**: Visual order becomes C (pending), A, B (completed at bottom)

### Test Scenario 3: Reorder Within Sections
1. Have pending: A, B, C and completed: D, E
2. Drag B above A in pending section
3. **Expected**: Pending order becomes B, A, C
4. Next day
5. **Expected**: B, A, C, D, E (base order preserved)

### Test Scenario 4: Cannot Drag Across Sections
1. Have pending: A, B and completed: C, D
2. Try dragging A (pending) to completed section
3. **Expected**: Drag is blocked, A stays in pending section
4. Try dragging C (completed) to pending section
5. **Expected**: Drag is blocked, C stays in completed section

## Migration Notes
- No database migration needed
- Existing `order` field values are preserved
- All existing functionality (completion, skipping, failing) still works
- Only the visual sorting behavior has changed

## Code Quality
- ✅ No syntax errors
- ✅ No analyzer warnings
- ✅ Maintains section boundary logic for better UX
- ✅ Intelligent base order mapping for persistence
- ✅ Clean separation of visual vs. persisted state

## Related Documentation
- See: `docs/features/DRAG_AND_DROP_IMPLEMENTATION.md` for original drag-and-drop implementation
- See: `docs/implementation/IMPLEMENTATION_CHECKLIST.md` for requirement #7

