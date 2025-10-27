import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/bible_reader_page.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/notification_provider.dart';
import 'features/habits/presentation/onboarding/onboarding_page.dart';
import 'features/habits/data/storage/json_storage_service.dart';
import 'features/habits/data/storage/json_habits_repository.dart';
import 'features/habits/data/storage/storage_providers.dart';
import 'l10n/app_localizations.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 220,
              child: Lottie.asset('assets/lottie/animation.json'),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xff1a202c),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              key: const Key('start_button'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                backgroundColor: const Color(0xff6366f1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 6,
                shadowColor: Colors.blueAccent.withValues(alpha:0.15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Text(
                l10n.start,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('read_bible_button'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: const Color(0xffa5b4fc),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 3,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BibleReaderPage()),
                );
              },
              child: Text(
                l10n.readBible,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = JsonStorageService(prefs);
  const userId = 'local_user';
  final habitsRepository = JsonHabitsRepository(
    storage: storageService,
    userId: userId,
    idGenerator: () => DateTime.now().microsecondsSinceEpoch.toString(),
  );

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
    
    // Initialize notification service
    ref.watch(notificationInitProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/onboarding': (context) => const OnboardingPage(),
      },
      home: authInit.when(
        data: (_) =>
        onboardingComplete ? const LandingPage() : const OnboardingPage(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}