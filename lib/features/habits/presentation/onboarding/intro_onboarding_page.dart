import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../l10n/app_localizations.dart';

class IntroOnboardingPage extends StatelessWidget {
  final VoidCallback onStart;
  const IntroOnboardingPage({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/completing_tasks.json',
                  width: 220,
                  height: 220,
                  repeat: true,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.welcomeToHabitusFaith,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1a202c),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingWelcomeMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff64748b),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6366f1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: onStart,
                    child: Text(
                      l10n.start,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
