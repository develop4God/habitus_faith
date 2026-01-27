import 'dart:async' show unawaited;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/landing_page.dart';
import 'core/config/env_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/ml/model_updater.dart';

import 'features/habits/presentation/onboarding/simple_onboarding_flow.dart';
import 'features/habits/data/storage/json_storage_service.dart';
import 'features/habits/data/storage/json_habits_repository.dart';
import 'features/habits/data/storage/storage_providers.dart';
import 'l10n/app_localizations.dart';
import 'dev_tools/fast_time_banner.dart';
import 'features/developer/developer_debug_page.dart';
import 'providers/devotional_providers.dart';

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

  // Only for testing update logic: Upgrader.clearSavedSettings();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        jsonStorageServiceProvider.overrideWithValue(storageService),
        jsonHabitsRepositoryProvider.overrideWithValue(habitsRepository),
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

    ref.listen<Locale>(appLanguageProvider, (previous, next) {
      if (previous != null && previous.languageCode != next.languageCode) {
        ref.read(devotionalProvider.notifier).changeLanguage(next.languageCode);
      }
    });

    ref.watch(notificationInitProvider);

    // Reschedule habit notifications when app starts
    ref.watch(habitNotificationsSchedulerProvider);

    return WithFastTimeBanner(
      child: MaterialApp(
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
          '/onboarding': (context) => const SimpleOnboardingFlow(),
          '/habits': (context) => const HomePage(),
          '/devtools': (context) => const DeveloperDebugPage(),
        },
        home: UpgradeAlert(
          upgrader: Upgrader(
            appcastConfig: AppcastConfiguration(
              url: 'https://develop4god.github.io/habits-data/appcast.xml',
              supportedOS: ['android'],
            ),
            debugDisplayAlways: kDebugMode,
            durationUntilAlertAgain: const Duration(hours: 2),
            minAppVersion:
                '1.1.6+15', // Force update for any version below this
          ),
          child: Builder(
            builder: (context) {
              return authInit.when(
                data: (_) {
                  if (onboardingComplete) {
                    return Column(
                      children: [
                        const Expanded(child: LandingPage()),
                        FutureBuilder<String>(
                          future: _getAppVersion(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Versión: ${snapshot.data}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    );
                  }
                  return const SimpleOnboardingFlow();
                },
                loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator())),
                error: (error, stack) =>
                    Scaffold(body: Center(child: Text('Error: $error'))),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper to get app version from package_info_plus
Future<String> _getAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return "${info.version}+${info.buildNumber}";
}
