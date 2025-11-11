import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../data/storage/storage_providers.dart';
import '../../domain/habit.dart';
import 'onboarding_models.dart';
import 'onboarding_questions.dart';
import 'commitment_screen.dart';
import 'intro_onboarding_page.dart';
import '../../../../core/providers/ai_providers.dart';
import '../../../../core/services/templates/template_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Provider for current question index in onboarding flow
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for user's answers to questions
final answersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

/// Provider for selected user intent
final selectedIntentProvider = StateProvider<UserIntent?>((ref) => null);

/// Adaptive onboarding page with intent-based flow
class AdaptiveOnboardingPage extends ConsumerStatefulWidget {
  const AdaptiveOnboardingPage({super.key});

  @override
  ConsumerState<AdaptiveOnboardingPage> createState() =>
      _AdaptiveOnboardingPageState();
}

class _AdaptiveOnboardingPageState
    extends ConsumerState<AdaptiveOnboardingPage> {
  final PageController _pageController = PageController();
  bool _isLoading = false;
  bool _showIntro = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startOnboarding() {
    setState(() {
      _showIntro = false;
    });
  }

  List<OnboardingQuestion> _getQuestions() {
    final intent = ref.watch(selectedIntentProvider);
    if (intent == null) {
      return [intentQuestion];
    }
    return getQuestionsForIntent(intent);
  }

  void _handleAnswer(String questionId, dynamic answer) {
    final answers = ref.read(answersProvider);
    ref.read(answersProvider.notifier).state = {
      ...answers,
      questionId: answer,
    };

    // If this is the intent question, update the intent provider
    if (questionId == 'intent') {
      final intentValue = UserIntent.values.firstWhere(
        (e) => e.name == answer,
        orElse: () => UserIntent.both,
      );
      ref.read(selectedIntentProvider.notifier).state = intentValue;
    }
  }

  Future<void> _nextQuestion() async {
    final currentIndex = ref.read(currentQuestionIndexProvider);
    final questions = _getQuestions();
    final currentQuestion = questions[currentIndex];
    final answers = ref.read(answersProvider);
    final answer = answers[currentQuestion.id];
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Mostrar SnackBar antes de cualquier await
    if (currentQuestion.isRequired && answer == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una opción'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Mostrar diálogo antes de cualquier await
    if (currentQuestion.id == 'supportSystem') {
      final intent = ref.read(selectedIntentProvider);
      final supportLevel = answer as String?;
      if (intent != null && supportLevel != null) {
        final message = getEncouragementMessage(intent, supportLevel);
        if (message != null) {
          await showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xff6366f1)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1a202c),
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (message.verseReference != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xff6366f1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.verseReference!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff6366f1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message.verseText ?? '',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => navigator.pop(),
                    child: const Text('Continuar'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
    // Después de cualquier await, verifica que el widget sigue montado
    if (!mounted) return;
    // Move to next question or commitment screen
    if (currentIndex < questions.length - 1) {
      ref.read(currentQuestionIndexProvider.notifier).state = currentIndex + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _goToCommitmentScreen();
    }
  }

  Future<void> _goToCommitmentScreen() async {
    final intent = ref.read(selectedIntentProvider);
    if (intent == null) return;
    ref.read(answersProvider);
    final navigator = Navigator.of(context);
    Future showSuccessDialog() => showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/success.json',
                      width: 120, height: 120, repeat: false),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Tus hábitos han sido generados exitosamente!',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff6366f1),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
    Future showLoadingDialog() => showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/gears.json',
                      width: 120, height: 120, repeat: true),
                  const SizedBox(height: 16),
                  const Text(
                    'Generando tus primeras tareas, por favor espera...',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff6366f1),
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
    await navigator.push<String>(
      MaterialPageRoute(
        builder: (context) => CommitmentScreen(
          userIntent: intent,
          onCommitmentMade: (commitment) async {
            showLoadingDialog();
            final success = await _completeOnboarding(commitment);
            if (navigator.mounted) navigator.pop(); // Cierra modal de carga
            if (success && navigator.mounted) {
              showSuccessDialog();
              await Future.delayed(const Duration(seconds: 2));
              if (navigator.mounted) navigator.pop();
              if (navigator.mounted) navigator.pushReplacementNamed('/habits');
            } else if (navigator.mounted) {
              // Mostrar error amigable
              showDialog(
                context: navigator.context,
                barrierDismissible: true,
                builder: (dialogContext) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No se pudieron generar tus hábitos en este momento. Por favor, reintenta más tarde.',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
    if (!mounted) return;
  }

  Future<bool> _completeOnboarding(String commitment) async {
    debugPrint('Inicio de _completeOnboarding con commitment: $commitment');
    log('Inicio de _completeOnboarding con commitment: $commitment',
        name: 'onboarding');
    setState(() {
      _isLoading = true;
    });
    bool success = false;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final intent = ref.read(selectedIntentProvider);
      final answers = ref.read(answersProvider);
      debugPrint('Intent: $intent, Answers: ${jsonEncode(answers)}');
      log('Intent: $intent, Answers: ${jsonEncode(answers)}',
          name: 'onboarding');

      // Build onboarding profile
      final profile = OnboardingProfile(
        primaryIntent: intent!,
        motivations: _extractMotivations(answers, intent),
        challenge: answers['mainChallenge'] as String? ?? '',
        supportLevel: answers['supportSystem'] as String? ?? '',
        spiritualMaturity: _extractSpiritualMaturity(answers, intent),
        commitment: commitment,
        completedAt: DateTime.now(),
      );
      debugPrint('Perfil construido: ${jsonEncode(profile.toJson())}');
      log('Perfil construido: ${jsonEncode(profile.toJson())}',
          name: 'onboarding');

      // Save profile to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return false;
      await prefs.setString('onboarding_profile', jsonEncode(profile.toJson()));
      await prefs.setString('user_intent', intent.name);
      debugPrint('Perfil guardado en SharedPreferences');
      log('Perfil guardado en SharedPreferences', name: 'onboarding');

      // Get current language
      final locale = Localizations.localeOf(context);
      final language = locale.languageCode; // 'es', 'en', 'pt', 'fr'

      // Try to fetch template first
      final templateService = ref.read(templateMatchingServiceProvider);
      final templateHabits = await templateService.findMatch(profile, language);

      List<Map<String, dynamic>> habitsData;
      if (templateHabits != null && templateHabits.isNotEmpty) {
        habitsData = templateHabits;
        log('Using pre-generated template (${templateHabits.length} habits)',
            name: 'onboarding');
        debugPrint(
            'Using pre-generated template (${templateHabits.length} habits)');
      } else {
        // Fallback to Gemini AI generation
        final geminiService = await ref.read(geminiServiceProvider.future);
        if (!mounted) return false;
        const userId = 'local_user';
        habitsData =
            await geminiService.generateHabitsFromProfile(profile, userId);
        log('Generated with Gemini (no template match, ${habitsData.length} habits)',
            name: 'onboarding');
        debugPrint(
            'Generated with Gemini (no template match, ${habitsData.length} habits)');
      }

      if (!mounted) return false;

      // Create habits from generated data
      final repository = ref.read(jsonHabitsRepositoryProvider);
      final storage = ref.read(jsonStorageServiceProvider);
      for (final habitData in habitsData) {
        // Corregir casteo: convertir string a HabitCategory
        HabitCategory category;
        final catValue = habitData['category'];
        if (catValue is String) {
          category = HabitCategory.values.firstWhere(
            (e) => e.toString().split('.').last == catValue,
            orElse: () => HabitCategory.spiritual,
          );
        } else if (catValue is HabitCategory) {
          category = catValue;
        } else {
          category = HabitCategory.spiritual;
        }
        await repository.createHabit(
          name: habitData['name'] as String,
          description: habitData['description'] as String,
          category: category,
          emoji: habitData['emoji'] as String?,
        );
        if (!mounted) return false;
      }
      debugPrint('Hábitos creados en el repositorio');
      log('Hábitos creados en el repositorio', name: 'onboarding');

      // Mark onboarding as complete
      await storage.setBool('onboarding_complete', true);
      if (!mounted) return false;
      debugPrint('Onboarding marcado como completo en storage');
      log('Onboarding marcado como completo en storage', name: 'onboarding');

      // Debug print y log para diagnóstico final
      debugPrint(
          'Onboarding completado correctamente. Perfil: ${jsonEncode(profile.toJson())}');
      log('Onboarding completado correctamente. Perfil: ${jsonEncode(profile.toJson())}',
          name: 'onboarding');

      if (!mounted) return false;
      debugPrint('Navegando a /habits');
      log('Navegando a /habits', name: 'onboarding');
      success = true;
    } catch (e, stack) {
      debugPrint('Error en _completeOnboarding: ${e.toString()}');
      debugPrint('Stacktrace: $stack');
      log('Error en _completeOnboarding: ${e.toString()}', name: 'onboarding');
      log('Stacktrace: $stack', name: 'onboarding');
      if (!mounted) return false;
      String errorMessage;
      if (e.toString().contains('Resource exhausted') ||
          e.toString().contains('error-code-429')) {
        errorMessage =
            'La generación de hábitos está temporalmente limitada por el proveedor de IA. Por favor intenta nuevamente en unos minutos. Si el problema persiste, contacta soporte.';
      } else {
        errorMessage =
            'Ocurrió un error inesperado al finalizar el onboarding. Por favor verifica tu conexión y vuelve a intentarlo. Si el problema persiste, contacta soporte.';
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    return success;
  }

  List<String> _extractMotivations(
      Map<String, dynamic> answers, UserIntent intent) {
    switch (intent) {
      case UserIntent.faithBased:
        final motivations = answers['spiritualMotivation'];
        if (motivations is List) {
          return motivations.cast<String>();
        }
        return [];
      case UserIntent.wellness:
        final goals = answers['wellnessGoals'];
        if (goals is List) {
          return goals.cast<String>();
        }
        return [];
      case UserIntent.both:
        final spiritual = answers['spiritualMotivation'];
        final wellness = answers['wellnessGoals'];
        final combined = <String>[];
        if (spiritual is List) combined.addAll(spiritual.cast<String>());
        if (wellness is List) combined.addAll(wellness.cast<String>());
        return combined;
    }
  }

  String? _extractSpiritualMaturity(
      Map<String, dynamic> answers, UserIntent intent) {
    if (intent == UserIntent.wellness) return null;
    return answers['faithWalk'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return IntroOnboardingPage(onStart: _startOnboarding);
    }
    final l10n = AppLocalizations.of(context)!;
    final questions = _getQuestions();
    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final currentQuestion =
        currentIndex < questions.length ? questions[currentIndex] : null;
    final answers = ref.watch(answersProvider);

    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Detecta si es la pantalla 2 y si es multiChoice con máximo 3 selecciones
    final isSecondScreen = currentIndex == 1 &&
        currentQuestion.type == QuestionType.multiChoice &&
        currentQuestion.maxSelections == 3;

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de pasos moderna y clara + botón Back arriba a la izquierda en pantalla 2
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                children: [
                  if (currentIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xff6366f1)),
                      tooltip: 'Atrás',
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (currentIndex > 0) {
                                // Si la pregunta anterior es de selección única, limpiar respuesta para permitir avance
                                final prevQuestion =
                                    questions[currentIndex - 1];
                                if (prevQuestion.type ==
                                    QuestionType.singleChoice) {
                                  final answers = ref.read(answersProvider);
                                  final newAnswers =
                                      Map<String, dynamic>.from(answers);
                                  newAnswers.remove(prevQuestion.id);
                                  ref.read(answersProvider.notifier).state =
                                      newAnswers;
                                }
                                ref
                                    .read(currentQuestionIndexProvider.notifier)
                                    .state = currentIndex - 1;
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(questions.length, (i) {
                        final isActive = i == currentIndex;
                        final isCompleted = i < currentIndex;
                        return Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isActive ? 28 : 20,
                              height: isActive ? 28 : 20,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xff6366f1)
                                    : isActive
                                        ? const Color(0xff6366f1)
                                            .withValues(alpha: 0.8)
                                        : Colors.grey.shade300,
                                shape: BoxShape.circle,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                            color: const Color(0xff6366f1)
                                                .withValues(alpha: 0.2),
                                            blurRadius: 8)
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 16)
                                    : Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isActive ? 16 : 12,
                                        ),
                                      ),
                              ),
                            ),
                            if (i < questions.length - 1)
                              Container(
                                width: 32,
                                height: 4,
                                color: isCompleted
                                    ? const Color(0xff6366f1)
                                    : Colors.grey.shade300,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // Pregunta y mensaje destacado para pantalla 2 multiChoice
            if (currentIndex !=
                0) // Solo mostrar el título de la pregunta si no es la primera
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1a202c),
                      ),
                    ),
                    if (isSecondScreen)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffeef2ff),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xff6366f1), width: 1.5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xff6366f1)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Puedes seleccionar hasta 3 opciones que más te identifiquen.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff6366f1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // Opciones
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _QuestionPage(
                    question: question,
                    selectedAnswer: answers[question.id],
                    onAnswerSelected: (answer) =>
                        _handleAnswer(question.id, answer),
                    onAutoAdvance: question.type == QuestionType.singleChoice
                        ? () => _nextQuestion()
                        : null,
                  );
                },
              ),
            ),
            // Animación Lottie solo en la última pantalla, no en la 4 ni en la 5
            if (currentIndex == questions.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Lottie.asset(
                  'assets/lottie/tap_screen.json',
                  width: 120,
                  height: 120,
                  repeat: true,
                ),
              ),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: (currentQuestion.type == QuestionType.multiChoice)
                  ? SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6366f1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _isLoading ? null : _nextQuestion,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                l10n.continueButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final OnboardingQuestion question;
  final dynamic selectedAnswer;
  final Function(dynamic) onAnswerSelected;
  final VoidCallback? onAutoAdvance;

  const _QuestionPage({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.onAutoAdvance,
  });

  @override
  Widget build(BuildContext context) {
    // Evito mostrar el título dos veces en la página 4 (supportSystem)
    final showTitle = question.id != 'supportSystem';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (showTitle)
            Text(
              question.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff1a202c),
              ),
            ),
          if (!showTitle) const SizedBox(height: 8),
          const SizedBox(height: 16),
          ...question.options.map((option) {
            final isSelected = question.type == QuestionType.singleChoice
                ? selectedAnswer == option.id
                : (selectedAnswer as List?)?.contains(option.id) ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _OptionCard(
                option: option,
                isSelected: isSelected,
                onTap: () {
                  if (question.type == QuestionType.singleChoice) {
                    onAnswerSelected(option.id);
                    if (onAutoAdvance != null) {
                      Future.delayed(
                          const Duration(milliseconds: 150), onAutoAdvance);
                    }
                  } else {
                    final current = (selectedAnswer as List?)?.toList() ?? [];
                    if (isSelected) {
                      current.remove(option.id);
                    } else {
                      current.add(option.id);
                    }
                    onAnswerSelected(current);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si el texto es "Estrés y ansiedad", reemplazo el emoji por 😌
    final emoji = option.text == 'Estrés y ansiedad' ? '😌' : option.emoji;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xff6366f1) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xff6366f1).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: const Color(0xff1a202c),
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff64748b),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xff6366f1),
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade400,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
