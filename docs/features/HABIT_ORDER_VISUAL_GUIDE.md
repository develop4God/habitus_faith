# Visual Explanation: Habit Order Persistence

## The Problem (Before Fix)

```
DAY 1 - Morning
┌─────────────────────────┐
│  Habits (Base Order)    │
│  1. Prayer              │
│  2. Exercise            │
│  3. Reading             │
│  4. Meditation          │
└─────────────────────────┘

DAY 1 - After Completing Exercise & Meditation
┌─────────────────────────┐
│  Visual Order           │
│  1. Prayer    ⬜        │  Pending
│  2. Reading   ⬜        │  Pending
│  ───────────────────    │
│  3. Exercise  ✅        │  Completed (moved to bottom)
│  4. Meditation ✅       │  Completed (moved to bottom)
└─────────────────────────┘
         ↓
    SAVED THIS ORDER!  ❌ WRONG!
    (Prayer, Reading, Exercise, Meditation)

DAY 2 - Morning (Problem!)
┌─────────────────────────┐
│  Habits (Wrong Order!)  │
│  1. Prayer    ⬜        │  ← Should be here ✓
│  2. Reading   ⬜        │  ← But Exercise should be here!
│  3. Exercise  ⬜        │  ← Wrong position
│  4. Meditation ⬜       │  ← Wrong position
└─────────────────────────┘
The order is based on yesterday's completed positions!
```

## The Solution (After Fix)

```
DAY 1 - Morning
┌─────────────────────────┐
│  Base Order (Database)  │
│  order: 0 - Prayer      │
│  order: 1 - Exercise    │
│  order: 2 - Reading     │
│  order: 3 - Meditation  │
└─────────────────────────┘
         ↓
┌─────────────────────────┐
│  Visual Display         │
│  1. Prayer              │
│  2. Exercise            │
│  3. Reading             │
│  4. Meditation          │
└─────────────────────────┘

DAY 1 - User Completes Exercise & Meditation
┌─────────────────────────┐
│  Visual Order (Auto)    │
│  1. Prayer    ⬜        │  Pending ← Auto-sorted to top
│  2. Reading   ⬜        │  Pending ← Auto-sorted to top
│  ───────────────────    │
│  3. Exercise  ✅        │  Completed ← Auto-sorted to bottom
│  4. Meditation ✅       │  Completed ← Auto-sorted to bottom
└─────────────────────────┘
         ↓
    When saving, map back to base order:
         ↓
┌─────────────────────────┐
│  Base Order (Saved)     │
│  order: 0 - Prayer      │  ← Pending section
│  order: 1 - Reading     │  ← Pending section
│  order: 2 - Exercise    │  ← Completed section
│  order: 3 - Meditation  │  ← Completed section
└─────────────────────────┘

DAY 2 - Morning (Correct!)
┌─────────────────────────┐
│  Base Order (Database)  │
│  order: 0 - Prayer      │
│  order: 1 - Reading     │  ← Still in base order
│  order: 2 - Exercise    │  ← Back to original position!
│  order: 3 - Meditation  │  ← Back to original position!
└─────────────────────────┘
         ↓
┌─────────────────────────┐
│  Visual Display         │
│  1. Prayer    ⬜        │  All uncompleted (fresh start)
│  2. Reading   ⬜        │
│  3. Exercise  ⬜        │  ← Correct position!
│  4. Meditation ⬜       │  ← Correct position!
└─────────────────────────┘
```

## Reordering Example

```
DAY 1 - User Reorders Pending Habits
┌─────────────────────────┐
│  Visual Order (Before)  │
│  1. Prayer    ⬜        │  Pending
│  2. Reading   ⬜        │  Pending
│  ───────────────────    │
│  3. Exercise  ✅        │  Completed
│  4. Meditation ✅       │  Completed
└─────────────────────────┘
         ↓
    User drags Reading above Prayer
         ↓
┌─────────────────────────┐
│  Visual Order (After)   │
│  1. Reading   ⬜        │  Pending (moved up)
│  2. Prayer    ⬜        │  Pending (moved down)
│  ───────────────────    │
│  3. Exercise  ✅        │  Completed (stayed)
│  4. Meditation ✅       │  Completed (stayed)
└─────────────────────────┘
         ↓
    Extract sections and combine:
         ↓
┌─────────────────────────┐
│  Base Order (Saved)     │
│  order: 0 - Reading     │  ← Pending section (new order)
│  order: 1 - Prayer      │  ← Pending section (new order)
│  order: 2 - Exercise    │  ← Completed section
│  order: 3 - Meditation  │  ← Completed section
└─────────────────────────┘

DAY 2 - Morning
┌─────────────────────────┐
│  Visual Display         │
│  1. Reading   ⬜        │  ← User's intended order preserved!
│  2. Prayer    ⬜        │  ← User's intended order preserved!
│  3. Exercise  ⬜        │
│  4. Meditation ⬜       │
└─────────────────────────┘
```

## Key Concepts

### Base Order
- **What**: User's intended habit order
- **When**: Persisted to database
- **Purpose**: Maintains stable order across days
- **Field**: `order` (0, 1, 2, 3...)

### Visual Order
- **What**: Auto-sorted by completion status
- **When**: Only when viewing today
- **Purpose**: Clear visual separation of completed/pending
- **How**: Pending at top, completed at bottom

### The Mapping
```
Visual Order              Base Order
(What user sees)          (What gets saved)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reading    ⬜ Pending  →  order: 0 - Reading
Prayer     ⬜ Pending  →  order: 1 - Prayer
────────────────────
Exercise   ✅ Complete →  order: 2 - Exercise
Meditation ✅ Complete →  order: 3 - Meditation
```

## Benefits

✅ **Today**: Visual clarity with auto-sort  
✅ **Tomorrow**: Stable, predictable order  
✅ **Forever**: User's intended organization persists  

