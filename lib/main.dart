import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'pages/home_page.dart';
import 'pages/landing_page.dart';
import 'core/config/env_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/background_task_service_provider.dart';
import 'core/services/ml/model_updater.dart';
import 'core/services/service_locator.dart';

import 'features/habits/presentation/onboarding/simple_onboarding_flow.dart';
import 'features/habits/data/storage/json_storage_service.dart';
import 'features/habits/data/storage/json_habits_repository.dart';
import 'features/habits/data/storage/storage_providers.dart';
import 'l10n/app_localizations.dart';
import 'dev_tools/fast_time_banner.dart';
import 'features/developer/developer_debug_page.dart';
import 'providers/devotional_providers.dart';

// Global ScaffoldMessenger key for showing snackbars from anywhere
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Performance tracking
  final startTime = DateTime.now();

  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 [Startup] App initialization started');

  // PHASE 1: Load critical resources in parallel
  final results = await Future.wait([
    _loadDotenv(),
    SharedPreferences.getInstance(),
    EnvConfig.load(),
  ]);

  final prefs = results[1] as SharedPreferences;

  // PHASE 1.5: Setup Service Locator for Dependency Injection
  setupServiceLocator();
  debugPrint('✅ [Startup] ServiceLocator initialized');

  // PHASE 2: Initialize core services synchronously (required before runApp)
  final storageService = JsonStorageService(prefs);
  const userId = 'local_user';

  // Create repository - Firestore will be injected later via provider
  final habitsRepository = JsonHabitsRepository(
    storage: storageService,
    userId: userId,
    idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
    firestore: null, // Will be set by provider when Firebase initializes
  );

  final initTime = DateTime.now().difference(startTime).inMilliseconds;
  debugPrint('✅ [Startup] Critical init complete in ${initTime}ms');

  // PHASE 3: Start the app immediately
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

  // PHASE 4: Schedule deferred initialization after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final totalTime = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('🎉 [Startup] First frame rendered in ${totalTime}ms');

    // Defer non-critical operations
    _scheduleDeferredInitialization();
  });
}

/// Load .env file with error handling
Future<void> _loadDotenv() async {
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('📄 [Config] .env loaded');
  } catch (e) {
    debugPrint('⚠️ [Config] .env not found (optional)');
  }
}

/// Schedule deferred initialization for non-critical features
void _scheduleDeferredInitialization() {
  // Use microtask to run after current frame but before next frame
  Future.microtask(() async {
    debugPrint('🔧 [Deferred] Starting background tasks');

    // Wait a bit to let UI settle
    await Future.delayed(const Duration(milliseconds: 300));

    // ML model update check (very low priority)
    unawaited(
      ModelUpdater().checkAndUpdateModel().catchError((error) {
        debugPrint('⚠️ [ML] Model update failed: $error');
        return null;
      }),
    );

    debugPrint('✅ [Deferred] Background tasks scheduled');
  });
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

    // Initialize background tasks and schedule daily predictions with error handling
    ref.listen(backgroundTaskInitProvider, (previous, next) {
      next.when(
        data: (_) =>
            debugPrint('BackgroundTaskService: Initialized successfully'),
        error: (err, stack) =>
            debugPrint('BackgroundTaskService: Initialization failed: $err'),
        loading: () => debugPrint('BackgroundTaskService: Initializing...'),
      );
    });
    ref.watch(backgroundTaskInitProvider);

    // Reschedule habit notifications when app starts
    ref.watch(habitNotificationsSchedulerProvider);

    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
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
          minAppVersion: '1.1.6+15', // Force update for any version below this
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
                              child: Text(
                                'Versión: ${snapshot.data}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
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
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) =>
                  Scaffold(body: Center(child: Text('Error: $error'))),
            );
          },
        ),
      ),
      // Add builder to wrap all screens with FastTimeBanner
      builder: (context, child) {
        return WithFastTimeBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

// Helper to get app version from package_info_plus
Future<String> _getAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return "${info.version}+${info.buildNumber}";
}
