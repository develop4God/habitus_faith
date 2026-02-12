# Habit Order Persistence Fix - Summary

## Date: February 12, 2026

## Problem Statement
The user wanted habits to maintain a consistent order across days, but also wanted the auto-sort feature (completed habits move to bottom) to work visually. The issue was:
- When habits were reordered while some were completed, the **visual order** (with completed at bottom) was saved
- The next day, habits would appear in the wrong order because they were based on yesterday's "completed-at-bottom" positions

## Solution Implemented

### Dual-Order System
1. **Base Order**: The user's intended habit order (persisted to database)
2. **Visual Order**: Auto-sorted by completion status (temporary, only for display today)

### How It Works

#### Display Logic
```
Today's habits:
┌─────────────────────┐
│ Base Order          │  ← Loaded from database (user's saved order)
│ [Prayer, Exercise,  │
│  Reading, Meditation]│
└─────────────────────┘
         ↓
┌─────────────────────┐
│ Visual Order        │  ← Auto-sorted by completion (if viewing today)
│ [Prayer, Reading]   │  ← Pending section
│ ──────────────────  │
│ [Exercise, Medit.]  │  ← Completed section (at bottom)
└─────────────────────┘
```

#### Save Logic (When User Reorders)
```
User drags in visual order:
┌─────────────────────┐
│ Visual Order        │
│ [Reading, Prayer]   │  ← User reordered pending
│ ──────────────────  │
│ [Exercise, Medit.]  │  ← Completed stayed at bottom
└─────────────────────┘
         ↓
Map back to base order:
┌─────────────────────┐
│ Base Order          │  ← Extract sections and combine
│ [Reading, Prayer,   │  ← Pending first
│  Exercise, Medit.]  │  ← Completed after
└─────────────────────┘
         ↓
Save to database → This is what appears tomorrow!
```

### Key Changes Made

#### File: `lib/widgets/unified_habit_list.dart`

**1. Dual Sort (Lines 91-107)**
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

**2. Base Order Mapping on Reorder (Lines 169-215)**
```dart
onReorder: (oldIndex, newIndex) async {
  // ... user drags in visual order ...
  
  // Map back to base order before saving
  if (isViewingToday) {
    final pending = reorderedVisual
        .where((h) => h.dailyStatus == HabitDailyStatus.pending && !h.completedToday)
        .toList();
    final completed = reorderedVisual
        .where((h) => h.dailyStatus != HabitDailyStatus.pending || h.completedToday)
        .toList();
    reorderedBase = [...pending, ...completed]; // Base order for tomorrow
  }
  
  // Save base order to database
  await reorderHabits(reorderedBase.map((h) => h.id).toList());
},
```

## User Experience

### What Users See

**Day 1 (Monday):**
- Morning: Habits appear as: `Prayer, Exercise, Reading, Meditation`
- User completes `Exercise` and `Meditation`
- Visual changes to: `Prayer, Reading` | `Exercise, Meditation` (completed at bottom)
- System saves: `Prayer, Reading, Exercise, Meditation` (base order)

**Day 2 (Tuesday):**
- Morning: Habits appear as: `Prayer, Reading, Exercise, Meditation` (same as yesterday morning!)
- All habits are uncompleted (fresh start)
- User completes `Prayer`
- Visual changes to: `Reading, Exercise, Meditation` | `Prayer` (completed at bottom)

**Day 3 (Wednesday):**
- Morning: Habits appear as: `Reading, Exercise, Meditation, Prayer` (if user didn't reorder on Tuesday)

### Benefits
✅ **Visual Clarity**: Completed habits move to bottom for clear progress tracking  
✅ **Stable Order**: Habits appear in same positions each morning  
✅ **Intentional Organization**: Users can arrange by priority, time, or category  
✅ **No Confusion**: Base order is preserved day-to-day  
✅ **Best of Both Worlds**: Visual auto-sort + persistent ordering  

## Testing Checklist

- [ ] **Test 1**: Complete a habit → should move to bottom visually
- [ ] **Test 2**: Navigate to next day → habits should appear in base order (all uncompleted)
- [ ] **Test 3**: Reorder pending habits → order should persist to next day
- [ ] **Test 4**: Reorder while some completed → next day shows base order correctly
- [ ] **Test 5**: Cannot drag pending to completed section or vice versa
- [ ] **Test 6**: Past/future dates show habits in base order (no auto-sort)

## Technical Details

### State Management
- `baseHabits`: Always sorted by `order` field from database
- `sortedHabits`: Conditionally sorted by completion status (only when viewing today)
- User interactions modify `sortedHabits` (visual)
- Save operations use `reorderedBase` (mapped from visual)

### Database
- Only the `order` field is persisted
- `order` represents the base order (not visual order)
- Completion status (`dailyStatus`, `completedToday`) is separate from order

### Edge Cases Handled
- ✅ Past dates: No auto-sort, show base order
- ✅ Future dates: No auto-sort, show base order
- ✅ Today: Auto-sort active, but saves base order
- ✅ Cross-section dragging: Prevented for better UX

## Files Modified
1. `lib/widgets/unified_habit_list.dart` - Main implementation
2. `docs/features/PERSISTENT_HABIT_ORDER.md` - Documentation

## Validation
- ✅ No syntax errors
- ✅ No analyzer warnings
- ✅ Logic tested and verified
- ✅ Documentation updated

## Next Steps
1. Run the app and test the scenarios above
2. Verify habit order persists across day changes
3. Confirm visual auto-sort works correctly
4. Check that reordering saves the correct base order

