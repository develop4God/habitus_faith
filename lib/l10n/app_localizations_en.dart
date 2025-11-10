// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habitus Faith';

  @override
  String get start => 'Start';

  @override
  String get readBible => 'Read Bible';

  @override
  String get myHabits => 'My Habits';

  @override
  String get noHabits => 'No habits yet';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'days';

  @override
  String get best => 'Best';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String deleteHabitConfirm(String habitName) {
    return 'Are you sure you want to delete \"$habitName\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get add => 'Add';

  @override
  String get welcomeToHabitusFaith => 'Welcome to Habitus Faith';

  @override
  String get selectUpToThreeHabits =>
      'Select up to 3 habits to start your journey';

  @override
  String get continueButton => 'Continue';

  @override
  String get selectAtLeastOne => 'Please select at least one habit';

  @override
  String get maxThreeHabits => 'You can select up to 3 habits';

  @override
  String get spiritual => 'Spiritual';

  @override
  String get physical => 'Physical';

  @override
  String get mental => 'Mental';

  @override
  String get relational => 'Relational';

  @override
  String get habitCompleted => 'Habit completed! 🎉';

  @override
  String get tapToComplete => 'Tap to complete';

  @override
  String get completed => 'Completed';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get thisWeek => 'This Week';

  @override
  String get predefinedHabit_morningPrayer_name => 'Morning Prayer';

  @override
  String get predefinedHabit_morningPrayer_description =>
      'Start your day with prayer and thanksgiving';

  @override
  String get predefinedHabit_bibleReading_name => 'Bible Reading';

  @override
  String get predefinedHabit_bibleReading_description =>
      'Read and meditate on God\'s Word daily';

  @override
  String get predefinedHabit_worship_name => 'Worship';

  @override
  String get predefinedHabit_worship_description =>
      'Spend time in worship and praise';

  @override
  String get predefinedHabit_gratitude_name => 'Gratitude Journal';

  @override
  String get predefinedHabit_gratitude_description =>
      'Write down what you\'re thankful for';

  @override
  String get predefinedHabit_exercise_name => 'Exercise';

  @override
  String get predefinedHabit_exercise_description =>
      'Take care of your body, God\'s temple';

  @override
  String get predefinedHabit_healthyEating_name => 'Healthy Eating';

  @override
  String get predefinedHabit_healthyEating_description =>
      'Nourish your body with wholesome food';

  @override
  String get predefinedHabit_sleep_name => 'Quality Sleep';

  @override
  String get predefinedHabit_sleep_description =>
      'Get restful sleep to recharge';

  @override
  String get predefinedHabit_meditation_name => 'Meditation';

  @override
  String get predefinedHabit_meditation_description =>
      'Practice mindfulness and reflection';

  @override
  String get predefinedHabit_learning_name => 'Learning';

  @override
  String get predefinedHabit_learning_description =>
      'Grow in knowledge and wisdom';

  @override
  String get predefinedHabit_creativity_name => 'Creative Time';

  @override
  String get predefinedHabit_creativity_description =>
      'Express yourself through creative activities';

  @override
  String get predefinedHabit_familyTime_name => 'Family Time';

  @override
  String get predefinedHabit_familyTime_description =>
      'Spend quality time with loved ones';

  @override
  String get predefinedHabit_service_name => 'Acts of Service';

  @override
  String get predefinedHabit_service_description =>
      'Serve others with love and compassion';

  @override
  String get onboardingErrorMessage =>
      'Failed to save habits. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

  @override
  String get category => 'Category';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get emoji => 'Emoji';

  @override
  String get color => 'Color';

  @override
  String get optional => 'optional';

  @override
  String get edit => 'Edit';

  @override
  String get uncheck => 'Uncheck';

  @override
  String get save => 'Save';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get defaultColor => 'Default';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageInfo =>
      'The app will use your selected language for all text and interface elements.';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get notificationTimeUpdated => 'Notification time updated to';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationsOn => 'Notifications On';

  @override
  String get notificationsOff => 'Notifications Off';

  @override
  String get receiveReminderNotifications =>
      'Receive daily reminder notifications';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get selectNotificationTime => 'Select notification time';

  @override
  String get currentTime => 'Current time';

  @override
  String get notificationInfo =>
      'You will receive a daily reminder at your selected time to complete your habits.';

  @override
  String get highRiskWarning => 'High risk of abandoning this habit today!';

  @override
  String riskPercentage(int percent) {
    return '$percent% probability of abandonment';
  }

  @override
  String get completeNow => 'Complete Now';

  @override
  String abandonmentNudgeTitle(String habitName) {
    return 'Reduce habit \"$habitName\"?';
  }

  @override
  String abandonmentNudgeBody(int minutes) {
    return 'Reduce to ${minutes}min? We noticed you might abandon this habit';
  }

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get versesSaved => 'Verses saved';

  @override
  String get loadingBooks => 'Loading books...';

  @override
  String get selectBook => 'Select Book';

  @override
  String get selectBookAndChapter => 'Select a book and chapter';

  @override
  String get habitsCompleted => 'Habits completed:';

  @override
  String habitsCompletedCount(int completed, int total) {
    return '$completed of $total';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get generateMicroHabits => 'Generate Micro-Habits';

  @override
  String get aiGeneratedHabits => 'AI-Generated Habits';

  @override
  String get yourGoal => 'Your Goal';

  @override
  String get goalHint =>
      'What would you like to improve? (e.g., Pray more consistently)';

  @override
  String get goalRequired => 'Please enter your goal';

  @override
  String get goalTooShort => 'Goal must be at least 10 characters';

  @override
  String get goalTooLong => 'Goal cannot exceed 200 characters';

  @override
  String get failurePattern => 'When do you usually fail? (Optional)';

  @override
  String get failurePatternHint => 'e.g., I forget during busy mornings';

  @override
  String get generateHabits => 'Generate Habits';

  @override
  String get generating => 'Generating...';

  @override
  String get generatingHabits =>
      'Generating personalized micro-habits for you...';

  @override
  String get generatedHabitsTitle => 'Your Personalized Micro-Habits';

  @override
  String get selectHabitsToAdd => 'Select habits to add to your tracking:';

  @override
  String get saveSelected => 'Save Selected';

  @override
  String get saving => 'Saving...';

  @override
  String habitsAdded(int count) {
    return '$count habit(s) added successfully!';
  }

  @override
  String estimatedTime(int minutes) {
    return '~$minutes min';
  }

  @override
  String get bibleVerse => 'Bible Verse';

  @override
  String get purpose => 'Purpose';

  @override
  String remaining(int count) {
    return '$count remaining';
  }

  @override
  String monthlyLimit(int limit) {
    return 'Monthly limit: $limit generations';
  }

  @override
  String get rateLimitReached => 'Monthly limit reached. Try again next month.';

  @override
  String get generationFailed => 'Failed to generate habits. Please try again.';

  @override
  String get apiTimeout =>
      'Request timed out. Please check your connection and try again.';

  @override
  String get invalidInput =>
      'Invalid input. Please check your goal and try again.';

  @override
  String get noHabitsSelected => 'Please select at least one habit to save';

  @override
  String get tryAgain => 'Try Again';

  @override
  String generationsRemaining(int count) {
    return '$count generation(s) remaining this month';
  }

  @override
  String get poweredByGemini => 'Powered by Gemini AI';

  @override
  String get chooseYourExperience => 'Choose Your Experience';

  @override
  String get displayModeDescription =>
      'Select how you want to use Habitus Faith';

  @override
  String get compactMode => 'Compact Mode';

  @override
  String get compactModeDescription =>
      'Essential features for daily habit tracking';

  @override
  String get compactModeFeature1 => 'Clean, minimalist interface';

  @override
  String get compactModeFeature2 => 'Quick habit tracking';

  @override
  String get compactModeFeature3 => 'Basic statistics';

  @override
  String get advancedMode => 'Advanced Mode';

  @override
  String get advancedModeDescription =>
      'Full-featured experience with insights and analytics';

  @override
  String get advancedModeFeature1 => 'Detailed habit analytics';

  @override
  String get advancedModeFeature2 => 'AI-powered insights';

  @override
  String get advancedModeFeature3 => 'Advanced customization';

  @override
  String get changeAnytime =>
      'You can change this setting anytime in preferences';

  @override
  String get selectMode => 'Select Mode';

  @override
  String get displayMode => 'Display Mode';

  @override
  String displayModeUpdated(String mode) {
    return 'Display mode updated to $mode';
  }

  @override
  String get compactModeSubtitle => 'Compact checklist - tap for details';

  @override
  String get advancedModeSubtitle => 'Full tracking visible';

  @override
  String get addManually => 'Add Manually';

  @override
  String get createCustomHabit => 'Create a custom habit';

  @override
  String get generateWithAI => 'Generate with AI';

  @override
  String get aiCustomHabits => 'Custom habits with AI';

  @override
  String get previewHabitName => 'Habit name';

  @override
  String get previewHabitDescription => 'Habit description';

  @override
  String get total => 'Total';

  @override
  String get mlPredictionFailed => 'Unable to calculate abandonment risk';

  @override
  String get mlModelNotLoaded =>
      'Prediction model unavailable. Please restart the app.';

  @override
  String mlInsufficientData(int days) {
    return 'Need at least $days days of data for predictions';
  }

  @override
  String backgroundSyncFailed(String reason) {
    return 'Sync failed: $reason';
  }

  @override
  String get backgroundSyncNetwork =>
      'No internet connection. Changes will sync when online.';

  @override
  String get backgroundSyncPermission =>
      'Background sync disabled. Enable in settings.';

  @override
  String get workmanagerActive => 'Background sync active';

  @override
  String get workmanagerRestricted =>
      'Background sync may be limited by battery optimization';

  @override
  String get workmanagerDisabled =>
      'Background sync disabled in system settings';

  @override
  String get patternWeekend =>
      'You tend to skip weekends. Try setting a reminder?';

  @override
  String get patternEvening =>
      'Evening completion rate is low. Consider morning habits?';

  @override
  String optimalTimeFound(String time) {
    return 'Your best completion time is $time';
  }

  @override
  String get networkTimeout => 'Request timed out. Check your connection.';

  @override
  String get firebasePermissionDenied => 'Access denied. Please sign in again.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get devBannerTitle => 'Developer Tools';

  @override
  String devBannerLastSync(String time) {
    return 'Last sync: $time';
  }

  @override
  String devBannerMlStatus(String status) {
    return 'ML Model: $status';
  }

  @override
  String devBannerWorkmanager(String status) {
    return 'Background: $status';
  }

  @override
  String devBannerFastTime(String multiplier, String date) {
    return 'Time: ${multiplier}x (Simulated: $date)';
  }

  @override
  String get riskLevelLow => 'Low risk';

  @override
  String get riskLevelMedium => 'Medium risk';

  @override
  String get riskLevelHigh => 'High risk';

  @override
  String get predictorRunning => 'Analyzing habits...';

  @override
  String get predictorComplete => 'Analysis complete';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get mlModelLoaded => 'Loaded';

  @override
  String get mlModelLoading => 'Loading...';

  @override
  String get mlModelError => 'Error';

  @override
  String get chooseHabitType => 'What type of habit do you want to add?';

  @override
  String get chooseFromPredefined => 'Choose from predefined habits';

  @override
  String get manual => 'Manual';

  @override
  String get custom => 'Custom';

  @override
  String get defaultHabit => 'Default';

  @override
  String get addHabitDiscoverySubtitle =>
      'Choose how you want to add your new habit: you can create a custom one or select a predefined habit to get started faster.';

  @override
  String get requiredFieldLabel => 'Required';

  @override
  String get back => 'Back';

  @override
  String get selectAll => 'Select all';

  @override
  String get copy => 'Duplicate';

  @override
  String get copyHabit => 'Do you want to duplicate the task?';

  @override
  String copyHabitConfirm(String habitName) {
    return 'Are you sure you want to duplicate \"$habitName\"?';
  }

  @override
  String get introMessage => 'The greatest changes begin with consistency...';

  @override
  String get usefulTip => 'Useful tip';

  @override
  String get habitsTip => 'Swipe to see actions on your habits';

  @override
  String get understood => 'Understood';

  @override
  String get bible => 'Bible';

  @override
  String get home => 'Home';
}
