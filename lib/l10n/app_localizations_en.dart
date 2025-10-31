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
}
