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
    Locale('zh'),
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
  /// **'Bible'**
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

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Confirmation message when user tries to start timer for already completed habit
  ///
  /// In en, this message translates to:
  /// **'This habit is already completed. Do you want to start the timer again?'**
  String get habitAlreadyCompletedStartAgain;

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

  /// Onboarding welcome message
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you personalize your first routines, according to your preferences.'**
  String get onboardingWelcomeMessage;

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

  /// Name of wash dishes habit
  ///
  /// In en, this message translates to:
  /// **'Wash Dishes'**
  String get predefinedHabit_washDishes_name;

  /// Description of wash dishes habit
  ///
  /// In en, this message translates to:
  /// **'Keep the kitchen clean and organized'**
  String get predefinedHabit_washDishes_description;

  /// Name of clean room habit
  ///
  /// In en, this message translates to:
  /// **'Clean Room'**
  String get predefinedHabit_cleanRoom_name;

  /// Description of clean room habit
  ///
  /// In en, this message translates to:
  /// **'Tidy up and organize your space'**
  String get predefinedHabit_cleanRoom_description;

  /// Name of do laundry habit
  ///
  /// In en, this message translates to:
  /// **'Do Laundry'**
  String get predefinedHabit_doLaundry_name;

  /// Description of do laundry habit
  ///
  /// In en, this message translates to:
  /// **'Wash and fold clothes'**
  String get predefinedHabit_doLaundry_description;

  /// Name of organize space habit
  ///
  /// In en, this message translates to:
  /// **'Organize Space'**
  String get predefinedHabit_organizeSpace_name;

  /// Description of organize space habit
  ///
  /// In en, this message translates to:
  /// **'Declutter and arrange your living area'**
  String get predefinedHabit_organizeSpace_description;

  /// Name of clean bathroom habit
  ///
  /// In en, this message translates to:
  /// **'Clean Bathroom'**
  String get predefinedHabit_cleanBathroom_name;

  /// Description of clean bathroom habit
  ///
  /// In en, this message translates to:
  /// **'Maintain a clean and hygienic bathroom'**
  String get predefinedHabit_cleanBathroom_description;

  /// Name of cook meal habit
  ///
  /// In en, this message translates to:
  /// **'Cook a Meal'**
  String get predefinedHabit_cookMeal_name;

  /// Description of cook meal habit
  ///
  /// In en, this message translates to:
  /// **'Prepare healthy home-cooked food'**
  String get predefinedHabit_cookMeal_description;

  /// Name of vacuum floors habit
  ///
  /// In en, this message translates to:
  /// **'Vacuum Floors'**
  String get predefinedHabit_vacuumFloors_name;

  /// Description of vacuum floors habit
  ///
  /// In en, this message translates to:
  /// **'Keep floors clean and dust-free'**
  String get predefinedHabit_vacuumFloors_description;

  /// Name of make breakfast habit
  ///
  /// In en, this message translates to:
  /// **'Make Breakfast'**
  String get predefinedHabit_makeBreakfast_name;

  /// Description of make breakfast habit
  ///
  /// In en, this message translates to:
  /// **'Start the day with a nutritious meal'**
  String get predefinedHabit_makeBreakfast_description;

  /// Name of bed making habit
  ///
  /// In en, this message translates to:
  /// **'Make the Bed'**
  String get predefinedHabit_bedMaking_name;

  /// Description of bed making habit
  ///
  /// In en, this message translates to:
  /// **'Start your day by making your bed'**
  String get predefinedHabit_bedMaking_description;

  /// Name of help kids homework habit
  ///
  /// In en, this message translates to:
  /// **'Help Kids with Homework'**
  String get predefinedHabit_helpKidsHomework_name;

  /// Description of help kids homework habit
  ///
  /// In en, this message translates to:
  /// **'Support children with their studies'**
  String get predefinedHabit_helpKidsHomework_description;

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

  /// Success message after editing a habit
  ///
  /// In en, this message translates to:
  /// **'Habit edited successfully'**
  String get habitEdited;

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

  /// Notification time updated message with time
  ///
  /// In en, this message translates to:
  /// **'Notification time updated to {time}'**
  String notificationTimeUpdated(String time);

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

  /// Label for current notification time
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get currentTime;

  /// Notification information text
  ///
  /// In en, this message translates to:
  /// **'You will receive a daily reminder at your selected time to complete your habits.'**
  String get notificationInfo;

  /// Confirmation question for notification time
  ///
  /// In en, this message translates to:
  /// **'Would you like to set the notification time to {time}?'**
  String confirmNotificationQuestion(String time);

  /// Confirm hour button label
  ///
  /// In en, this message translates to:
  /// **'Confirm hour'**
  String get buttonConfirmHour;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

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

  /// Title for automatically generated habits section
  ///
  /// In en, this message translates to:
  /// **'Automatically Generated Habits'**
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
  /// **'Advanced and personalized insights.'**
  String get advancedModeFeature2;

  /// Third feature of advanced mode
  ///
  /// In en, this message translates to:
  /// **'Third feature of advanced mode'**
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

  /// Option to generate habits automatically
  ///
  /// In en, this message translates to:
  /// **'Generate automatically'**
  String get generateWithAI;

  /// Description for automatically generated habits
  ///
  /// In en, this message translates to:
  /// **'Automatically customized habits'**
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

  /// Title for today's Bible verse section on home page
  ///
  /// In en, this message translates to:
  /// **'Today\'s Verse'**
  String get todaysVerse;

  /// Title for today's habits section on home page
  ///
  /// In en, this message translates to:
  /// **'Today\'s Habits'**
  String get todaysHabits;

  /// Success message when all habits are completed
  ///
  /// In en, this message translates to:
  /// **'🎉 All habits completed today!'**
  String get allHabitsCompleted;

  /// Shows the current streak for a habit
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(int count);

  /// Message shown when user has no habits yet
  ///
  /// In en, this message translates to:
  /// **'Start your journey today'**
  String get startJourney;

  /// Motivational message when no habits are completed
  ///
  /// In en, this message translates to:
  /// **'Let\'s build consistency today! 💪'**
  String get buildConsistency;

  /// Motivational message when some habits are completed
  ///
  /// In en, this message translates to:
  /// **'Great progress! Keep it going! 🔥'**
  String get greatProgress;

  /// Shows how many habits remain to be completed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit remaining today} other{{count} habits remaining today}}'**
  String habitsRemaining(int count);

  /// Label for longest streak card on home page
  ///
  /// In en, this message translates to:
  /// **'Longest\nStreak'**
  String get longestStreakCard;

  /// Label for weekly consistency card on home page
  ///
  /// In en, this message translates to:
  /// **'Weekly\nConsistency'**
  String get weeklyConsistencyCard;

  /// Hint text showing users how to complete habits
  ///
  /// In en, this message translates to:
  /// **'Tap or swipe left to complete'**
  String get swipeToComplete;

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

  /// Reminder configuration dialog title
  ///
  /// In en, this message translates to:
  /// **'Reminder Configuration'**
  String get reminderConfig;

  /// Recurrence configuration dialog title
  ///
  /// In en, this message translates to:
  /// **'Daily Repetitions'**
  String get recurrenceConfig;

  /// Repeat reminder toggle label
  ///
  /// In en, this message translates to:
  /// **'Repeat Reminder'**
  String get repeat;

  /// Subtitle for repeat toggle
  ///
  /// In en, this message translates to:
  /// **'Set a cycle for your plan'**
  String get setCycleForPlan;

  /// Subtasks section label
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// Add subtask hint text
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtask;

  /// Custom minutes before label
  ///
  /// In en, this message translates to:
  /// **'Minutes before'**
  String get minutesBefore;

  /// Interval label for recurrence
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// End date label for recurrence
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// Daily frequency option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency option
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly frequency option
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Every X days text
  ///
  /// In en, this message translates to:
  /// **'Every {count} day(s)'**
  String everyXDays(int count);

  /// Every X weeks text
  ///
  /// In en, this message translates to:
  /// **'Every {count} week(s)'**
  String everyXWeeks(int count);

  /// Every X months text
  ///
  /// In en, this message translates to:
  /// **'Every {count} month(s)'**
  String everyXMonths(int count);

  /// No repetition text
  ///
  /// In en, this message translates to:
  /// **'No repetition'**
  String get noRepetition;

  /// Reminder label
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// Repetition label
  ///
  /// In en, this message translates to:
  /// **'Repetition'**
  String get repetition;

  /// Event time label
  ///
  /// In en, this message translates to:
  /// **'Event time (HH:MM)'**
  String get eventTime;

  /// Validation message for invalid custom minutes
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number between 1 and 1440'**
  String get invalidMinutes;

  /// Validation message for invalid interval
  ///
  /// In en, this message translates to:
  /// **'Interval must be at least 1'**
  String get invalidInterval;

  /// Title for habit tracking calendar page
  ///
  /// In en, this message translates to:
  /// **'Habit Tracking'**
  String get habitTracking;

  /// Label for routine option in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routine;

  /// Label to show the current day in the habits view
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Quick task option with only name and emoji
  ///
  /// In en, this message translates to:
  /// **'Flash Task'**
  String get flashTask;

  /// Description for flash task option
  ///
  /// In en, this message translates to:
  /// **'Quickly add a task with just a name and emoji'**
  String get flashTaskSubtitle;

  /// No description provided for @morning_prayer.
  ///
  /// In en, this message translates to:
  /// **'Morning Prayer'**
  String get morning_prayer;

  /// No description provided for @bible_reading.
  ///
  /// In en, this message translates to:
  /// **'Bible Reading'**
  String get bible_reading;

  /// No description provided for @evening_prayer.
  ///
  /// In en, this message translates to:
  /// **'Evening Prayer'**
  String get evening_prayer;

  /// No description provided for @worship_music.
  ///
  /// In en, this message translates to:
  /// **'Worship Music'**
  String get worship_music;

  /// No description provided for @gratitude_journal.
  ///
  /// In en, this message translates to:
  /// **'Gratitude Journal'**
  String get gratitude_journal;

  /// No description provided for @scripture_meditation.
  ///
  /// In en, this message translates to:
  /// **'Scripture Meditation'**
  String get scripture_meditation;

  /// No description provided for @fasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fasting;

  /// No description provided for @serve_others.
  ///
  /// In en, this message translates to:
  /// **'Serve Others'**
  String get serve_others;

  /// No description provided for @bible_study_group.
  ///
  /// In en, this message translates to:
  /// **'Bible Study Group'**
  String get bible_study_group;

  /// No description provided for @prayer_walk.
  ///
  /// In en, this message translates to:
  /// **'Prayer Walk'**
  String get prayer_walk;

  /// No description provided for @scripture_memorization.
  ///
  /// In en, this message translates to:
  /// **'Scripture Memorization'**
  String get scripture_memorization;

  /// No description provided for @intercessory_prayer.
  ///
  /// In en, this message translates to:
  /// **'Intercessory Prayer'**
  String get intercessory_prayer;

  /// No description provided for @devotional_reading.
  ///
  /// In en, this message translates to:
  /// **'Devotional Reading'**
  String get devotional_reading;

  /// No description provided for @confession_repentance.
  ///
  /// In en, this message translates to:
  /// **'Confession & Repentance'**
  String get confession_repentance;

  /// No description provided for @praise_thanksgiving.
  ///
  /// In en, this message translates to:
  /// **'Praise & Thanksgiving'**
  String get praise_thanksgiving;

  /// No description provided for @sabbath_rest.
  ///
  /// In en, this message translates to:
  /// **'Sabbath Rest'**
  String get sabbath_rest;

  /// No description provided for @digital_detox_prayer.
  ///
  /// In en, this message translates to:
  /// **'Digital Detox & Prayer'**
  String get digital_detox_prayer;

  /// No description provided for @christian_podcast.
  ///
  /// In en, this message translates to:
  /// **'Christian Podcast'**
  String get christian_podcast;

  /// No description provided for @family_devotion.
  ///
  /// In en, this message translates to:
  /// **'Family Devotion'**
  String get family_devotion;

  /// No description provided for @spiritual_reading.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Reading'**
  String get spiritual_reading;

  /// No description provided for @daily_walk.
  ///
  /// In en, this message translates to:
  /// **'Daily Walk'**
  String get daily_walk;

  /// No description provided for @morning_exercise.
  ///
  /// In en, this message translates to:
  /// **'Morning Exercise'**
  String get morning_exercise;

  /// No description provided for @yoga_stretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get yoga_stretching;

  /// No description provided for @healthy_breakfast.
  ///
  /// In en, this message translates to:
  /// **'Healthy Breakfast'**
  String get healthy_breakfast;

  /// No description provided for @hydration_routine.
  ///
  /// In en, this message translates to:
  /// **'Hydration Routine'**
  String get hydration_routine;

  /// No description provided for @running_jogging.
  ///
  /// In en, this message translates to:
  /// **'Running/Jogging'**
  String get running_jogging;

  /// No description provided for @strength_training.
  ///
  /// In en, this message translates to:
  /// **'Strength Training'**
  String get strength_training;

  /// No description provided for @bike_cycling.
  ///
  /// In en, this message translates to:
  /// **'Biking/Cycling'**
  String get bike_cycling;

  /// No description provided for @healthy_meal_prep.
  ///
  /// In en, this message translates to:
  /// **'Healthy Meal Prep'**
  String get healthy_meal_prep;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @dance_movement.
  ///
  /// In en, this message translates to:
  /// **'Dance/Movement'**
  String get dance_movement;

  /// No description provided for @sports_recreation.
  ///
  /// In en, this message translates to:
  /// **'Sports/Recreation'**
  String get sports_recreation;

  /// No description provided for @posture_breaks.
  ///
  /// In en, this message translates to:
  /// **'Posture Breaks'**
  String get posture_breaks;

  /// No description provided for @outdoor_nature.
  ///
  /// In en, this message translates to:
  /// **'Outdoor/Nature Time'**
  String get outdoor_nature;

  /// No description provided for @evening_walk.
  ///
  /// In en, this message translates to:
  /// **'Evening Walk'**
  String get evening_walk;

  /// No description provided for @mindfulness_meditation.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness Meditation'**
  String get mindfulness_meditation;

  /// No description provided for @journaling.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get journaling;

  /// No description provided for @deep_work_focus.
  ///
  /// In en, this message translates to:
  /// **'Deep Work/Focus'**
  String get deep_work_focus;

  /// No description provided for @reading_learning.
  ///
  /// In en, this message translates to:
  /// **'Reading/Learning'**
  String get reading_learning;

  /// No description provided for @digital_detox.
  ///
  /// In en, this message translates to:
  /// **'Digital Detox'**
  String get digital_detox;

  /// No description provided for @planning_review.
  ///
  /// In en, this message translates to:
  /// **'Planning & Review'**
  String get planning_review;

  /// No description provided for @breathing_exercises.
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercises'**
  String get breathing_exercises;

  /// No description provided for @creative_hobby.
  ///
  /// In en, this message translates to:
  /// **'Creative Hobby'**
  String get creative_hobby;

  /// No description provided for @call_friend_family.
  ///
  /// In en, this message translates to:
  /// **'Call Friend/Family'**
  String get call_friend_family;

  /// No description provided for @quality_time_loved_ones.
  ///
  /// In en, this message translates to:
  /// **'Quality Time with Loved Ones'**
  String get quality_time_loved_ones;

  /// Add note button text
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Placeholder text for note input field
  ///
  /// In en, this message translates to:
  /// **'How did it go? Share your thoughts...'**
  String get noteHint;

  /// View note button text
  ///
  /// In en, this message translates to:
  /// **'View Note'**
  String get viewNote;

  /// Share note button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareNote;

  /// Note added confirmation message
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get noteAdded;

  /// Add note dialog title
  ///
  /// In en, this message translates to:
  /// **'Add a Note'**
  String get addNoteDialog;

  /// Complete habit with note button text
  ///
  /// In en, this message translates to:
  /// **'Complete & Add Note'**
  String get completeWithNote;

  /// Add emoji button text
  ///
  /// In en, this message translates to:
  /// **'Add Emoji'**
  String get addEmoji;

  /// Hide emoji picker button text
  ///
  /// In en, this message translates to:
  /// **'Hide Emojis'**
  String get hideEmojis;

  /// No description provided for @onboardingSelectAtLeastOneGoal.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one goal'**
  String get onboardingSelectAtLeastOneGoal;

  /// No description provided for @onboardingPreparingHabits.
  ///
  /// In en, this message translates to:
  /// **'Preparing your habits...'**
  String get onboardingPreparingHabits;

  /// No description provided for @onboardingKeepAtLeastOneHabit.
  ///
  /// In en, this message translates to:
  /// **'You must keep at least one habit'**
  String get onboardingKeepAtLeastOneHabit;

  /// No description provided for @onboardingCouldNotCreateHabits.
  ///
  /// In en, this message translates to:
  /// **'Could not create habits. Please try again.'**
  String get onboardingCouldNotCreateHabits;

  /// Title for planning the day's habits
  ///
  /// In en, this message translates to:
  /// **'Plan Your Day'**
  String get planYourDay;

  /// Option to skip/postpone habit for today
  ///
  /// In en, this message translates to:
  /// **'Skip for Today'**
  String get skipHabit;

  /// Option to mark habit as failed/not completed
  ///
  /// In en, this message translates to:
  /// **'Not Completed'**
  String get markAsNotCompleted;

  /// Label for skipped habit
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedHabit;

  /// Label for failed/not completed habit
  ///
  /// In en, this message translates to:
  /// **'Not Completed'**
  String get failedHabit;

  /// Repeat reminder configuration option
  ///
  /// In en, this message translates to:
  /// **'Repeat Reminder'**
  String get repeatReminder;

  /// Message when habit is skipped
  ///
  /// In en, this message translates to:
  /// **'Habit skipped for today'**
  String get habitSkipped;

  /// Message when habit is marked as failed
  ///
  /// In en, this message translates to:
  /// **'Habit marked as not completed'**
  String get habitMarkedAsNotCompleted;

  /// Success message after deleting a habit
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get habitDeleted;

  /// Success message after creating a habit
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully'**
  String get habitCreated;

  /// Title for the daily reflection/notes page
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection'**
  String get dailyReflection;

  /// Subtitle/Header for daily reflection
  ///
  /// In en, this message translates to:
  /// **'My Reflection'**
  String get myReflection;

  /// Label for the general daily note
  ///
  /// In en, this message translates to:
  /// **'General Note'**
  String get globalNote;

  /// Hint for general daily note
  ///
  /// In en, this message translates to:
  /// **'How was your communion with God today?'**
  String get globalNoteHint;

  /// Section header for daily habits in reflection
  ///
  /// In en, this message translates to:
  /// **'Daily Habits'**
  String get dailyHabits;

  /// Instruction for habit-specific reflections
  ///
  /// In en, this message translates to:
  /// **'Add thoughts specific to your achievements.'**
  String get addReflection;

  /// Empty state message for reflection page
  ///
  /// In en, this message translates to:
  /// **'Complete a habit to reflect on it'**
  String get completeHabitToReflect;

  /// Title for notification options dialog
  ///
  /// In en, this message translates to:
  /// **'Notification Options'**
  String get notificationOptions;

  /// Option to turn off habit notification
  ///
  /// In en, this message translates to:
  /// **'Turn Off Notification'**
  String get turnOffNotification;

  /// Description for turn off notification option
  ///
  /// In en, this message translates to:
  /// **'Disable daily reminder for this habit'**
  String get turnOffNotificationDesc;

  /// Option to change notification time
  ///
  /// In en, this message translates to:
  /// **'Change Time'**
  String get changeNotificationTime;

  /// Description for change notification time option
  ///
  /// In en, this message translates to:
  /// **'Update when you want to be reminded'**
  String get changeNotificationTimeDesc;

  /// Message shown when notification is disabled
  ///
  /// In en, this message translates to:
  /// **'Notification turned off'**
  String get notificationTurnedOff;

  /// Message shown when notification time is changed
  ///
  /// In en, this message translates to:
  /// **'Notification time updated'**
  String get notificationTimeChanged;

  /// Error message shown when notification data is corrupted or invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid notification configuration. Please set up the notification again.'**
  String get invalidNotificationConfig;

  /// Button to read the Bible verse before the devotional
  ///
  /// In en, this message translates to:
  /// **'Read Verse First'**
  String get readVerseFirst;

  /// Section title for devotional reflection
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// Section title for meditation points
  ///
  /// In en, this message translates to:
  /// **'For Meditation'**
  String get forMeditation;

  /// Section title for prayer
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get prayer;

  /// Label for today's date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// Label for tomorrow's date
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowLabel;

  /// About Us page title
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// About Us page main title
  ///
  /// In en, this message translates to:
  /// **'Habitus Faith'**
  String get aboutUsTitle;

  /// About Us page subtitle
  ///
  /// In en, this message translates to:
  /// **'Building Faith Through Daily Habits'**
  String get aboutUsSubtitle;

  /// About Us main description
  ///
  /// In en, this message translates to:
  /// **'Habitus Faith is an application designed to help you grow in your spiritual journey through the power of consistent daily habits. We believe that small, intentional actions repeated daily can transform your life and deepen your relationship with God.'**
  String get aboutUsDescription;

  /// Our Mission section title
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// Our Mission text
  ///
  /// In en, this message translates to:
  /// **'To empower believers worldwide to build sustainable spiritual habits that strengthen their faith, one day at a time.'**
  String get ourMissionText;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Feature: Habit Tracking
  ///
  /// In en, this message translates to:
  /// **'Habit Tracking'**
  String get featureHabitTracking;

  /// Feature description: Habit Tracking
  ///
  /// In en, this message translates to:
  /// **'Track your spiritual, physical, mental, and relational habits with ease.'**
  String get featureHabitTrackingDesc;

  /// Feature: Bible Reading
  ///
  /// In en, this message translates to:
  /// **'Bible Reading'**
  String get featureBibleReading;

  /// Feature description: Bible Reading
  ///
  /// In en, this message translates to:
  /// **'Access the complete Bible with bookmarking and verse-saving capabilities.'**
  String get featureBibleReadingDesc;

  /// Feature: Daily Devotionals
  ///
  /// In en, this message translates to:
  /// **'Daily Devotionals'**
  String get featureDailyDevotionals;

  /// Feature description: Daily Devotionals
  ///
  /// In en, this message translates to:
  /// **'Receive daily spiritual reflections to inspire and guide you.'**
  String get featureDailyDevotionalsDesc;

  /// Feature: AI Coach
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Habit Coach'**
  String get featureAiCoach;

  /// Feature description: AI Coach
  ///
  /// In en, this message translates to:
  /// **'Get personalized micro-habits generated based on your goals.'**
  String get featureAiCoachDesc;

  /// Contact Us section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Contact Us text
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you! Your feedback helps us improve and serve you better.'**
  String get contactUsText;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Footer text
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Develop4God\n \nFor the Glory of God'**
  String get madeWithLove;

  /// No description provided for @faithJourney.
  ///
  /// In en, this message translates to:
  /// **'Faith Journey'**
  String get faithJourney;

  /// No description provided for @faithJourneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your progress, earn faith points, and unlock badges!'**
  String get faithJourneyDescription;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get startTimer;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer Running'**
  String get timerRunning;

  /// No description provided for @timeToFocus.
  ///
  /// In en, this message translates to:
  /// **'Time to Focus'**
  String get timeToFocus;

  /// No description provided for @focusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus session complete!'**
  String get focusComplete;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached!'**
  String get goalReached;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;
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
    'that was used.',
  );
}
