// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Habitus Fe';

  @override
  String get start => 'Comenzar';

  @override
  String get readBible => 'Leer Biblia';

  @override
  String get myHabits => 'Mis Hábitos';

  @override
  String get noHabits => 'Aún no tienes hábitos';

  @override
  String get streak => 'Racha';

  @override
  String get days => 'días';

  @override
  String get best => 'Mejor';

  @override
  String get addHabit => 'Agregar Hábito';

  @override
  String get deleteHabit => 'Eliminar Hábito';

  @override
  String deleteHabitConfirm(String habitName) {
    return '¿Estás seguro de eliminar \"$habitName\"?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get add => 'Agregar';

  @override
  String get welcomeToHabitusFaith => 'Bienvenido a Habitus Fe';

  @override
  String get selectUpToThreeHabits =>
      'Selecciona hasta 3 hábitos para comenzar tu jornada';

  @override
  String get continueButton => 'Continuar';

  @override
  String get selectAtLeastOne => 'Por favor selecciona al menos un hábito';

  @override
  String get maxThreeHabits => 'Puedes seleccionar hasta 3 hábitos';

  @override
  String get spiritual => 'Espiritual';

  @override
  String get physical => 'Físico';

  @override
  String get mental => 'Mental';

  @override
  String get relational => 'Relacional';

  @override
  String get habitCompleted => '¡Hábito completado! 🎉';

  @override
  String get tapToComplete => 'Toca para completar';

  @override
  String get completed => 'Completado';

  @override
  String get currentStreak => 'Racha Actual';

  @override
  String get longestStreak => 'Mejor Racha';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get predefinedHabit_morningPrayer_name => 'Oración Matutina';

  @override
  String get predefinedHabit_morningPrayer_description =>
      'Comienza tu día con oración y gratitud';

  @override
  String get predefinedHabit_bibleReading_name => 'Lectura Bíblica';

  @override
  String get predefinedHabit_bibleReading_description =>
      'Lee y medita en la Palabra de Dios diariamente';

  @override
  String get predefinedHabit_worship_name => 'Adoración';

  @override
  String get predefinedHabit_worship_description =>
      'Dedica tiempo a la adoración y alabanza';

  @override
  String get predefinedHabit_gratitude_name => 'Diario de Gratitud';

  @override
  String get predefinedHabit_gratitude_description =>
      'Escribe por lo que estás agradecido';

  @override
  String get predefinedHabit_exercise_name => 'Ejercicio';

  @override
  String get predefinedHabit_exercise_description =>
      'Cuida tu cuerpo, templo de Dios';

  @override
  String get predefinedHabit_healthyEating_name => 'Alimentación Saludable';

  @override
  String get predefinedHabit_healthyEating_description =>
      'Nutre tu cuerpo con alimentos sanos';

  @override
  String get predefinedHabit_sleep_name => 'Sueño de Calidad';

  @override
  String get predefinedHabit_sleep_description =>
      'Descansa bien para recargar energías';

  @override
  String get predefinedHabit_meditation_name => 'Meditación';

  @override
  String get predefinedHabit_meditation_description =>
      'Practica atención plena y reflexión';

  @override
  String get predefinedHabit_learning_name => 'Aprendizaje';

  @override
  String get predefinedHabit_learning_description =>
      'Crece en conocimiento y sabiduría';

  @override
  String get predefinedHabit_creativity_name => 'Tiempo Creativo';

  @override
  String get predefinedHabit_creativity_description =>
      'Exprésate a través de actividades creativas';

  @override
  String get predefinedHabit_familyTime_name => 'Tiempo en Familia';

  @override
  String get predefinedHabit_familyTime_description =>
      'Pasa tiempo de calidad con tus seres queridos';

  @override
  String get predefinedHabit_service_name => 'Actos de Servicio';

  @override
  String get predefinedHabit_service_description =>
      'Sirve a otros con amor y compasión';

  @override
  String get onboardingErrorMessage =>
      'Error al guardar los hábitos. Por favor, inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get category => 'Categoría';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get emoji => 'Emoji';

  @override
  String get color => 'Color';

  @override
  String get optional => 'opcional';

  @override
  String get edit => 'Editar';

  @override
  String get uncheck => 'Desmarcar';

  @override
  String get save => 'Guardar';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get defaultColor => 'Por defecto';

  @override
  String get statistics => 'Progreso';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettings => 'Configuración de Notificaciones';

  @override
  String get languageSettings => 'Configuración de Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get languageInfo =>
      'La aplicación usará el idioma seleccionado para todo el texto y elementos de la interfaz.';

  @override
  String get notificationsEnabled => 'Notificaciones activadas';

  @override
  String get notificationsDisabled => 'Notificaciones desactivadas';

  @override
  String get notificationTimeUpdated => 'Hora de notificación actualizada a';

  @override
  String get enableNotifications => 'Activar Notificaciones';

  @override
  String get notificationsOn => 'Notificaciones Activadas';

  @override
  String get notificationsOff => 'Notificaciones Desactivadas';

  @override
  String get receiveReminderNotifications =>
      'Recibir notificaciones de recordatorio diario';

  @override
  String get notificationTime => 'Hora de Notificación';

  @override
  String get selectNotificationTime => 'Seleccionar hora de notificación';

  @override
  String get currentTime => 'Hora actual';

  @override
  String get notificationInfo =>
      'Recibirás un recordatorio diario a la hora seleccionada para completar tus hábitos.';

  @override
  String get highRiskWarning => '¡Alto riesgo de abandonar este hábito hoy!';

  @override
  String riskPercentage(int percent) {
    return '$percent% probabilidad de abandono';
  }

  @override
  String get completeNow => 'Completar Ahora';

  @override
  String abandonmentNudgeTitle(String habitName) {
    return '¿Reducir hábito \"$habitName\"?';
  }

  @override
  String abandonmentNudgeBody(int minutes) {
    return '¿Reducimos a ${minutes}min? Notamos que podrías abandonar este hábito';
  }

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get versesSaved => 'Versículos guardados';

  @override
  String get loadingBooks => 'Cargando libros...';

  @override
  String get selectBook => 'Seleccionar Libro';

  @override
  String get selectBookAndChapter => 'Selecciona un libro y capítulo';

  @override
  String get habitsCompleted => 'Hábitos completados:';

  @override
  String habitsCompletedCount(int completed, int total) {
    return '$completed de $total';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get generateMicroHabits => 'Generar Micro-Hábitos';

  @override
  String get aiGeneratedHabits => 'Hábitos Generados por IA';

  @override
  String get yourGoal => 'Tu Meta';

  @override
  String get goalHint =>
      '¿Qué te gustaría mejorar? (ej: Orar más consistentemente)';

  @override
  String get goalRequired => 'Por favor ingresa tu meta';

  @override
  String get goalTooShort => 'La meta debe tener al menos 10 caracteres';

  @override
  String get goalTooLong => 'La meta no puede exceder 200 caracteres';

  @override
  String get failurePattern => '¿Cuándo sueles fallar? (Opcional)';

  @override
  String get failurePatternHint => 'ej: Olvido en las mañanas ocupadas';

  @override
  String get generateHabits => 'Generar Hábitos';

  @override
  String get generating => 'Generando...';

  @override
  String get generatingHabits =>
      'Generando micro-hábitos personalizados para ti...';

  @override
  String get generatedHabitsTitle => 'Tus Micro-Hábitos Personalizados';

  @override
  String get selectHabitsToAdd =>
      'Selecciona hábitos para agregar a tu seguimiento:';

  @override
  String get saveSelected => 'Guardar Seleccionados';

  @override
  String get saving => 'Guardando...';

  @override
  String habitsAdded(int count) {
    return '¡$count hábito(s) agregado(s) exitosamente!';
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
    return 'Límite mensual: $limit generaciones';
  }

  @override
  String get rateLimitReached =>
      'Límite mensual alcanzado. Intenta de nuevo el próximo mes.';

  @override
  String get generationFailed =>
      'Error al generar hábitos. Por favor intenta de nuevo.';

  @override
  String get apiTimeout =>
      'Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo.';

  @override
  String get invalidInput =>
      'Entrada inválida. Verifica tu meta e intenta de nuevo.';

  @override
  String get noHabitsSelected =>
      'Por favor selecciona al menos un hábito para guardar';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String generationsRemaining(int count) {
    return '$count generación(es) restante(s) este mes';
  }

  @override
  String get poweredByGemini => 'Desarrollado por Gemini AI';

  @override
  String get chooseYourExperience => 'Elige tu experiencia';

  @override
  String get displayModeDescription =>
      'Selecciona cómo quieres usar Habitus Faith';

  @override
  String get compactMode => 'Modo compacto';

  @override
  String get compactModeDescription =>
      'Funciones esenciales para el seguimiento diario de hábitos';

  @override
  String get compactModeFeature1 => 'Interfaz limpia y minimalista';

  @override
  String get compactModeFeature2 => 'Seguimiento rápido de hábitos';

  @override
  String get compactModeFeature3 => 'Estadísticas básicas';

  @override
  String get advancedMode => 'Modo avanzado';

  @override
  String get advancedModeDescription =>
      'Experiencia completa con análisis y perspectivas';

  @override
  String get advancedModeFeature1 => 'Análisis detallados de hábitos';

  @override
  String get advancedModeFeature2 => 'Información impulsada por IA';

  @override
  String get advancedModeFeature3 => 'Personalización avanzada';

  @override
  String get changeAnytime =>
      'Puedes cambiar esta configuración en cualquier momento en las preferencias';

  @override
  String get selectMode => 'Seleccionar modo';

  @override
  String get displayMode => 'Modo de visualización';

  @override
  String displayModeUpdated(String mode) {
    return 'Modo de visualización actualizado a $mode';
  }

  @override
  String get compactModeSubtitle => 'Lista compacta - toca para ver detalles';

  @override
  String get advancedModeSubtitle => 'Seguimiento completo visible';

  @override
  String get addManually => 'Agregar Manualmente';

  @override
  String get createCustomHabit => 'Crear un hábito personalizado';

  @override
  String get generateWithAI => 'Generar con IA';

  @override
  String get aiCustomHabits => 'Hábitos personalizados con IA';

  @override
  String get previewHabitName => 'Nombre del hábito';

  @override
  String get previewHabitDescription => 'Descripción del hábito';

  @override
  String get total => 'Total';

  @override
  String get chooseHabitType => '¿Qué tipo de hábito quieres agregar?';

  @override
  String get chooseFromPredefined => 'Elige un hábito predefinido';

  @override
  String get manual => 'Manual';

  @override
  String get custom => 'Personalizado';

  @override
  String get defaultHabit => 'Predefinido';

  @override
  String get addHabitDiscoverySubtitle =>
      'Elige cómo quieres agregar tu nuevo hábito: puedes crear uno personalizado o seleccionar uno predefinido para empezar más rápido.';

  @override
  String get requiredFieldLabel => 'Obligatorio';

  @override
  String get back => 'Atrás';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get copy => 'Duplicar';

  @override
  String get copyHabit => '¿Deseas duplicar la tarea?';

  @override
  String copyHabitConfirm(String habitName) {
    return '¿Seguro que quieres duplicar \"$habitName\"?';
  }

  @override
  String get introMessage => 'Los mayores cambios, inician en la constancia...';

  @override
  String get usefulTip => 'Tip útil';

  @override
  String get habitsTip => 'Desliza para ver acciones en tus hábitos';

  @override
  String get understood => 'Entendido';
}
