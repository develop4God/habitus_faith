import 'dart:async' show unawaited;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/landing_page.dart';
import 'core/config/env_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/ml/model_updater.dart';
import 'features/habits/presentation/onboarding/adaptive_onboarding_page.dart';
import 'features/habits/data/storage/json_storage_service.dart';
import 'features/habits/data/storage/json_habits_repository.dart';
import 'features/habits/data/storage/storage_providers.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Directorio de trabajo actual: ${Directory.current.path}');

  // Manejo de error para dotenv con ruta relativa
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Archivo .env cargado correctamente desde ruta relativa');
  } catch (e) {
    debugPrint(
        'Advertencia: No se pudo cargar el archivo .env en la raíz del proyecto. Error: ${e.runtimeType} - ${e.toString()}');
    debugPrint(
        'Ejecuta Flutter desde la raíz del proyecto y verifica que el archivo .env esté junto a pubspec.yaml, sin extensión oculta y con permisos de lectura.');
  }

  // Load environment configuration before Firebase
  await EnvConfig.load();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize core services for synchronous overrides
  final prefs = await SharedPreferences.getInstance();
  final storageService = JsonStorageService(prefs);
  const userId = 'local_user';
  final firestore = FirebaseFirestore.instance;
  final habitsRepository = JsonHabitsRepository(
    storage: storageService,
    userId: userId,
    idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
    firestore: firestore,
  );

  // Non-blocking ML model update check
  unawaited(ModelUpdater().checkAndUpdateModel());

  runApp(
    ProviderScope(
      overrides: [
        // Only override synchronous services
        sharedPreferencesProvider.overrideWithValue(prefs),
        jsonStorageServiceProvider.overrideWithValue(storageService),
        jsonHabitsRepositoryProvider.overrideWithValue(habitsRepository),
        // Async providers (geminiService, bibleDbService) initialize themselves
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInit = ref.watch(authInitProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);
    final currentLocale = ref.watch(appLanguageProvider);

    // Initialize notification service
    ref.watch(notificationInitProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('fr', ''),
        Locale('pt', ''),
        Locale('zh', ''),
      ],
      routes: {
        '/home': (context) => const HomePage(),
        '/onboarding': (context) => const AdaptiveOnboardingPage(),
        '/habits': (context) =>
            const HomePage(), // ← Agregado para solucionar el error de ruta
      },
      home: authInit.when(
        data: (_) {
          if (onboardingComplete) {
            return const LandingPage();
          }
          return const AdaptiveOnboardingPage();
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}
