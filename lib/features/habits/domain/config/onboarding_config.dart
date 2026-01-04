/// Configuration constants for onboarding flow
class OnboardingConfig {
  // Timing
  static const autoAdvanceDelay = Duration(milliseconds: 300);
  static const loadingDialogDelay = Duration(milliseconds: 800);

  // Constraints
  static const maxGoals = 3;
  static const minHabits = 1;

  // Score thresholds
  static const scoreAdvancedThreshold = 10;
  static const scoreIntermediateThreshold = 7;
}
