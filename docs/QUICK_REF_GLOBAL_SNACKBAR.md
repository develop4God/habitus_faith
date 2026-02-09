# Quick Reference: GlobalSnackbar Usage

## Import
```dart
import 'package:habitus_faith/core/utils/global_snackbar.dart';
```

## API Reference

### Success (Green)
```dart
GlobalSnackbar.showSuccess("Habit completed!");
```
- Icon: ✓ check_circle_outline
- Color: Green (#43A047)
- Use for: Completed actions, saved changes

### Error (Red)
```dart
GlobalSnackbar.showError("Habit deleted");
```
- Icon: ⚠ error_outline
- Color: Red (#E53935)
- Use for: Deletions, failures, critical messages

### Warning (Orange)
```dart
GlobalSnackbar.showWarning("Habit skipped");
```
- Icon: ⚠ warning_amber_outlined
- Color: Orange (#FB8C00)
- Use for: Skips, cautionary messages, reversible actions

### Info (Blue)
```dart
GlobalSnackbar.showInfo("Update available");
```
- Icon: ℹ info_outline
- Color: Blue (#1E88E5)
- Use for: Information, tips, updates

### Custom
```dart
GlobalSnackbar.showCustom(
  message: "Custom message",
  icon: Icons.star,
  backgroundColor: Colors.purple.shade600,
  duration: Duration(seconds: 5),
);
```

## Common Patterns

### After Modal Close
```dart
// 1. Close modal
Navigator.of(context).pop();

// 2. Wait for animation (300ms)
await Future.delayed(const Duration(milliseconds: 300));

// 3. Do work
await doSomething();

// 4. Show feedback
GlobalSnackbar.showSuccess("Done!");
```

### After Async Operation
```dart
try {
  await repository.save(data);
  GlobalSnackbar.showSuccess("Saved!");
} catch (e) {
  GlobalSnackbar.showError("Failed to save");
}
```

### With Custom Duration
```dart
GlobalSnackbar.showInfo(
  "Long message that needs more time",
  duration: Duration(seconds: 5),
);
```

## Do's and Don'ts

### ✅ DO
- Use GlobalSnackbar for all app-wide notifications
- Choose appropriate type (success/error/warning/info)
- Keep messages concise (< 50 characters)
- Use localization (l10n)
- Wait for animations before showing

### ❌ DON'T
- Use ScaffoldMessenger.of(context) directly
- Show snackbars during animations
- Chain multiple snackbars rapidly
- Use for critical errors (use dialogs instead)
- Forget to localize messages

## Examples from Codebase

### Delete Habit
```dart
GlobalSnackbar.showError(l10n.habitDeleted);
```

### Skip Habit
```dart
GlobalSnackbar.showWarning(l10n.habitSkipped);
```

### Complete Habit
```dart
GlobalSnackbar.showSuccess(l10n.habitCompleted);
```

### Network Error
```dart
GlobalSnackbar.showError(l10n.networkError);
```

## Timing Guidelines

| Action | Delay | Reason |
|--------|-------|--------|
| After modal close | 300ms | Animation completion |
| After page navigation | 200ms | Route transition |
| After dialog dismiss | 250ms | Fade-out animation |
| Immediate feedback | 0ms | User tapped button |

## Accessibility

All snackbars automatically support:
- ✅ Screen reader announcements
- ✅ Semantic labels
- ✅ High contrast mode
- ✅ Large text scaling

## Testing

```dart
testWidgets('shows success snackbar', (tester) async {
  // Trigger action
  GlobalSnackbar.showSuccess("Test message");
  await tester.pump();
  
  // Verify
  expect(find.text("Test message"), findsOneWidget);
  expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
});
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Snackbar not showing | Verify scaffoldMessengerKey in MaterialApp |
| Shows too early | Add delay after modal/navigation |
| Wrong color | Use correct method (success/error/warning/info) |
| Not localized | Use l10n instead of hardcoded strings |

---

**Last Updated:** February 9, 2026  
**Version:** 1.0.0  
**Maintainer:** Development Team

