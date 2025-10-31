import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/ai_providers.dart';
import '../../domain/models/generation_request.dart';
import '../../../../l10n/app_localizations.dart';
import 'generated_habits_page.dart';

/// Micro-habits generator page with AI-powered suggestions
class MicroHabitGeneratorPage extends ConsumerStatefulWidget {
  const MicroHabitGeneratorPage({super.key});

  @override
  ConsumerState<MicroHabitGeneratorPage> createState() =>
      _MicroHabitGeneratorPageState();
}

class _MicroHabitGeneratorPageState
    extends ConsumerState<MicroHabitGeneratorPage> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _failurePatternController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    _failurePatternController.dispose();
    super.dispose();
  }

  Future<void> _generateHabits() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final request = GenerationRequest(
      userGoal: _goalController.text.trim(),
      failurePattern: _failurePatternController.text.trim().isEmpty
          ? null
          : _failurePatternController.text.trim(),
      languageCode: locale.languageCode,
    );

    try {
      await ref.read(microHabitGeneratorProvider.notifier).generate(request);

      final state = ref.read(microHabitGeneratorProvider);

      state.when(
        data: (habits) {
          if (habits.isNotEmpty && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GeneratedHabitsPage(),
              ),
            );
          }
        },
        loading: () {},
        error: (error, _) {
          if (mounted) {
            String errorMessage = l10n.generationFailed;

            if (error.toString().contains('RateLimitExceededException')) {
              errorMessage = l10n.rateLimitReached;
            } else if (error.toString().contains('TimeoutException')) {
              errorMessage = l10n.apiTimeout;
            } else if (error.toString().contains('InvalidInputException')) {
              errorMessage = l10n.invalidInput;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red.shade600,
                action: SnackBarAction(
                  label: l10n.tryAgain,
                  textColor: Colors.white,
                  onPressed: () => _generateHabits(),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.generationFailed),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final generatorState = ref.watch(microHabitGeneratorProvider);
    final isGenerating = generatorState.isLoading;
    final remaining =
        ref.watch(microHabitGeneratorProvider.notifier).remainingRequests;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      appBar: AppBar(
        title: Text(l10n.generateMicroHabits),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1a202c),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  l10n.aiGeneratedHabits,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1a202c),
                  ),
                ),
                const SizedBox(height: 12),

                // Powered by Gemini badge
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.poweredByGemini,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Goal input
                TextFormField(
                  controller: _goalController,
                  decoration: InputDecoration(
                    labelText: l10n.yourGoal,
                    hintText: l10n.goalHint,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  maxLength: 200,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.goalRequired;
                    }
                    if (value.trim().length < 10) {
                      return l10n.goalTooShort;
                    }
                    if (value.trim().length > 200) {
                      return l10n.goalTooLong;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Failure pattern input (optional)
                TextFormField(
                  controller: _failurePatternController,
                  decoration: InputDecoration(
                    labelText: '${l10n.failurePattern} (${l10n.optional})',
                    hintText: l10n.failurePatternHint,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.warning_amber),
                  ),
                  maxLength: 200,
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                // Generate button
                ElevatedButton(
                  onPressed:
                      isGenerating || remaining <= 0 ? null : _generateHabits,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6366f1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isGenerating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.generatingHabits,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.generateHabits,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Rate limit info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: remaining <= 3
                        ? Colors.orange.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: remaining <= 3
                          ? Colors.orange.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            remaining <= 3
                                ? Icons.warning_amber
                                : Icons.info_outline,
                            size: 20,
                            color: remaining <= 3
                                ? Colors.orange.shade700
                                : Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.monthlyLimit(10),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: remaining <= 3
                                  ? Colors.orange.shade900
                                  : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.generationsRemaining(remaining),
                        style: TextStyle(
                          fontSize: 14,
                          color: remaining <= 3
                              ? Colors.orange.shade900
                              : Colors.blue.shade900,
                        ),
                      ),
                    ],
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
