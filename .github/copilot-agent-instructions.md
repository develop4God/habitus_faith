Must on each session.

1. Run `flutter test` before starting any tasks. All tests must pass. Refactor or fix failing tests. If a failing test does not validate real user logic, delete it and update your approach accordingly. 

2. Use `dart format .` and `dart analyze` frequently. Resolve all warnings and errors.

3. Only modify production code for requested features or bug fixes. Justify all major changes in commit messages and documentation.

4. Use Riverpod for all state and business logic. Use dependency injection and unique identifiers (IDs) for specific robo tests to facilitate easy testing.

5. For  code updates and new features you must include new tests. Acceptance tests criteria:
a. mimics real user journey.
b. include edge cases.
c. Tests must be dependency injection.
d. Tests should validate real user/business functionality and remain robust to code changes. Avoid fragile tests that break due to minor implementation changes.

6. Before finishing this session, compile the project with `flutter run` and wait for the APK to be generated.
