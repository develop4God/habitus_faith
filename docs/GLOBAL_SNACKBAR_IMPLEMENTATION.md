# Global Snackbar Implementation - Technical Documentation

## Overview
This document describes the implementation of a robust global snackbar system that properly handles displaying notifications after modal closures and async operations.

## Problem Statement
When showing snackbars after closing modals or performing async operations, the widget context can become unmounted, causing the error:
```
Unhandled Exception: This widget has been unmounted, so the State no longer has a context
```

## Solution Architecture

### 1. Global ScaffoldMessengerKey
Created a global key that provides access to the ScaffoldMessenger from anywhere in the app:

**File:** `lib/main.dart`
```dart
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
```

The key is registered in `MaterialApp`:
```dart
MaterialApp(
  scaffoldMessengerKey: rootScaffoldMessengerKey,
  // ... other properties
)
```

### 2. GlobalSnackbar Utility
Created a utility class that provides convenient methods for showing snackbars without needing a BuildContext:

**File:** `lib/core/utils/global_snackbar.dart`

#### Available Methods:
- `GlobalSnackbar.showSuccess(message)` - Green snackbar with checkmark icon
- `GlobalSnackbar.showError(message)` - Red snackbar with error icon  
- `GlobalSnackbar.showWarning(message)` - Orange snackbar with warning icon
- `GlobalSnackbar.showInfo(message)` - Blue snackbar with info icon
- `GlobalSnackbar.showCustom(...)` - Custom icon and color

#### Features:
- Consistent styling across the app (floating, rounded corners, 16px margins)
- Default 3-second duration (customizable)
- Icon + message layout with proper spacing
- No BuildContext required

### 3. Modal Close Timing
Implemented proper timing for modal closure before showing snackbars:

```dart
// Close the modal
Navigator.of(context).pop();

// Wait for modal animation to complete (250-300ms is typical)
await Future.delayed(const Duration(milliseconds: 300));

// Perform async operation
await widget.onDelete(habit.id);

// Show snackbar safely
GlobalSnackbar.showError(l10n.habitDeleted);
```

## Implementation Details

### Delete Habit Flow
1. Show confirmation dialog
2. If confirmed:
   - Check widget is still mounted
   - Pop the modal sheet
   - Wait 300ms for close animation
   - Perform deletion
   - Show error snackbar (red) using GlobalSnackbar

### Skip Habit Flow
1. Check widget is still mounted
2. Pop the modal sheet
3. Wait 300ms for close animation
4. Perform skip operation
5. Show warning snackbar (orange) using GlobalSnackbar

## Benefits

### 1. No Context Required
```dart
// Old way (can fail if widget is unmounted)
ScaffoldMessenger.of(context).showSnackBar(...);

// New way (always works)
GlobalSnackbar.showError(l10n.habitDeleted);
```

### 2. Consistent Styling
All snackbars automatically have:
- Floating behavior
- Rounded corners (12px radius)
- 16px margins
- Icon + message layout
- Appropriate colors per type

### 3. Type Safety
Different methods for different message types ensure correct icon and color:
```dart
GlobalSnackbar.showSuccess("Habit completed!");  // Green
GlobalSnackbar.showError("Habit deleted");       // Red
GlobalSnackbar.showWarning("Habit skipped");     // Orange
GlobalSnackbar.showInfo("Update available");     // Blue
```

### 4. Timing Control
Explicit delays ensure animations complete before showing feedback:
- Modal close: 300ms delay
- Prevents visual glitches
- Smooth user experience

## Usage Examples

### Basic Usage
```dart
// Success message
GlobalSnackbar.showSuccess("Changes saved!");

// Error message  
GlobalSnackbar.showError("Failed to save");

// Warning message
GlobalSnackbar.showWarning("Please check your input");

// Info message
GlobalSnackbar.showInfo("Version 2.0 available");
```

### Custom Duration
```dart
GlobalSnackbar.showSuccess(
  "Operation completed",
  duration: Duration(seconds: 5),
);
```

### Custom Snackbar
```dart
GlobalSnackbar.showCustom(
  message: "Custom notification",
  icon: Icons.star,
  backgroundColor: Colors.purple.shade600,
  duration: Duration(seconds: 4),
);
```

### After Async Operation
```dart
Future<void> deleteItem() async {
  // Close any modals
  Navigator.of(context).pop();
  
  // Wait for animation
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Perform operation
  await repository.delete(itemId);
  
  // Show feedback (no context needed!)
  GlobalSnackbar.showError("Item deleted");
}
```

## Testing Considerations

### Unit Tests
The GlobalSnackbar can be tested by:
1. Providing a mock GlobalKey in tests
2. Verifying the correct methods are called
3. Checking message content and styling

### Widget Tests
For widget tests:
```dart
testWidgets('shows snackbar after delete', (tester) async {
  // Setup MaterialApp with real scaffoldMessengerKey
  await tester.pumpWidget(
    MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: YourWidget(),
    ),
  );
  
  // Trigger delete
  await tester.tap(find.byIcon(Icons.delete));
  await tester.pumpAndSettle();
  
  // Verify snackbar appears
  expect(find.byType(SnackBar), findsOneWidget);
});
```

## Migration Guide

To migrate existing snackbar code:

### Before
```dart
if (context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check, color: Colors.white),
          SizedBox(width: 12),
          Text(message),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      // ... lots of styling code
    ),
  );
}
```

### After
```dart
GlobalSnackbar.showSuccess(message);
```

## Performance Considerations

- **Memory:** The global key adds minimal overhead (~40 bytes)
- **Timing:** 300ms delay is imperceptible to users but prevents visual glitches
- **UI Thread:** All operations are async and don't block the UI

## Future Enhancements

Potential improvements:
1. **Undo Actions:** Add action buttons to snackbars
   ```dart
   GlobalSnackbar.showWithAction(
     message: "Item deleted",
     actionLabel: "Undo",
     onAction: () => restore(item),
   );
   ```

2. **Queue Management:** Auto-queue multiple snackbars
3. **Priorities:** High-priority messages can interrupt lower ones
4. **Analytics:** Track which snackbars users see/interact with

## Troubleshooting

### Snackbar Not Showing
1. Verify `scaffoldMessengerKey` is set in MaterialApp
2. Check that `rootScaffoldMessengerKey` is imported correctly
3. Ensure the app has been built at least once

### Snackbar Appears Too Early
Increase the delay after modal closure:
```dart
await Future.delayed(const Duration(milliseconds: 400));
```

### Context Issues Persist
If using the old pattern, ensure migration to GlobalSnackbar is complete:
```bash
# Search for old pattern
grep -r "ScaffoldMessenger.of(context).showSnackBar" lib/
```

## Related Files

- `lib/main.dart` - Global key definition and registration
- `lib/core/utils/global_snackbar.dart` - Utility implementation
- `lib/widgets/unified_habit_card.dart` - Example usage in delete/skip flows

## Changelog

**2026-02-09:** Initial implementation
- Created global ScaffoldMessengerKey
- Implemented GlobalSnackbar utility
- Updated unified_habit_card delete and skip handlers
- Added 300ms delay for modal close animations
- Created comprehensive documentation

---

## Code Review Checklist

When reviewing snackbar implementations:
- [ ] Uses GlobalSnackbar instead of ScaffoldMessenger.of(context)
- [ ] Appropriate delay after modal closures (300ms minimum)
- [ ] Correct snackbar type (success/error/warning/info)
- [ ] Message is localized (uses l10n)
- [ ] No unnecessary context.mounted checks
- [ ] No try-catch blocks for showing snackbars (not needed with global key)

