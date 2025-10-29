// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Habitus Foi';

  @override
  String get start => 'Commencer';

  @override
  String get readBible => 'Lire la Bible';

  @override
  String get myHabits => 'Mes Habitudes';

  @override
  String get noHabits => 'Pas encore d\'habitudes';

  @override
  String get streak => 'Série';

  @override
  String get days => 'jours';

  @override
  String get best => 'Meilleur';

  @override
  String get addHabit => 'Ajouter Habitude';

  @override
  String get deleteHabit => 'Supprimer Habitude';

  @override
  String deleteHabitConfirm(String habitName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$habitName\"?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get name => 'Nom';

  @override
  String get description => 'Description';

  @override
  String get add => 'Ajouter';

  @override
  String get welcomeToHabitusFaith => 'Bienvenue à Habitus Foi';

  @override
  String get selectUpToThreeHabits =>
      'Sélectionnez jusqu\'à 3 habitudes pour commencer votre voyage';

  @override
  String get continueButton => 'Continuer';

  @override
  String get selectAtLeastOne => 'Veuillez sélectionner au moins une habitude';

  @override
  String get maxThreeHabits => 'Vous pouvez sélectionner jusqu\'à 3 habitudes';

  @override
  String get spiritual => 'Spirituel';

  @override
  String get physical => 'Physique';

  @override
  String get mental => 'Mental';

  @override
  String get relational => 'Relationnel';

  @override
  String get habitCompleted => 'Habitude terminée! 🎉';

  @override
  String get tapToComplete => 'Appuyez pour terminer';

  @override
  String get completed => 'Terminé';

  @override
  String get currentStreak => 'Série Actuelle';

  @override
  String get longestStreak => 'Meilleure Série';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get predefinedHabit_morningPrayer_name => 'Prière Matinale';

  @override
  String get predefinedHabit_morningPrayer_description =>
      'Commencez votre journée avec la prière et la gratitude';

  @override
  String get predefinedHabit_bibleReading_name => 'Lecture Biblique';

  @override
  String get predefinedHabit_bibleReading_description =>
      'Lisez et méditez la Parole de Dieu quotidiennement';

  @override
  String get predefinedHabit_worship_name => 'Adoration';

  @override
  String get predefinedHabit_worship_description =>
      'Passez du temps en adoration et louange';

  @override
  String get predefinedHabit_gratitude_name => 'Journal de Gratitude';

  @override
  String get predefinedHabit_gratitude_description =>
      'Écrivez ce dont vous êtes reconnaissant';

  @override
  String get predefinedHabit_exercise_name => 'Exercice';

  @override
  String get predefinedHabit_exercise_description =>
      'Prenez soin de votre corps, temple de Dieu';

  @override
  String get predefinedHabit_healthyEating_name => 'Alimentation Saine';

  @override
  String get predefinedHabit_healthyEating_description =>
      'Nourrissez votre corps avec des aliments sains';

  @override
  String get predefinedHabit_sleep_name => 'Sommeil de Qualité';

  @override
  String get predefinedHabit_sleep_description =>
      'Dormez bien pour vous ressourcer';

  @override
  String get predefinedHabit_meditation_name => 'Méditation';

  @override
  String get predefinedHabit_meditation_description =>
      'Pratiquez la pleine conscience et la réflexion';

  @override
  String get predefinedHabit_learning_name => 'Apprentissage';

  @override
  String get predefinedHabit_learning_description =>
      'Grandissez en connaissance et sagesse';

  @override
  String get predefinedHabit_creativity_name => 'Temps Créatif';

  @override
  String get predefinedHabit_creativity_description =>
      'Exprimez-vous à travers des activités créatives';

  @override
  String get predefinedHabit_familyTime_name => 'Temps en Famille';

  @override
  String get predefinedHabit_familyTime_description =>
      'Passez du temps de qualité avec vos proches';

  @override
  String get predefinedHabit_service_name => 'Actes de Service';

  @override
  String get predefinedHabit_service_description =>
      'Servez les autres avec amour et compassion';

  @override
  String get onboardingErrorMessage =>
      'Failed to save habits. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

  @override
  String get category => 'Catégorie';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get emoji => 'Emoji';

  @override
  String get color => 'Couleur';

  @override
  String get optional => 'optionnel';

  @override
  String get edit => 'Modifier';

  @override
  String get uncheck => 'Décocher';

  @override
  String get save => 'Enregistrer';

  @override
  String get editHabit => 'Modifier l\'Habitude';

  @override
  String get defaultColor => 'Par défaut';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Paramètres de Notification';

  @override
  String get languageSettings => 'Paramètres de Langue';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get languageInfo =>
      'L\'application utilisera la langue sélectionnée pour tous les textes et éléments d\'interface.';

  @override
  String get notificationsEnabled => 'Notifications activées';

  @override
  String get notificationsDisabled => 'Notifications désactivées';

  @override
  String get notificationTimeUpdated => 'Heure de notification mise à jour à';

  @override
  String get enableNotifications => 'Activer les Notifications';

  @override
  String get notificationsOn => 'Notifications Activées';

  @override
  String get notificationsOff => 'Notifications Désactivées';

  @override
  String get receiveReminderNotifications =>
      'Recevoir des notifications de rappel quotidien';

  @override
  String get notificationTime => 'Heure de Notification';

  @override
  String get selectNotificationTime => 'Sélectionner l\'heure de notification';

  @override
  String get currentTime => 'Heure actuelle';

  @override
  String get notificationInfo =>
      'Vous recevrez un rappel quotidien à l\'heure sélectionnée pour compléter vos habitudes.';

  @override
  String get highRiskWarning =>
      'Risque élevé d\'abandonner cette habitude aujourd\'hui !';

  @override
  String riskPercentage(int percent) {
    return '$percent% de probabilité d\'abandon';
  }

  @override
  String get completeNow => 'Terminer Maintenant';
}
