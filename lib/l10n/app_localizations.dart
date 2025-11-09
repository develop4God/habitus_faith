import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('zh')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Habitus Faith'**
  String get appTitle;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Read Bible button text
  ///
  /// In en, this message translates to:
  /// **'Read Bible'**
  String get readBible;

  /// Title for habits page
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabits;

  /// Empty state message when user has no habits
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabits;

  /// Streak label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// Add habit button text
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get addHabit;

  /// Delete habit dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// Delete habit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{habitName}\"?'**
  String deleteHabitConfirm(String habitName);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Onboarding welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Habitus Faith'**
  String get welcomeToHabitusFaith;

  /// Onboarding instruction
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 habits to start your journey'**
  String get selectUpToThreeHabits;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Error message when no habits selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one habit'**
  String get selectAtLeastOne;

  /// Error message when trying to select more than 3
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 habits'**
  String get maxThreeHabits;

  /// Spiritual category
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get spiritual;

  /// Physical category
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// Mental category
  ///
  /// In en, this message translates to:
  /// **'Mental'**
  String get mental;

  /// Relational category
  ///
  /// In en, this message translates to:
  /// **'Relational'**
  String get relational;

  /// Success message when habit is completed
  ///
  /// In en, this message translates to:
  /// **'Habit completed! 🎉'**
  String get habitCompleted;

  /// Instruction to tap to complete habit
  ///
  /// In en, this message translates to:
  /// **'Tap to complete'**
  String get tapToComplete;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Longest streak label
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// This week label for calendar
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Name of morning prayer habit
  ///
  /// In en, this message translates to:
  /// **'Morning Prayer'**
  String get predefinedHabit_morningPrayer_name;

  /// Description of morning prayer habit
  ///
  /// In en, this message translates to:
  /// **'Start your day with prayer and thanksgiving'**
  String get predefinedHabit_morningPrayer_description;

  /// Name of bible reading habit
  ///
  /// In en, this message translates to:
  /// **'Bible Reading'**
  String get predefinedHabit_bibleReading_name;

  /// Description of bible reading habit
  ///
  /// In en, this message translates to:
  /// **'Read and meditate on God\'s Word daily'**
  String get predefinedHabit_bibleReading_description;

  /// Name of worship habit
  ///
  /// In en, this message translates to:
  /// **'Worship'**
  String get predefinedHabit_worship_name;

  /// Description of worship habit
  ///
  /// In en, this message translates to:
  /// **'Spend time in worship and praise'**
  String get predefinedHabit_worship_description;

  /// Name of gratitude habit
  ///
  /// In en, this message translates to:
  /// **'Gratitude Journal'**
  String get predefinedHabit_gratitude_name;

  /// Description of gratitude habit
  ///
  /// In en, this message translates to:
  /// **'Write down what you\'re thankful for'**
  String get predefinedHabit_gratitude_description;

  /// Name of exercise habit
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get predefinedHabit_exercise_name;

  /// Description of exercise habit
  ///
  /// In en, this message translates to:
  /// **'Take care of your body, God\'s temple'**
  String get predefinedHabit_exercise_description;

  /// Name of healthy eating habit
  ///
  /// In en, this message translates to:
  /// **'Healthy Eating'**
  String get predefinedHabit_healthyEating_name;

  /// Description of healthy eating habit
  ///
  /// In en, this message translates to:
  /// **'Nourish your body with wholesome food'**
  String get predefinedHabit_healthyEating_description;

  /// Name of sleep habit
  ///
  /// In en, this message translates to:
  /// **'Quality Sleep'**
  String get predefinedHabit_sleep_name;

  /// Description of sleep habit
  ///
  /// In en, this message translates to:
  /// **'Get restful sleep to recharge'**
  String get predefinedHabit_sleep_description;

  /// Name of meditation habit
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get predefinedHabit_meditation_name;

  /// Description of meditation habit
  ///
  /// In en, this message translates to:
  /// **'Practice mindfulness and reflection'**
  String get predefinedHabit_meditation_description;

  /// Name of learning habit
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get predefinedHabit_learning_name;

  /// Description of learning habit
  ///
  /// In en, this message translates to:
  /// **'Grow in knowledge and wisdom'**
  String get predefinedHabit_learning_description;

  /// Name of creativity habit
  ///
  /// In en, this message translates to:
  /// **'Creative Time'**
  String get predefinedHabit_creativity_name;

  /// Description of creativity habit
  ///
  /// In en, this message translates to:
  /// **'Express yourself through creative activities'**
  String get predefinedHabit_creativity_description;

  /// Name of family time habit
  ///
  /// In en, this message translates to:
  /// **'Family Time'**
  String get predefinedHabit_familyTime_name;

  /// Description of family time habit
  ///
  /// In en, this message translates to:
  /// **'Spend quality time with loved ones'**
  String get predefinedHabit_familyTime_description;

  /// Name of service habit
  ///
  /// In en, this message translates to:
  /// **'Acts of Service'**
  String get predefinedHabit_service_name;

  /// Description of service habit
  ///
  /// In en, this message translates to:
  /// **'Serve others with love and compassion'**
  String get predefinedHabit_service_description;

  /// Error message shown when onboarding fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save habits. Please try again.'**
  String get onboardingErrorMessage;

  /// Button label for retrying an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Accessibility label indicating an item is selected
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Emoji label
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// Color label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Optional label
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Uncheck button text
  ///
  /// In en, this message translates to:
  /// **'Uncheck'**
  String get uncheck;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit habit dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// Default color option label
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultColor;

  /// Statistics/Progress page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Notifications settings option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification settings title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Language settings title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Select language instruction
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language information text
  ///
  /// In en, this message translates to:
  /// **'The app will use your selected language for all text and interface elements.'**
  String get languageInfo;

  /// Notifications enabled message
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// Notifications disabled message
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// Notification time updated message
  ///
  /// In en, this message translates to:
  /// **'Notification time updated to'**
  String get notificationTimeUpdated;

  /// Enable notifications option
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Notifications on label
  ///
  /// In en, this message translates to:
  /// **'Notifications On'**
  String get notificationsOn;

  /// Notifications off label
  ///
  /// In en, this message translates to:
  /// **'Notifications Off'**
  String get notificationsOff;

  /// Receive reminder notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive daily reminder notifications'**
  String get receiveReminderNotifications;

  /// Notification time label
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// Select notification time instruction
  ///
  /// In en, this message translates to:
  /// **'Select notification time'**
  String get selectNotificationTime;

  /// Current time label
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get currentTime;

  /// Notification information text
  ///
  /// In en, this message translates to:
  /// **'You will receive a daily reminder at your selected time to complete your habits.'**
  String get notificationInfo;

  /// Warning message for high abandonment risk
  ///
  /// In en, this message translates to:
  /// **'High risk of abandoning this habit today!'**
  String get highRiskWarning;

  /// Display abandonment risk percentage
  ///
  /// In en, this message translates to:
  /// **'{percent}% probability of abandonment'**
  String riskPercentage(int percent);

  /// Button text to complete habit immediately
  ///
  /// In en, this message translates to:
  /// **'Complete Now'**
  String get completeNow;

  /// Title for abandonment prediction nudge notification
  ///
  /// In en, this message translates to:
  /// **'Reduce habit \"{habitName}\"?'**
  String abandonmentNudgeTitle(String habitName);

  /// Body text for abandonment prediction nudge notification
  ///
  /// In en, this message translates to:
  /// **'Reduce to {minutes}min? We noticed you might abandon this habit'**
  String abandonmentNudgeBody(int minutes);

  /// Message shown when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Message shown when Bible verses are saved
  ///
  /// In en, this message translates to:
  /// **'Verses saved'**
  String get versesSaved;

  /// Message shown while loading Bible books
  ///
  /// In en, this message translates to:
  /// **'Loading books...'**
  String get loadingBooks;

  /// Hint text for book selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get selectBook;

  /// Message shown when no book and chapter are selected
  ///
  /// In en, this message translates to:
  /// **'Select a book and chapter'**
  String get selectBookAndChapter;

  /// Label for habits completed statistic
  ///
  /// In en, this message translates to:
  /// **'Habits completed:'**
  String get habitsCompleted;

  /// Shows number of completed habits out of total
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total}'**
  String habitsCompletedCount(int completed, int total);

  /// Error message template
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(String message);

  /// Title for micro-habits generator page
  ///
  /// In en, this message translates to:
  /// **'Generate Micro-Habits'**
  String get generateMicroHabits;

  /// Title for AI-generated habits section
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Habits'**
  String get aiGeneratedHabits;

  /// Label for user goal input field
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get yourGoal;

  /// Hint text for goal input field
  ///
  /// In en, this message translates to:
  /// **'What would you like to improve? (e.g., Pray more consistently)'**
  String get goalHint;

  /// Validation message when goal is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your goal'**
  String get goalRequired;

  /// Validation message when goal is too short
  ///
  /// In en, this message translates to:
  /// **'Goal must be at least 10 characters'**
  String get goalTooShort;

  /// Validation message when goal is too long
  ///
  /// In en, this message translates to:
  /// **'Goal cannot exceed 200 characters'**
  String get goalTooLong;

  /// Label for failure pattern input field
  ///
  /// In en, this message translates to:
  /// **'When do you usually fail? (Optional)'**
  String get failurePattern;

  /// Hint text for failure pattern input
  ///
  /// In en, this message translates to:
  /// **'e.g., I forget during busy mornings'**
  String get failurePatternHint;

  /// Button text to generate habits
  ///
  /// In en, this message translates to:
  /// **'Generate Habits'**
  String get generateHabits;

  /// Loading state text while generating
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// Loading message while habits are being generated
  ///
  /// In en, this message translates to:
  /// **'Generating personalized micro-habits for you...'**
  String get generatingHabits;

  /// Title for generated habits results page
  ///
  /// In en, this message translates to:
  /// **'Your Personalized Micro-Habits'**
  String get generatedHabitsTitle;

  /// Instructions for selecting habits
  ///
  /// In en, this message translates to:
  /// **'Select habits to add to your tracking:'**
  String get selectHabitsToAdd;

  /// Button to save selected habits
  ///
  /// In en, this message translates to:
  /// **'Save Selected'**
  String get saveSelected;

  /// Loading text while saving habits
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Success message after adding habits
  ///
  /// In en, this message translates to:
  /// **'{count} habit(s) added successfully!'**
  String habitsAdded(int count);

  /// Estimated time for habit completion
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String estimatedTime(int minutes);

  /// Label for bible verse section
  ///
  /// In en, this message translates to:
  /// **'Bible Verse'**
  String get bibleVerse;

  /// Label for habit purpose
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// Remaining generations count
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String remaining(int count);

  /// Information about monthly generation limit
  ///
  /// In en, this message translates to:
  /// **'Monthly limit: {limit} generations'**
  String monthlyLimit(int limit);

  /// Error message when rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Monthly limit reached. Try again next month.'**
  String get rateLimitReached;

  /// Generic error message for generation failure
  ///
  /// In en, this message translates to:
  /// **'Failed to generate habits. Please try again.'**
  String get generationFailed;

  /// Error message for API timeout
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please check your connection and try again.'**
  String get apiTimeout;

  /// Error message for invalid input
  ///
  /// In en, this message translates to:
  /// **'Invalid input. Please check your goal and try again.'**
  String get invalidInput;

  /// Error when trying to save without selecting habits
  ///
  /// In en, this message translates to:
  /// **'Please select at least one habit to save'**
  String get noHabitsSelected;

  /// Button to retry after error
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Shows how many generations are left
  ///
  /// In en, this message translates to:
  /// **'{count} generation(s) remaining this month'**
  String generationsRemaining(int count);

  /// Attribution for AI service
  ///
  /// In en, this message translates to:
  /// **'Powered by Gemini AI'**
  String get poweredByGemini;

  /// Title for display mode selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Experience'**
  String get chooseYourExperience;

  /// Description text for display mode selection
  ///
  /// In en, this message translates to:
  /// **'Select how you want to use Habitus Faith'**
  String get displayModeDescription;

  /// Title for compact display mode
  ///
  /// In en, this message translates to:
  /// **'Compact Mode'**
  String get compactMode;

  /// Description of compact display mode
  ///
  /// In en, this message translates to:
  /// **'Essential features for daily habit tracking'**
  String get compactModeDescription;

  /// First feature of compact mode
  ///
  /// In en, this message translates to:
  /// **'Clean, minimalist interface'**
  String get compactModeFeature1;

  /// Second feature of compact mode
  ///
  /// In en, this message translates to:
  /// **'Quick habit tracking'**
  String get compactModeFeature2;

  /// Third feature of compact mode
  ///
  /// In en, this message translates to:
  /// **'Basic statistics'**
  String get compactModeFeature3;

  /// Title for advanced display mode
  ///
  /// In en, this message translates to:
  /// **'Advanced Mode'**
  String get advancedMode;

  /// Description of advanced display mode
  ///
  /// In en, this message translates to:
  /// **'Full-featured experience with insights and analytics'**
  String get advancedModeDescription;

  /// First feature of advanced mode
  ///
  /// In en, this message translates to:
  /// **'Detailed habit analytics'**
  String get advancedModeFeature1;

  /// Second feature of advanced mode
  ///
  /// In en, this message translates to:
  /// **'AI-powered insights'**
  String get advancedModeFeature2;

  /// Third feature of advanced mode
  ///
  /// In en, this message translates to:
  /// **'Advanced customization'**
  String get advancedModeFeature3;

  /// Message informing users they can change mode later
  ///
  /// In en, this message translates to:
  /// **'You can change this setting anytime in preferences'**
  String get changeAnytime;

  /// Button text to confirm mode selection
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get selectMode;

  /// Display mode setting title
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// Confirmation message when display mode is changed
  ///
  /// In en, this message translates to:
  /// **'Display mode updated to {mode}'**
  String displayModeUpdated(String mode);

  /// Subtitle for compact mode in settings
  ///
  /// In en, this message translates to:
  /// **'Compact checklist - tap for details'**
  String get compactModeSubtitle;

  /// Subtitle for advanced mode in settings
  ///
  /// In en, this message translates to:
  /// **'Full tracking visible'**
  String get advancedModeSubtitle;

  /// Option to add habit manually
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// Description for manual habit creation
  ///
  /// In en, this message translates to:
  /// **'Create a custom habit'**
  String get createCustomHabit;

  /// Option to generate habits with AI
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get generateWithAI;

  /// Description for AI-generated habits
  ///
  /// In en, this message translates to:
  /// **'Custom habits with AI'**
  String get aiCustomHabits;

  /// Placeholder text for habit name in preview
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get previewHabitName;

  /// Placeholder text for habit description in preview
  ///
  /// In en, this message translates to:
  /// **'Habit description'**
  String get previewHabitDescription;

  /// Total label for statistics
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Error message when ML prediction fails
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate abandonment risk'**
  String get mlPredictionFailed;

  /// Error when ML model is not loaded
  ///
  /// In en, this message translates to:
  /// **'Prediction model unavailable. Please restart the app.'**
  String get mlModelNotLoaded;

  /// Error when not enough data for predictions
  ///
  /// In en, this message translates to:
  /// **'Need at least {days} days of data for predictions'**
  String mlInsufficientData(int days);

  /// Background sync failure message
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {reason}'**
  String backgroundSyncFailed(String reason);

  /// Sync failed due to network
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Changes will sync when online.'**
  String get backgroundSyncNetwork;

  /// Sync disabled due to permissions
  ///
  /// In en, this message translates to:
  /// **'Background sync disabled. Enable in settings.'**
  String get backgroundSyncPermission;

  /// WorkManager is active
  ///
  /// In en, this message translates to:
  /// **'Background sync active'**
  String get workmanagerActive;

  /// WorkManager restricted warning
  ///
  /// In en, this message translates to:
  /// **'Background sync may be limited by battery optimization'**
  String get workmanagerRestricted;

  /// WorkManager disabled
  ///
  /// In en, this message translates to:
  /// **'Background sync disabled in system settings'**
  String get workmanagerDisabled;

  /// Weekend pattern detected message
  ///
  /// In en, this message translates to:
  /// **'You tend to skip weekends. Try setting a reminder?'**
  String get patternWeekend;

  /// Evening pattern detected message
  ///
  /// In en, this message translates to:
  /// **'Evening completion rate is low. Consider morning habits?'**
  String get patternEvening;

  /// Optimal time found message
  ///
  /// In en, this message translates to:
  /// **'Your best completion time is {time}'**
  String optimalTimeFound(String time);

  /// Network timeout error
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check your connection.'**
  String get networkTimeout;

  /// Firebase permission denied
  ///
  /// In en, this message translates to:
  /// **'Access denied. Please sign in again.'**
  String get firebasePermissionDenied;

  /// Generic unknown error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnknown;

  /// Dev tools banner title
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get devBannerTitle;

  /// Last sync time in dev banner
  ///
  /// In en, this message translates to:
  /// **'Last sync: {time}'**
  String devBannerLastSync(String time);

  /// ML model status in dev banner
  ///
  /// In en, this message translates to:
  /// **'ML Model: {status}'**
  String devBannerMlStatus(String status);

  /// WorkManager status in dev banner
  ///
  /// In en, this message translates to:
  /// **'Background: {status}'**
  String devBannerWorkmanager(String status);

  /// Fast time mode in dev banner
  ///
  /// In en, this message translates to:
  /// **'Time: {multiplier}x (Simulated: {date})'**
  String devBannerFastTime(String multiplier, String date);

  /// Low abandonment risk level
  ///
  /// In en, this message translates to:
  /// **'Low risk'**
  String get riskLevelLow;

  /// Medium abandonment risk level
  ///
  /// In en, this message translates to:
  /// **'Medium risk'**
  String get riskLevelMedium;

  /// High abandonment risk level
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskLevelHigh;

  /// Predictor is running
  ///
  /// In en, this message translates to:
  /// **'Analyzing habits...'**
  String get predictorRunning;

  /// Predictor completed
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get predictorComplete;

  /// Sync in progress
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncInProgress;

  /// Sync completed successfully
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// ML model loaded status
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get mlModelLoaded;

  /// ML model loading status
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get mlModelLoading;

  /// ML model error status
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get mlModelError;
  /// Text for choosing habit type when adding
  ///
  /// In en, this message translates to:
  /// **'What type of habit do you want to add?'**
  String get chooseHabitType;

  /// Text for choosing from predefined habits
  ///
  /// In en, this message translates to:
  /// **'Choose from predefined habits'**
  String get chooseFromPredefined;

  /// Manual habit option (short label)
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// Custom habit option (short label)
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Default/predefined habit option (short label)
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultHabit;

  /// Explanatory subtitle for the add habit discovery dialog
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your new habit: you can create a custom one or select a predefined habit to get started faster.'**
  String get addHabitDiscoverySubtitle;

  /// Label to indicate a field is required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredFieldLabel;

  /// Button to go back to the previous step in the dialog
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button to select all habits on the habits page
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// Text for duplicating a habit (swipe action)
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get copy;

  /// Dialog title for duplicating a habit
  ///
  /// In en, this message translates to:
  /// **'Do you want to duplicate the task?'**
  String get copyHabit;

  /// Confirmation message for duplicating a habit
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to duplicate \"{habitName}\"?'**
  String copyHabitConfirm(String habitName);

  /// Intro message shown on landing page as a motivational quote.
  ///
  /// In en, this message translates to:
  /// **'The greatest changes begin with consistency...'**
  String get introMessage;

  /// Educational tip title
  ///
  /// In en, this message translates to:
  /// **'Useful tip'**
  String get usefulTip;

  /// Educational tip description
  ///
  /// In en, this message translates to:
  /// **'Swipe to see actions on your habits'**
  String get habitsTip;

  /// Button to close the educational tip
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Bible title for AppBar
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get bible;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
