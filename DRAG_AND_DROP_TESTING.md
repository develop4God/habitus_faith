# Testing Guide: Drag-and-Drop Habit Reordering & UI Improvements

## Test Scenarios

### 1. Basic Drag-and-Drop
**Steps:**
1. Open the app with at least 3 pending habits
2. Long press on the second habit
3. Drag it above the first habit
4. Release

**Expected:**
- Habit moves smoothly to new position
- Order is persisted (survives app restart)
- No errors in console

### 2. Pending → Completed Movement (Check) - AUTO REORDER
**Steps:**
1. Have 3 pending habits and 2 completed habits
2. Check (tap checkbox) on a pending habit

**Expected:**
- ✅ **Habit AUTOMATICALLY moves from pending section to completed section**
- ✅ **Habit appears at bottom of list (completed section)**
- Visual feedback (strikethrough, color change)
- Maintains its relative order within completed section
- **No manual reorder needed - happens instantly**

### 3. Completed → Pending Movement (Uncheck) - AUTO REORDER
**Steps:**
1. Have 2 pending habits and 3 completed habits
2. Uncheck a completed habit

**Expected:**
- ✅ **Habit AUTOMATICALLY moves from completed section to pending section**
- ✅ **Habit appears in pending area (top of list)**
- Strikethrough removed
- Background color changes
- **No manual reorder needed - happens instantly**

### 4. Cross-Section Drag Prevention
**Steps:**
1. Have both pending and completed habits
2. Try to drag a pending habit to completed section
3. Try to drag a completed habit to pending section

**Expected:**
- Drag is prevented (won't allow drop)
- Habit returns to original position
- No errors

### 5. Reordering Within Completed Section
**Steps:**
1. Complete 3 habits
2. Long press on the last completed habit
3. Drag it above the first completed habit

**Expected:**
- Habit reorders within completed section
- Stays in completed section (doesn't move to pending)
- Order persists

### 6. Multiple Rapid Checks/Unchecks
**Steps:**
1. Rapidly check and uncheck the same habit 5 times

**Expected:**
- Habit moves smoothly between sections
- No race conditions or duplicate habits
- Final state matches checkbox state
- No console errors

### 7. Edge Case: Empty Sections
**Steps:**
1. Complete all habits (empty pending section)
2. Try to reorder completed habits
3. Uncheck all habits (empty completed section)
4. Try to reorder pending habits

**Expected:**
- Reordering works in both cases
- No crashes
- Sections appear/disappear gracefully

### 8. Persistence Test
**Steps:**
1. Reorder 5 habits manually
2. Check 2 of them
3. Close and restart the app

**Expected:**
- All habit positions are maintained
- Completed habits stay at bottom
- Pending habits maintain custom order

### 9. Edit Habit Dialog - Buttons on Top
**Steps:**
1. Tap on any habit to expand
2. Tap "Edit" button
3. Observe the dialog layout

**Expected:**
- ✅ **Cancel and Save buttons are at the TOP of the dialog**
- Save button has green background with check icon
- Save button shows "Save" text
- No duplicate buttons at the bottom
- Dialog is scrollable for long content

### 10. Edit Habit - Save Feedback
**Steps:**
1. Edit a habit (change name, add subtask, etc.)
2. Click the Save button
3. Observe the feedback

**Expected:**
- Loading indicator appears briefly
- Dialog closes
- ✅ **Snackbar appears with "Habit Edited ✓" message**
- Snackbar has green background with check icon
- Snackbar is floating style with rounded corners
- Changes are immediately visible in the list

### 11. Subtasks Display in Habit Card
**Steps:**
1. Create or edit a habit with 3 subtasks
2. Complete 1 out of 3 subtasks
3. View the habit in the main list

**Expected:**
- ✅ **Subtask summary shows "1/3 Subtasks"**
- Checklist icon appears next to subtask count
- Text is small and gray (unobtrusive)
- Subtask summary appears below the streak info
- Tapping the habit shows full subtask details

### 12. Subtasks Display - No Subtasks
**Steps:**
1. View a habit without any subtasks

**Expected:**
- No subtask summary line appears
- Card layout remains compact
- No visual clutter

### 13. Subtasks in Expanded View
**Steps:**
1. Create a habit with 5 subtasks
2. Complete 3 of them
3. Tap to expand the habit

**Expected:**
- All 5 subtasks are listed
- Completed subtasks have check icon and strikethrough
- Incomplete subtasks have empty circle icon
- Clear visual distinction between completed/incomplete

## Manual Verification Checklist

### Drag-and-Drop
- [ ] Long press on habit shows drag handle/visual feedback
- [ ] Dragging is smooth (60fps)
- [ ] Can't drag title ("Plan Your Day")
- [ ] Can't drag swipe hint at bottom
- [ ] Can't drag between pending/completed sections

### Auto-Reordering
- [ ] ✅ Checking a habit moves it to bottom instantly
- [ ] ✅ Unchecking a habit moves it to top instantly
- [ ] Completed habits have visual distinction (strikethrough, lighter color)
- [ ] Order survives app restart
- [ ] No flickering or glitches during reorder

### Edit Dialog
- [ ] ✅ Cancel and Save buttons are at the TOP
- [ ] Save button has green styling with check icon
- [ ] Loading indicator shows when saving
- [ ] ✅ Snackbar shows "Habit Edited ✓" with green background
- [ ] Dialog scrolls properly for long content
- [ ] No duplicate buttons at bottom

### Subtasks Display
- [ ] ✅ Subtasks show as "X/Y Subtasks" in compact card
- [ ] Checklist icon appears next to count
- [ ] Subtask line only shows when habit has subtasks
- [ ] Completed subtasks update the count immediately
- [ ] Tapping habit shows full subtask list in expanded view

### General
- [ ] Works with 1 habit
- [ ] Works with 20+ habits
- [ ] Scrolling works correctly during drag
- [ ] No duplicate habits appear
- [ ] Deleting a habit doesn't break order

## Performance Checks

- [ ] Reordering 20 habits is smooth
- [ ] No lag when checking/unchecking
- [ ] Stream updates don't cause flickering
- [ ] Batch updates happen efficiently

## Console Logs to Monitor

Look for these debug logs:
```
JsonHabitsRepository.reorderHabits: Reordering X habits
HabitsNotifier.reorderHabits: reordering X habits
HabitsNotifier.reorderHabits: éxito
```

## Known Limitations

1. **Title Element**: The "Plan Your Day" title is at index 0 and is not draggable
2. **Section Boundaries**: Cannot drag between pending/completed sections (by design)
3. **Swipe Hint**: Bottom hint is not draggable

## Debugging Tips

If drag-and-drop doesn't work:
1. Check that each habit has a unique `Key('habit_${habit.id}')`
2. Verify `order` field exists in stored habit data
3. Check console for reordering errors
4. Ensure ReorderableListView has proper itemCount

If habits don't move between sections:
1. Verify `dailyStatus` is updating correctly
2. Check sorting logic in UnifiedHabitList
3. Confirm stream is emitting updated habits

