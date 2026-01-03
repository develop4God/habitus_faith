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
  String get readBible => 'Bible';

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
  String get onboardingWelcomeMessage =>
      'Nous vous aiderons à personnaliser vos premières routines selon vos préférences.';

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
      'Échec de la sauvegarde des habitudes. Veuillez réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get selected => 'Sélectionné';

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

  @override
  String abandonmentNudgeTitle(String habitName) {
    return 'Réduire l\'habitude \"$habitName\"?';
  }

  @override
  String abandonmentNudgeBody(int minutes) {
    return 'Réduire à ${minutes}min? Nous avons remarqué que vous pourriez abandonner cette habitude';
  }

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get versesSaved => 'Versets sauvegardés';

  @override
  String get loadingBooks => 'Chargement des livres...';

  @override
  String get selectBook => 'Sélectionner un Livre';

  @override
  String get selectBookAndChapter => 'Sélectionnez un livre et un chapitre';

  @override
  String get habitsCompleted => 'Habitudes complétées:';

  @override
  String habitsCompletedCount(int completed, int total) {
    return '$completed sur $total';
  }

  @override
  String error(String message) {
    return 'Erreur: $message';
  }

  @override
  String get generateMicroHabits => 'Générer des Micro-Habitudes';

  @override
  String get aiGeneratedHabits => 'Habitudes Générées Automatiquement';

  @override
  String get yourGoal => 'Votre Objectif';

  @override
  String get goalHint =>
      'Que souhaitez-vous améliorer? (ex: Prier plus régulièrement)';

  @override
  String get goalRequired => 'Veuillez saisir votre objectif';

  @override
  String get goalTooShort => 'L\'objectif doit contenir au moins 10 caractères';

  @override
  String get goalTooLong => 'L\'objectif ne peut pas dépasser 200 caractères';

  @override
  String get failurePattern => 'Quand échouez-vous généralement? (Facultatif)';

  @override
  String get failurePatternHint => 'ex: J\'oublie pendant les matins occupés';

  @override
  String get generateHabits => 'Générer des Habitudes';

  @override
  String get generating => 'Génération...';

  @override
  String get generatingHabits =>
      'Génération de micro-habitudes personnalisées pour vous...';

  @override
  String get generatedHabitsTitle => 'Vos Micro-Habitudes Personnalisées';

  @override
  String get selectHabitsToAdd =>
      'Sélectionnez les habitudes à ajouter à votre suivi:';

  @override
  String get saveSelected => 'Enregistrer la Sélection';

  @override
  String get saving => 'Enregistrement...';

  @override
  String habitsAdded(int count) {
    return '$count habitude(s) ajoutée(s) avec succès!';
  }

  @override
  String estimatedTime(int minutes) {
    return '~$minutes min';
  }

  @override
  String get bibleVerse => 'Verset Biblique';

  @override
  String get purpose => 'Objectif';

  @override
  String remaining(int count) {
    return '$count restant(s)';
  }

  @override
  String monthlyLimit(int limit) {
    return 'Limite mensuelle: $limit générations';
  }

  @override
  String get rateLimitReached =>
      'Limite mensuelle atteinte. Réessayez le mois prochain.';

  @override
  String get generationFailed =>
      'Échec de la génération d\'habitudes. Veuillez réessayer.';

  @override
  String get apiTimeout =>
      'Délai d\'attente dépassé. Vérifiez votre connexion et réessayez.';

  @override
  String get invalidInput =>
      'Entrée invalide. Vérifiez votre objectif et réessayez.';

  @override
  String get noHabitsSelected =>
      'Veuillez sélectionner au moins une habitude à enregistrer';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String generationsRemaining(int count) {
    return '$count génération(s) restante(s) ce mois';
  }

  @override
  String get poweredByGemini => 'Propulsé par Gemini AI';

  @override
  String get chooseYourExperience => 'Choisissez votre expérience';

  @override
  String get displayModeDescription =>
      'Sélectionnez comment vous souhaitez utiliser Habitus Faith';

  @override
  String get compactMode => 'Mode compact';

  @override
  String get compactModeDescription =>
      'Fonctionnalités essentielles pour le suivi quotidien des habitudes';

  @override
  String get compactModeFeature1 => 'Interface épurée et minimaliste';

  @override
  String get compactModeFeature2 => 'Suivi rapide des habitudes';

  @override
  String get compactModeFeature3 => 'Statistiques de base';

  @override
  String get advancedMode => 'Mode avancé';

  @override
  String get advancedModeDescription =>
      'Expérience complète avec analyses et perspectives';

  @override
  String get advancedModeFeature1 => 'Analyses détaillées des habitudes';

  @override
  String get advancedModeFeature2 => 'Informations avancées et personnalisées.';

  @override
  String get advancedModeFeature3 => 'Personnalisation avancée';

  @override
  String get changeAnytime =>
      'Vous pouvez modifier ce paramètre à tout moment dans les préférences';

  @override
  String get selectMode => 'Sélectionner le mode';

  @override
  String get displayMode => 'Mode d\'affichage';

  @override
  String displayModeUpdated(String mode) {
    return 'Mode d\'affichage mis à jour vers $mode';
  }

  @override
  String get compactModeSubtitle => 'Liste compacte - appuyez pour les détails';

  @override
  String get advancedModeSubtitle => 'Suivi complet visible';

  @override
  String get addManually => 'Ajouter Manuellement';

  @override
  String get createCustomHabit => 'Créer une habitude personnalisée';

  @override
  String get generateWithAI => 'Générer automatiquement';

  @override
  String get aiCustomHabits => 'Habitudes personnalisées automatiquement';

  @override
  String get previewHabitName => 'Nom de l\'habitude';

  @override
  String get previewHabitDescription => 'Description de l\'habitude';

  @override
  String get total => 'Total';

  @override
  String get mlPredictionFailed =>
      'Impossible de calculer le risque d\'abandon';

  @override
  String get mlModelNotLoaded =>
      'Modèle de prédiction indisponible. Veuillez redémarrer l\'application.';

  @override
  String mlInsufficientData(int days) {
    return 'Besoin d\'au moins $days jours de données pour les prédictions';
  }

  @override
  String backgroundSyncFailed(String reason) {
    return 'Échec de la synchronisation: $reason';
  }

  @override
  String get backgroundSyncNetwork =>
      'Pas de connexion Internet. Les modifications seront synchronisées en ligne.';

  @override
  String get backgroundSyncPermission =>
      'Synchronisation en arrière-plan désactivée. Activer dans les paramètres.';

  @override
  String get workmanagerActive => 'Synchronisation en arrière-plan active';

  @override
  String get workmanagerRestricted =>
      'La synchronisation en arrière-plan peut être limitée par l\'optimisation de la batterie';

  @override
  String get workmanagerDisabled =>
      'Synchronisation en arrière-plan désactivée dans les paramètres système';

  @override
  String get patternWeekend =>
      'Vous avez tendance à sauter les week-ends. Essayer de définir un rappel?';

  @override
  String get patternEvening =>
      'Le taux de complétion le soir est faible. Envisager des habitudes matinales?';

  @override
  String optimalTimeFound(String time) {
    return 'Votre meilleur moment de complétion est $time';
  }

  @override
  String get networkTimeout =>
      'Délai d\'attente dépassé. Vérifiez votre connexion.';

  @override
  String get firebasePermissionDenied =>
      'Accès refusé. Veuillez vous reconnecter.';

  @override
  String get errorUnknown =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get devBannerTitle => 'Outils de Développement';

  @override
  String devBannerLastSync(String time) {
    return 'Dernière synchro: $time';
  }

  @override
  String devBannerMlStatus(String status) {
    return 'Modèle ML: $status';
  }

  @override
  String devBannerWorkmanager(String status) {
    return 'Arrière-plan: $status';
  }

  @override
  String devBannerFastTime(String multiplier, String date) {
    return 'Temps: ${multiplier}x (Simulé: $date)';
  }

  @override
  String get riskLevelLow => 'Risque faible';

  @override
  String get riskLevelMedium => 'Risque moyen';

  @override
  String get riskLevelHigh => 'Risque élevé';

  @override
  String get predictorRunning => 'Analyse des habitudes...';

  @override
  String get predictorComplete => 'Analyse terminée';

  @override
  String get syncInProgress => 'Synchronisation...';

  @override
  String get syncComplete => 'Synchronisation terminée';

  @override
  String get mlModelLoaded => 'Chargé';

  @override
  String get mlModelLoading => 'Chargement...';

  @override
  String get mlModelError => 'Erreur';

  @override
  String get chooseHabitType =>
      'Quel type d\'habitude souhaitez-vous ajouter ?';

  @override
  String get chooseFromPredefined => 'Choisissez une habitude prédéfinie';

  @override
  String get manual => 'Manuel';

  @override
  String get custom => 'Personnalisé';

  @override
  String get defaultHabit => 'Prédéfini';

  @override
  String get addHabitDiscoverySubtitle =>
      'Choisissez comment ajouter votre nouvelle habitude : créez-en une personnalisée ou sélectionnez une habitude prédéfinie pour commencer plus rapidement.';

  @override
  String get requiredFieldLabel => 'Obligatoire';

  @override
  String get back => 'Retour';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get copy => 'Dupliquer';

  @override
  String get copyHabit => 'Voulez-vous dupliquer la tâche ?';

  @override
  String copyHabitConfirm(String habitName) {
    return 'Êtes-vous sûr de vouloir dupliquer \"$habitName\" ?';
  }

  @override
  String get introMessage =>
      'Les plus grands changements commencent par la constance...';

  @override
  String get usefulTip => 'Astuce utile';

  @override
  String get habitsTip =>
      'Faites glisser pour voir les actions sur vos habitudes';

  @override
  String get understood => 'Compris';

  @override
  String get bible => 'Bible';

  @override
  String get home => 'Accueil';

  @override
  String get reminderConfig => 'FR: Reminder Configuration';

  @override
  String get recurrenceConfig => 'FR: Daily Repetitions';

  @override
  String get repeat => 'FR: Repeat';

  @override
  String get setCycleForPlan => 'FR: Set a cycle for your plan';

  @override
  String get subtasks => 'FR: Subtasks';

  @override
  String get addSubtask => 'FR: Add subtask';

  @override
  String get minutesBefore => 'FR: Minutes before';

  @override
  String get interval => 'FR: Interval';

  @override
  String get endDate => 'FR: End date';

  @override
  String get daily => 'FR: Daily';

  @override
  String get weekly => 'FR: Weekly';

  @override
  String get monthly => 'FR: Monthly';

  @override
  String everyXDays(int count) {
    return 'FR: Every $count day(s)';
  }

  @override
  String everyXWeeks(int count) {
    return 'FR: Every $count week(s)';
  }

  @override
  String everyXMonths(int count) {
    return 'FR: Every $count month(s)';
  }

  @override
  String get noRepetition => 'FR: No repetition';

  @override
  String get reminder => 'FR: Reminder';

  @override
  String get repetition => 'FR: Repetition';

  @override
  String get eventTime => 'FR: Event time (HH:MM)';

  @override
  String get invalidMinutes =>
      'FR: Please enter a valid number between 1 and 1440';

  @override
  String get invalidInterval => 'FR: Interval must be at least 1';

  @override
  String get habitTracking => 'Suivi des Habitudes';

  @override
  String get routine => 'Routine';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get morning_prayer => 'Prière du Matin';

  @override
  String get bible_reading => 'Lecture Biblique';

  @override
  String get evening_prayer => 'Prière du Soir';

  @override
  String get worship_music => 'Musique de Louange';

  @override
  String get gratitude_journal => 'Journal de Gratitude';

  @override
  String get scripture_meditation => 'Méditation Scripturaire';

  @override
  String get fasting => 'Jeûne';

  @override
  String get serve_others => 'Servir les Autres';

  @override
  String get bible_study_group => 'Groupe d\'Étude Biblique';

  @override
  String get prayer_walk => 'Marche de Prière';

  @override
  String get scripture_memorization => 'Mémorisation des Écritures';

  @override
  String get intercessory_prayer => 'Prière d\'Intercession';

  @override
  String get devotional_reading => 'Lecture Dévotionnelle';

  @override
  String get confession_repentance => 'Confession et Repentance';

  @override
  String get praise_thanksgiving => 'Louange et Action de Grâces';

  @override
  String get sabbath_rest => 'Repos du Sabbat';

  @override
  String get digital_detox_prayer => 'Détox Numérique et Prière';

  @override
  String get christian_podcast => 'Podcast Chrétien';

  @override
  String get family_devotion => 'Dévotion Familiale';

  @override
  String get spiritual_reading => 'Lecture Spirituelle';

  @override
  String get daily_walk => 'Marche Quotidienne';

  @override
  String get morning_exercise => 'Exercice Matinal';

  @override
  String get yoga_stretching => 'Étirements';

  @override
  String get healthy_breakfast => 'Petit-déjeuner Sain';

  @override
  String get hydration_routine => 'Routine d\'Hydratation';

  @override
  String get running_jogging => 'Course à Pied';

  @override
  String get strength_training => 'Musculation';

  @override
  String get bike_cycling => 'Cyclisme';

  @override
  String get healthy_meal_prep => 'Préparation de Repas Sains';

  @override
  String get swimming => 'Natation';

  @override
  String get dance_movement => 'Danse/Mouvement';

  @override
  String get sports_recreation => 'Sports/Loisirs';

  @override
  String get posture_breaks => 'Pauses Posturales';

  @override
  String get outdoor_nature => 'Temps en Plein Air/Nature';

  @override
  String get evening_walk => 'Marche du Soir';

  @override
  String get mindfulness_meditation => 'Méditation de Pleine Conscience';

  @override
  String get journaling => 'Tenir un Journal';

  @override
  String get deep_work_focus => 'Travail Profond/Concentration';

  @override
  String get reading_learning => 'Lecture/Apprentissage';

  @override
  String get digital_detox => 'Détox Numérique';

  @override
  String get planning_review => 'Planification et Révision';

  @override
  String get breathing_exercises => 'Exercices de Respiration';

  @override
  String get creative_hobby => 'Loisir Créatif';

  @override
  String get call_friend_family => 'Appeler un Ami/la Famille';

  @override
  String get quality_time_loved_ones => 'Temps de Qualité avec les Proches';
}
