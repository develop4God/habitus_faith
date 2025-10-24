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
