// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Habitus Fé';

  @override
  String get start => 'Começar';

  @override
  String get readBible => 'Ler Bíblia';

  @override
  String get myHabits => 'Meus Hábitos';

  @override
  String get noHabits => 'Ainda não tem hábitos';

  @override
  String get streak => 'Sequência';

  @override
  String get days => 'dias';

  @override
  String get best => 'Melhor';

  @override
  String get addHabit => 'Adicionar Hábito';

  @override
  String get deleteHabit => 'Excluir Hábito';

  @override
  String deleteHabitConfirm(String habitName) {
    return 'Tem certeza de que deseja excluir \"$habitName\"?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrição';

  @override
  String get add => 'Adicionar';

  @override
  String get welcomeToHabitusFaith => 'Bem-vindo ao Habitus Fé';

  @override
  String get selectUpToThreeHabits =>
      'Selecione até 3 hábitos para começar sua jornada';

  @override
  String get continueButton => 'Continuar';

  @override
  String get selectAtLeastOne => 'Por favor, selecione pelo menos um hábito';

  @override
  String get maxThreeHabits => 'Você pode selecionar até 3 hábitos';

  @override
  String get spiritual => 'Espiritual';

  @override
  String get physical => 'Físico';

  @override
  String get mental => 'Mental';

  @override
  String get relational => 'Relacional';

  @override
  String get habitCompleted => 'Hábito concluído! 🎉';

  @override
  String get tapToComplete => 'Toque para completar';

  @override
  String get completed => 'Concluído';

  @override
  String get currentStreak => 'Sequência Atual';

  @override
  String get longestStreak => 'Melhor Sequência';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get predefinedHabit_morningPrayer_name => 'Oração Matinal';

  @override
  String get predefinedHabit_morningPrayer_description =>
      'Comece seu dia com oração e gratidão';

  @override
  String get predefinedHabit_bibleReading_name => 'Leitura Bíblica';

  @override
  String get predefinedHabit_bibleReading_description =>
      'Leia e medite na Palavra de Deus diariamente';

  @override
  String get predefinedHabit_worship_name => 'Adoração';

  @override
  String get predefinedHabit_worship_description =>
      'Passe tempo em adoração e louvor';

  @override
  String get predefinedHabit_gratitude_name => 'Diário de Gratidão';

  @override
  String get predefinedHabit_gratitude_description =>
      'Escreva pelo que você é grato';

  @override
  String get predefinedHabit_exercise_name => 'Exercício';

  @override
  String get predefinedHabit_exercise_description =>
      'Cuide do seu corpo, templo de Deus';

  @override
  String get predefinedHabit_healthyEating_name => 'Alimentação Saudável';

  @override
  String get predefinedHabit_healthyEating_description =>
      'Nutra seu corpo com alimentos saudáveis';

  @override
  String get predefinedHabit_sleep_name => 'Sono de Qualidade';

  @override
  String get predefinedHabit_sleep_description => 'Durma bem para recarregar';

  @override
  String get predefinedHabit_meditation_name => 'Meditação';

  @override
  String get predefinedHabit_meditation_description =>
      'Pratique atenção plena e reflexão';

  @override
  String get predefinedHabit_learning_name => 'Aprendizado';

  @override
  String get predefinedHabit_learning_description =>
      'Cresça em conhecimento e sabedoria';

  @override
  String get predefinedHabit_creativity_name => 'Tempo Criativo';

  @override
  String get predefinedHabit_creativity_description =>
      'Expresse-se através de atividades criativas';

  @override
  String get predefinedHabit_familyTime_name => 'Tempo em Família';

  @override
  String get predefinedHabit_familyTime_description =>
      'Passe tempo de qualidade com seus entes queridos';

  @override
  String get predefinedHabit_service_name => 'Atos de Serviço';

  @override
  String get predefinedHabit_service_description =>
      'Sirva aos outros com amor e compaixão';

  @override
  String get onboardingErrorMessage =>
      'Failed to save habits. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get notificationsOn => 'Notifications On';

  @override
  String get notificationsOff => 'Notifications Off';

  @override
  String get receiveReminderNotifications =>
      'Receive daily reminders for your habits';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get selectNotificationTime =>
      'Select your preferred notification time';

  @override
  String get currentTime => 'Current time';

  @override
  String get notificationTimeUpdated => 'Notification time updated to';

  @override
  String get notificationInfo =>
      'Notifications will help you stay on track with your daily habits. You\'ll receive reminders at your chosen time.';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';
}
