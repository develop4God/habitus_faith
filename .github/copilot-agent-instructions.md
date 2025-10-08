# Copilot Agent Instructions for Flutter/Dart

> **Copilot Agent: Confirm you have read this file at the start of every session.**

## Standards

- **Validate after each change:**  
  Run `flutter run` (or similar) and fix all compile errors before committing.

- **Test-driven development:**  
  Run `flutter test` before and during work. All tests must pass. Refactor/fix failing tests.

- **Formatting & analysis:**  
  Use `dart format .` and `dart analyze` frequently. Resolve all warnings/errors.

- **Production code:**  
  Only change production code for requested features or fixes. Justify all major changes in commits/docs.

## Architecture & Structure

- **State management:**  
  Use Riverpod for all state/business logic.

- **Folder tree:**  
  Organize by feature. Group related UI, providers, logic, and models:
  ```
  lib/
    features/
      auth/
        ui/
        providers/
        models/
      profile/
        ui/
        providers/
        models/
    shared/
      widgets/
      utils/
  ```
  Keep business logic out of UI. Refactor folder tree for clarity as needed.

## Testing Best Practices

- Write tests that validate real business logic and key flows—avoid trivial/meaningless tests.
- Design robust tests that aren't fragile to minor code changes.
- Use dependency injection for all external/services logic for testability.
- Assign unique `Key`s (like `ValueKey('loginButton')`) to interactive widgets for reliable UI/integration tests.
- Prefer meaningful widget/integration tests that simulate real user actions and verify outcomes.
- Use descriptive test names and clear structure (setup, action, assertions).
- Remove or refactor low-value/brittle tests.

## Workflow

1. Install: `flutter pub get`
2. Compile: `flutter run`
3. Test: `flutter test`
4. Format: `dart format .`
5. Analyze: `dart analyze`

## General

- Preserve and improve folder structure.
- Write unit tests for new logic or fixes.
- Document public APIs and complex logic.
- Update docs if usage or structure changes.

---

**Always follow these instructions for code quality and consistency. Confirm reading this file at each session start.**
