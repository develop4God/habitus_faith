import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/storage/storage_providers.dart';
import '../../domain/habit.dart';
import 'onboarding_models.dart';
import 'onboarding_questions.dart';
import 'commitment_screen.dart';
import '../../../../core/providers/ai_providers.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    // Validate answer
    final answers = ref.read(answersProvider);
    final answer = answers[currentQuestion.id];

    if (currentQuestion.isRequired && answer == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una opción'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Check if we should show encouragement message
    if (currentQuestion.id == 'supportSystem') {
      final intent = ref.read(selectedIntentProvider);
      final supportLevel = answer as String?;
      if (intent != null && supportLevel != null) {
        final message = getEncouragementMessage(intent, supportLevel);
        if (message != null && mounted) {
          await _showEncouragementDialog(message);
        }
      }
    }

    // Move to next question or commitment screen
    if (currentIndex < questions.length - 1) {
      ref.read(currentQuestionIndexProvider.notifier).state = currentIndex + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to commitment screen
      if (mounted) {
        await _goToCommitmentScreen();
      }
    }
  }

  Future<void> _goToCommitmentScreen() async {
    final intent = ref.read(selectedIntentProvider);
    if (intent == null) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CommitmentScreen(
          userIntent: intent,
          onCommitmentMade: (commitment) {
            Navigator.of(context).pop(commitment);
          },
        ),
      ),
    );

    if (result != null && mounted) {
      await _completeOnboarding(result);
    }
  }

  Future<void> _completeOnboarding(String commitment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final intent = ref.read(selectedIntentProvider);
      final answers = ref.read(answersProvider);

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

      // Save profile to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_profile', jsonEncode(profile.toJson()));
      await prefs.setString('user_intent', intent.name);

      // Generate habits using AI based on profile
      final geminiService = await ref.read(geminiServiceProvider.future);
      final storage = ref.read(jsonStorageServiceProvider);
      const userId = 'local_user'; // For now, using local storage

      final habitsData =
          await geminiService.generateHabitsFromProfile(profile, userId);

      // Create habits from generated data
      final repository = ref.read(jsonHabitsRepositoryProvider);
      for (final habitData in habitsData) {
        await repository.createHabit(
          name: habitData['name'] as String,
          description: habitData['description'] as String,
          category: habitData['category'] as HabitCategory,
          emoji: habitData['emoji'] as String?,
        );
      }

      // Mark onboarding as complete
      await storage.setBool('onboarding_complete', true);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Future<void> _showEncouragementDialog(ConditionalMessage message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _previousQuestion() {
    final currentIndex = ref.read(currentQuestionIndexProvider);
    if (currentIndex > 0) {
      ref.read(currentQuestionIndexProvider.notifier).state = currentIndex - 1;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentIndex > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previousQuestion,
                        )
                      else
                        const SizedBox(width: 48),
                      Text(
                        '${currentIndex + 1}/${questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff64748b),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / questions.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xff6366f1),
                    ),
                  ),
                ],
              ),
            ),

            // Question content
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
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          currentIndex < questions.length - 1
                              ? l10n.continueButton
                              : 'Finalizar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
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

  const _QuestionPage({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            question.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1a202c),
            ),
          ),
          const SizedBox(height: 24),
          if (question.type == QuestionType.multiChoice &&
              question.maxSelections != null)
            Text(
              'Selecciona hasta ${question.maxSelections} opciones',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff64748b),
              ),
            ),
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
                  } else {
                    // Multi-select
                    final current = (selectedAnswer as List?)?.toList() ?? [];
                    if (isSelected) {
                      current.remove(option.id);
                    } else {
                      if (question.maxSelections == null ||
                          current.length < question.maxSelections!) {
                        current.add(option.id);
                      }
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              option.emoji,
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
