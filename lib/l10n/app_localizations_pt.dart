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
  String get readBible => 'Bíblia';

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
  String get onboardingWelcomeMessage => 'PT: Welcome message';

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
  String get longestStreak => 'Sequência\nMais Longa';

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
      'Falha ao salvar os hábitos. Por favor, tente novamente.';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get selected => 'Selecionado';

  @override
  String get category => 'Categoria';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get emoji => 'Emoji';

  @override
  String get color => 'Cor';

  @override
  String get optional => 'opcional';

  @override
  String get edit => 'Editar';

  @override
  String get uncheck => 'Desmarcar';

  @override
  String get save => 'Salvar';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get defaultColor => 'Padrão';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationSettings => 'Configurações de Notificação';

  @override
  String get languageSettings => 'Configurações de Idioma';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get languageInfo =>
      'O aplicativo usará o idioma selecionado para todo o texto e elementos da interface.';

  @override
  String get notificationsEnabled => 'Notificações ativadas';

  @override
  String get notificationsDisabled => 'Notificações desativadas';

  @override
  String get notificationTimeUpdated =>
      'Horário de notificação atualizado para';

  @override
  String get enableNotifications => 'Ativar Notificações';

  @override
  String get notificationsOn => 'Notificações Ativadas';

  @override
  String get notificationsOff => 'Notificações Desativadas';

  @override
  String get receiveReminderNotifications =>
      'Receber notificações de lembrete diário';

  @override
  String get notificationTime => 'Horário de Notificação';

  @override
  String get selectNotificationTime => 'Selecionar horário de notificação';

  @override
  String get currentTime => 'Horário atual';

  @override
  String get notificationInfo =>
      'Você receberá um lembrete diário no horário selecionado para completar seus hábitos.';

  @override
  String get highRiskWarning => 'Alto risco de abandonar este hábito hoje!';

  @override
  String riskPercentage(int percent) {
    return '$percent% de probabilidade de abandono';
  }

  @override
  String get completeNow => 'Completar Agora';

  @override
  String abandonmentNudgeTitle(String habitName) {
    return 'Reduzir hábito \"$habitName\"?';
  }

  @override
  String abandonmentNudgeBody(int minutes) {
    return 'Reduzir para ${minutes}min? Notamos que você pode abandonar este hábito';
  }

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get versesSaved => 'Versículos salvos';

  @override
  String get loadingBooks => 'Carregando livros...';

  @override
  String get selectBook => 'Selecionar Livro';

  @override
  String get selectBookAndChapter => 'Selecione um livro e capítulo';

  @override
  String get habitsCompleted => 'Hábitos concluídos:';

  @override
  String habitsCompletedCount(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String error(String message) {
    return 'Erro: $message';
  }

  @override
  String get generateMicroHabits => 'Gerar Micro-Hábitos';

  @override
  String get aiGeneratedHabits => 'Hábitos Gerados Automaticamente';

  @override
  String get yourGoal => 'Sua Meta';

  @override
  String get goalHint =>
      'O que você gostaria de melhorar? (ex: Orar mais consistentemente)';

  @override
  String get goalRequired => 'Por favor insira sua meta';

  @override
  String get goalTooShort => 'A meta deve ter pelo menos 10 caracteres';

  @override
  String get goalTooLong => 'A meta não pode exceder 200 caracteres';

  @override
  String get failurePattern => 'Quando você costuma falhar? (Opcional)';

  @override
  String get failurePatternHint => 'ex: Esqueço nas manhãs ocupadas';

  @override
  String get generateHabits => 'Gerar Hábitos';

  @override
  String get generating => 'Gerando...';

  @override
  String get generatingHabits =>
      'Gerando micro-hábitos personalizados para você...';

  @override
  String get generatedHabitsTitle => 'Seus Micro-Hábitos Personalizados';

  @override
  String get selectHabitsToAdd =>
      'Selecione hábitos para adicionar ao seu rastreamento:';

  @override
  String get saveSelected => 'Salvar Selecionados';

  @override
  String get saving => 'Salvando...';

  @override
  String habitsAdded(int count) {
    return '$count hábito(s) adicionado(s) com sucesso!';
  }

  @override
  String estimatedTime(int minutes) {
    return '~$minutes min';
  }

  @override
  String get bibleVerse => 'Versículo Bíblico';

  @override
  String get purpose => 'Propósito';

  @override
  String remaining(int count) {
    return '$count restante(s)';
  }

  @override
  String monthlyLimit(int limit) {
    return 'Limite mensal: $limit gerações';
  }

  @override
  String get rateLimitReached =>
      'Limite mensal atingido. Tente novamente no próximo mês.';

  @override
  String get generationFailed =>
      'Falha ao gerar hábitos. Por favor tente novamente.';

  @override
  String get apiTimeout =>
      'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';

  @override
  String get invalidInput =>
      'Entrada inválida. Verifique sua meta e tente novamente.';

  @override
  String get noHabitsSelected =>
      'Por favor selecione pelo menos um hábito para salvar';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String generationsRemaining(int count) {
    return '$count geração(ões) restante(s) este mês';
  }

  @override
  String get poweredByGemini => 'Desenvolvido por Gemini AI';

  @override
  String get chooseYourExperience => 'Escolha sua experiência';

  @override
  String get displayModeDescription =>
      'Selecione como você deseja usar o Habitus Faith';

  @override
  String get compactMode => 'Modo compacto';

  @override
  String get compactModeDescription =>
      'Recursos essenciais para rastreamento diário de hábitos';

  @override
  String get compactModeFeature1 => 'Interface limpa e minimalista';

  @override
  String get compactModeFeature2 => 'Rastreamento rápido de hábitos';

  @override
  String get compactModeFeature3 => 'Estatísticas básicas';

  @override
  String get advancedMode => 'Modo avançado';

  @override
  String get advancedModeDescription =>
      'Experiência completa com análises e insights';

  @override
  String get advancedModeFeature1 => 'Análises detalhadas de hábitos';

  @override
  String get advancedModeFeature2 => 'Insights avançados e personalizados.';

  @override
  String get advancedModeFeature3 => 'Personalização avançada';

  @override
  String get changeAnytime =>
      'Você pode alterar esta configuração a qualquer momento nas preferências';

  @override
  String get selectMode => 'Selecionar modo';

  @override
  String get displayMode => 'Modo de exibição';

  @override
  String displayModeUpdated(String mode) {
    return 'Modo de exibição atualizado para $mode';
  }

  @override
  String get compactModeSubtitle => 'Lista compacta - toque para detalhes';

  @override
  String get advancedModeSubtitle => 'Rastreamento completo visível';

  @override
  String get addManually => 'Adicionar Manualmente';

  @override
  String get createCustomHabit => 'Criar um hábito personalizado';

  @override
  String get generateWithAI => 'Gerar automaticamente';

  @override
  String get aiCustomHabits => 'Hábitos personalizados automaticamente';

  @override
  String get previewHabitName => 'Nome do hábito';

  @override
  String get previewHabitDescription => 'Descrição do hábito';

  @override
  String get total => 'Total';

  @override
  String get mlPredictionFailed =>
      'Não foi possível calcular o risco de abandono';

  @override
  String get mlModelNotLoaded =>
      'Modelo de previsão indisponível. Por favor, reinicie o aplicativo.';

  @override
  String mlInsufficientData(int days) {
    return 'Precisa de pelo menos $days dias de dados para previsões';
  }

  @override
  String backgroundSyncFailed(String reason) {
    return 'Falha na sincronização: $reason';
  }

  @override
  String get backgroundSyncNetwork =>
      'Sem conexão com a internet. As alterações serão sincronizadas quando estiver online.';

  @override
  String get backgroundSyncPermission =>
      'Sincronização em segundo plano desativada. Ative nas configurações.';

  @override
  String get workmanagerActive => 'Sincronização em segundo plano ativa';

  @override
  String get workmanagerRestricted =>
      'A sincronização em segundo plano pode ser limitada pela otimização da bateria';

  @override
  String get workmanagerDisabled =>
      'Sincronização em segundo plano desativada nas configurações do sistema';

  @override
  String get patternWeekend =>
      'Você tende a pular os fins de semana. Tente definir um lembrete?';

  @override
  String get patternEvening =>
      'A taxa de conclusão à noite é baixa. Considere hábitos matinais?';

  @override
  String optimalTimeFound(String time) {
    return 'Seu melhor horário de conclusão é $time';
  }

  @override
  String get networkTimeout =>
      'Tempo de espera esgotado. Verifique sua conexão.';

  @override
  String get firebasePermissionDenied =>
      'Acesso negado. Por favor, faça login novamente.';

  @override
  String get errorUnknown =>
      'Ocorreu um erro inesperado. Por favor, tente novamente.';

  @override
  String get devBannerTitle => 'Ferramentas de Desenvolvimento';

  @override
  String devBannerLastSync(String time) {
    return 'Última sincronização: $time';
  }

  @override
  String devBannerMlStatus(String status) {
    return 'Modelo ML: $status';
  }

  @override
  String devBannerWorkmanager(String status) {
    return 'Segundo plano: $status';
  }

  @override
  String devBannerFastTime(String multiplier, String date) {
    return 'Tempo: ${multiplier}x (Simulado: $date)';
  }

  @override
  String get riskLevelLow => 'Risco baixo';

  @override
  String get riskLevelMedium => 'Risco médio';

  @override
  String get riskLevelHigh => 'Risco alto';

  @override
  String get predictorRunning => 'Analisando hábitos...';

  @override
  String get predictorComplete => 'Análise concluída';

  @override
  String get syncInProgress => 'Sincronizando...';

  @override
  String get syncComplete => 'Sincronização concluída';

  @override
  String get mlModelLoaded => 'Carregado';

  @override
  String get mlModelLoading => 'Carregando...';

  @override
  String get mlModelError => 'Erro';

  @override
  String get chooseHabitType => 'Que tipo de hábito você deseja adicionar?';

  @override
  String get chooseFromPredefined => 'Escolha um hábito predefinido';

  @override
  String get manual => 'Manual';

  @override
  String get custom => 'Personalizado';

  @override
  String get defaultHabit => 'Padrão';

  @override
  String get addHabitDiscoverySubtitle =>
      'Escolha como deseja adicionar seu novo hábito: você pode criar um personalizado ou selecionar um predefinido para começar mais rápido.';

  @override
  String get requiredFieldLabel => 'Obrigatório';

  @override
  String get back => 'Voltar';

  @override
  String get selectAll => 'Selecionar todos';

  @override
  String get copy => 'Duplicar';

  @override
  String get copyHabit => 'Deseja duplicar a tarefa?';

  @override
  String copyHabitConfirm(String habitName) {
    return 'Tem certeza de que deseja duplicar \"$habitName\"?';
  }

  @override
  String get introMessage => 'As maiores mudanças começam na constância...';

  @override
  String get todaysVerse => 'Versículo do Dia';

  @override
  String get todaysHabits => 'Hábitos de Hoje';

  @override
  String get allHabitsCompleted => '🎉 Todos os hábitos concluídos hoje!';

  @override
  String dayStreak(int count) {
    return 'Sequência de $count dias';
  }

  @override
  String get startJourney => 'Comece sua jornada hoje';

  @override
  String get buildConsistency => 'Vamos construir consistência hoje! 💪';

  @override
  String get greatProgress => 'Ótimo progresso! Continue assim! 🔥';

  @override
  String habitsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hábitos restantes hoje',
      one: '1 hábito restante hoje',
    );
    return '$_temp0';
  }

  @override
  String get weeklyConsistency => 'Consistência\nSemanal';

  @override
  String get swipeToComplete =>
      'Toque ou deslize para a esquerda para concluir';

  @override
  String get usefulTip => 'Dica útil';

  @override
  String get habitsTip => 'Deslize para ver ações nos seus hábitos';

  @override
  String get understood => 'Entendido';

  @override
  String get bible => 'Bíblia';

  @override
  String get home => 'Início';

  @override
  String get reminderConfig => 'PT: Reminder Config';

  @override
  String get recurrenceConfig => 'PT: Recurrence Config';

  @override
  String get repeat => 'PT: Repeat';

  @override
  String get setCycleForPlan => 'PT: Set Cycle For Plan';

  @override
  String get subtasks => 'PT: Subtasks';

  @override
  String get addSubtask => 'PT: Add Subtask';

  @override
  String get minutesBefore => 'PT: Minutes Before';

  @override
  String get interval => 'PT: Interval';

  @override
  String get endDate => 'PT: End Date';

  @override
  String get daily => 'PT: Daily';

  @override
  String get weekly => 'PT: Weekly';

  @override
  String get monthly => 'PT: Monthly';

  @override
  String everyXDays(int count) {
    return 'PT: Every X Days';
  }

  @override
  String everyXWeeks(int count) {
    return 'PT: Every X Weeks';
  }

  @override
  String everyXMonths(int count) {
    return 'PT: Every X Months';
  }

  @override
  String get noRepetition => 'PT: No Repetition';

  @override
  String get reminder => 'PT: Reminder';

  @override
  String get repetition => 'PT: Repetition';

  @override
  String get eventTime => 'PT: Event Time';

  @override
  String get invalidMinutes => 'PT: Invalid Minutes';

  @override
  String get invalidInterval => 'PT: Invalid Interval';

  @override
  String get habitTracking => 'PT: Habit Tracking';

  @override
  String get routine => 'Rotina';

  @override
  String get today => 'Hoje';

  @override
  String get morning_prayer => 'Morning Prayer';

  @override
  String get bible_reading => 'Bible Reading';

  @override
  String get evening_prayer => 'Evening Prayer';

  @override
  String get worship_music => 'Worship Music';

  @override
  String get gratitude_journal => 'Gratitude Journal';

  @override
  String get scripture_meditation => 'Scripture Meditation';

  @override
  String get fasting => 'Fasting';

  @override
  String get serve_others => 'Serve Others';

  @override
  String get bible_study_group => 'Bible Study Group';

  @override
  String get prayer_walk => 'Prayer Walk';

  @override
  String get scripture_memorization => 'Scripture Memorization';

  @override
  String get intercessory_prayer => 'Intercessory Prayer';

  @override
  String get devotional_reading => 'Devotional Reading';

  @override
  String get confession_repentance => 'Confession & Repentance';

  @override
  String get praise_thanksgiving => 'Praise & Thanksgiving';

  @override
  String get sabbath_rest => 'Sabbath Rest';

  @override
  String get digital_detox_prayer => 'Digital Detox & Prayer';

  @override
  String get christian_podcast => 'Christian Podcast';

  @override
  String get family_devotion => 'Family Devotion';

  @override
  String get spiritual_reading => 'Spiritual Reading';

  @override
  String get daily_walk => 'Daily Walk';

  @override
  String get morning_exercise => 'Morning Exercise';

  @override
  String get yoga_stretching => 'Yoga/Stretching';

  @override
  String get healthy_breakfast => 'Healthy Breakfast';

  @override
  String get hydration_routine => 'Hydration Routine';

  @override
  String get running_jogging => 'Running/Jogging';

  @override
  String get strength_training => 'Strength Training';

  @override
  String get bike_cycling => 'Biking/Cycling';

  @override
  String get healthy_meal_prep => 'Healthy Meal Prep';

  @override
  String get swimming => 'Swimming';

  @override
  String get dance_movement => 'Dance/Movement';

  @override
  String get sports_recreation => 'Sports/Recreation';

  @override
  String get posture_breaks => 'Posture Breaks';

  @override
  String get outdoor_nature => 'Outdoor/Nature Time';

  @override
  String get evening_walk => 'Evening Walk';

  @override
  String get mindfulness_meditation => 'Mindfulness Meditation';

  @override
  String get journaling => 'Journaling';

  @override
  String get deep_work_focus => 'Deep Work/Focus';

  @override
  String get reading_learning => 'Reading/Learning';

  @override
  String get digital_detox => 'Digital Detox';

  @override
  String get planning_review => 'Planning & Review';

  @override
  String get breathing_exercises => 'Breathing Exercises';

  @override
  String get creative_hobby => 'Creative Hobby';

  @override
  String get call_friend_family => 'Call Friend/Family';

  @override
  String get quality_time_loved_ones => 'Quality Time with Loved Ones';
}
