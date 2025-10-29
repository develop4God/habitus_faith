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
      'Failed to save habits. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

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
}
