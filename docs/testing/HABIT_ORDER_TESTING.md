# Testing Guide: Habit Order Persistence

## Quick Test Scenarios

### Test 1: Basic Auto-Sort ✅
**Steps:**
1. Launch app with 4 habits: A, B, C, D (all pending)
2. Complete habit B
3. **Expected**: Visual order becomes A, C, D (pending) | B (completed at bottom)

**Validates:** Auto-sort is working

---

### Test 2: Order Persistence Across Days ✅
**Steps:**
1. Start with habits in order: Prayer, Exercise, Reading
2. Complete Exercise (visual becomes: Prayer, Reading | Exercise)
3. Wait until next day OR manually change device date
4. **Expected**: Habits appear as Prayer, Reading, Exercise (all uncompleted)

**Validates:** Base order persists, not visual order

---

### Test 3: Reorder Pending Habits ✅
**Steps:**
1. Have pending: A, B, C and completed: D, E
2. Drag B above A in pending section
3. Visual becomes: B, A, C (pending) | D, E (completed)
4. Navigate to next day
5. **Expected**: Habits appear as B, A, C, D, E

**Validates:** Reordering within section saves correctly

---

### Test 4: Cannot Cross Sections ✅
**Steps:**
1. Have pending: A, B and completed: C, D
2. Try dragging A (pending) down to completed section
3. **Expected**: Drag is blocked/prevented
4. Try dragging C (completed) up to pending section
5. **Expected**: Drag is blocked/prevented

**Validates:** Section boundaries are enforced

---

### Test 5: Multiple Completions ✅
**Steps:**
1. Start with: A, B, C, D (all pending)
2. Complete B (visual: A, C, D | B)
3. Complete D (visual: A, C | B, D)
4. Complete A (visual: C | A, B, D)
5. Next day
6. **Expected**: C, A, B, D (base order preserved)

**Validates:** Multiple state changes don't corrupt order

---

### Test 6: Past Date View ✅
**Steps:**
1. Today: Have habits A, B, C with B completed
2. Navigate to yesterday's date
3. **Expected**: Habits show in base order (A, B, C) with yesterday's completion status
4. No auto-sort (completed habits don't move to bottom)

**Validates:** Auto-sort only applies to today

---

### Test 7: Reorder Then Complete ✅
**Steps:**
1. Start with: A, B, C (all pending)
2. Drag C to top: C, A, B
3. Complete A (visual: C, B | A)
4. Next day
5. **Expected**: C, B, A (reorder was saved correctly)

**Validates:** Reorder + completion combo works

---

### Test 8: Complete Then Reorder ✅
**Steps:**
1. Start with: A, B, C, D (all pending)
2. Complete B and D (visual: A, C | B, D)
3. Drag C above A in pending section (visual: C, A | B, D)
4. Next day
5. **Expected**: C, A, B, D

**Validates:** Reordering after completion maps correctly

---

## How to Test

### Manual Testing
```bash
# Run the app
flutter run

# Navigate to Habits page
# Test scenarios above
```

### Debug Logging
Look for these debug messages:
```
🗓️ UnifiedHabitList: today=..., viewingDate=..., isViewingToday=...
HabitsNotifier.reorderHabits: reordering X habits
JsonHabitsRepository.reorderHabits: Saving X habits total
```

### What to Check
- ✅ Visual order changes when habits are completed
- ✅ Base order persists to next day
- ✅ Reordering saves the correct base order
- ✅ Section boundaries prevent invalid drags
- ✅ Past/future dates don't auto-sort

## Expected Behavior Summary

| Action | Visual Order (Today) | Saved Order (Database) | Tomorrow's Display |
|--------|---------------------|------------------------|-------------------|
| Complete habit B | A, C | A, C, B | A, C, B (all pending) |
| Reorder: drag B above A | B, A, C | B, A, C | B, A, C |
| Complete B, then reorder A & C | C, A | C, A, B | C, A, B (all pending) |

## Common Issues

### Issue: Habits appear in wrong order next day
**Cause:** Visual order was saved instead of base order  
**Check:** Verify `reorderedBase` mapping is working in `onReorder`

### Issue: Can't drag habits
**Cause:** Section boundary logic too restrictive  
**Check:** Ensure `isViewingToday` check is correct

### Issue: Completed habits don't move to bottom
**Cause:** Auto-sort not working  
**Check:** Verify `sortedHabits` sorting logic when `isViewingToday`

## Success Criteria

✅ Completed habits move to bottom (visual)  
✅ Next day, habits appear in base order  
✅ Reordering within sections works  
✅ Cannot drag across sections  
✅ Past/future dates show base order  
✅ No crashes or errors  

