import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../domain/services/simple_onboarding_scoring.dart';
import '../../domain/config/onboarding_config.dart';
import '../../domain/habit.dart';
import '../../data/storage/storage_providers.dart';
import 'habit_preview_page.dart';
import '../../../../l10n/app_localizations.dart';

/// Provider for current question in simple onboarding
final simpleOnboardingQuestionProvider = StateProvider<int>((ref) => 0);

/// Provider for selected goals
final selectedGoalsProvider = StateProvider<List<GoalType>>((ref) => []);

/// Provider for time commitment
final timeCommitmentProvider =
    StateProvider<TimeCommitment?>((ref) => null);

/// Provider for experience level
final experienceLevelProvider =
    StateProvider<ExperienceLevel?>((ref) => null);

/// Simple 3-question onboarding flow
/// 
/// Screens:
/// 1. Multi-select goals (max 3)
/// 2. Single-select time commitment (auto-advance)
/// 3. Single-select experience level (auto-advance)
class SimpleOnboardingFlow extends ConsumerStatefulWidget {
  const SimpleOnboardingFlow({super.key});

  @override
  ConsumerState<SimpleOnboardingFlow> createState() =>
      _SimpleOnboardingFlowState();
}

class _SimpleOnboardingFlowState extends ConsumerState<SimpleOnboardingFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _handleGoalToggle(GoalType goal) {
    final currentGoals = ref.read(selectedGoalsProvider);

    if (currentGoals.contains(goal)) {
      // Remove goal
      ref.read(selectedGoalsProvider.notifier).state =
          currentGoals.where((g) => g != goal).toList();
    } else {
      // Add goal (max 3)
      if (currentGoals.length < OnboardingConfig.maxGoals) {
        ref.read(selectedGoalsProvider.notifier).state = [
          ...currentGoals,
          goal
        ];
      }
    }
  }

  void _handleTimeSelection(TimeCommitment time) {
    _autoAdvanceTimer?.cancel();
    ref.read(timeCommitmentProvider.notifier).state = time;

    final currentQ = ref.read(simpleOnboardingQuestionProvider);
    _autoAdvanceTimer = Timer(OnboardingConfig.autoAdvanceDelay, () {
      if (mounted && ref.read(simpleOnboardingQuestionProvider) == currentQ) {
        _nextQuestion();
      }
    });
  }

  void _handleLevelSelection(ExperienceLevel level) {
    _autoAdvanceTimer?.cancel();
    ref.read(experienceLevelProvider.notifier).state = level;

    final currentQ = ref.read(simpleOnboardingQuestionProvider);
    _autoAdvanceTimer = Timer(OnboardingConfig.autoAdvanceDelay, () {
      if (mounted && ref.read(simpleOnboardingQuestionProvider) == currentQ) {
        _showLoadingAndNavigate();
      }
    });
  }

  void _nextQuestion() {
    final currentQuestion = ref.read(simpleOnboardingQuestionProvider);

    // Validate Q1 (goals)
    if (currentQuestion == 0) {
      final goals = ref.read(selectedGoalsProvider);
      if (goals.isEmpty) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.onboardingSelectAtLeastOneGoal ?? 
                        'Por favor selecciona al menos un objetivo'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Advance to next question
    ref.read(simpleOnboardingQuestionProvider.notifier).state =
        currentQuestion + 1;

    // Animate progress
    _progressController.forward(from: 0);
  }

  Future<void> _skipOnboarding() async {
    try {
      // Create single default habit
      final habitsRepository = ref.read(jsonHabitsRepositoryProvider);
      await habitsRepository.createHabit(
        name: 'Oración matutina',
        category: HabitCategory.spiritual,
        emoji: '🙏',
      );

      // Mark onboarding as complete
      final storage = ref.read(jsonStorageServiceProvider);
      await storage.setBool('onboarding_complete', true);

      if (mounted) {
        // Navigate to habits page
        Navigator.of(context).pushReplacementNamed('/habits');
      }
    } catch (e) {
      debugPrint('Failed to skip onboarding: $e');
      // Still mark as complete and navigate
      final storage = ref.read(jsonStorageServiceProvider);
      await storage.setBool('onboarding_complete', true);
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/habits');
      }
    }
  }

  Future<void> _showLoadingAndNavigate() async {
    debugPrint('🟢 Onboarding V2: Completed 3rd question, preparing habit preview...');
    try {
      final l10n = AppLocalizations.of(context);
      debugPrint('🟢 Showing loading dialog...');
      // Show loading animation (do not await)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
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
                Lottie.asset(
                  'assets/lottie/gears.json',
                  width: 120,
                  height: 120,
                  repeat: true,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.onboardingPreparingHabits ?? 'Preparando tus hábitos...',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xff6366f1),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
      debugPrint('🟢 Loading dialog shown. Calculating score...');
      // Calculate score
      final goals = ref.read(selectedGoalsProvider);
      final time = ref.read(timeCommitmentProvider)!;
      final level = ref.read(experienceLevelProvider)!;
      debugPrint('🟢 Providers: goals=$goals, time=$time, level=$level');
      final score = SimpleOnboardingScoring.calculateScore(
        goals: goals,
        timeCommitment: time,
        experienceLevel: level,
      );
      debugPrint('🟢 Score calculated: $score');
      // Small delay for UX
      await Future.delayed(OnboardingConfig.loadingDialogDelay);
      if (mounted) {
        debugPrint('🟢 Closing loading dialog...');
        Navigator.of(context).pop(); // Close loading dialog
        debugPrint('🟢 Navigating to HabitPreviewPage...');
        // Navigate to preview
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HabitPreviewPage(score: score),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('🔴 Error in _showLoadingAndNavigate: $e');
      debugPrint('🔴 Stacktrace: $stack');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = ref.watch(simpleOnboardingQuestionProvider);

    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(currentQuestion),
            const SizedBox(height: 24),

            // Question content
            Expanded(
              child: _buildQuestionContent(currentQuestion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentQuestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == currentQuestion;
          final isCompleted = index < currentQuestion;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? const Color(0xff6366f1)
                  : const Color(0xffe2e8f0),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionContent(int questionIndex) {
    switch (questionIndex) {
      case 0:
        return _buildGoalsQuestion();
      case 1:
        return _buildTimeQuestion();
      case 2:
        return _buildLevelQuestion();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGoalsQuestion() {
    final selectedGoals = ref.watch(selectedGoalsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué quieres mejorar?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona hasta 3 objetivos',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 32),

          // Goal options
          _buildGoalOption(
            goal: GoalType.faith,
            emoji: '🙏',
            text: 'Fe',
            isSelected: selectedGoals.contains(GoalType.faith),
          ),
          const SizedBox(height: 16),
          _buildGoalOption(
            goal: GoalType.wellness,
            emoji: '💪',
            text: 'Salud',
            isSelected: selectedGoals.contains(GoalType.wellness),
          ),
          const SizedBox(height: 16),
          _buildGoalOption(
            goal: GoalType.study,
            emoji: '📖',
            text: 'Estudio',
            isSelected: selectedGoals.contains(GoalType.study),
          ),
          const SizedBox(height: 16),
          _buildGoalOption(
            goal: GoalType.peace,
            emoji: '😌',
            text: 'Paz mental',
            isSelected: selectedGoals.contains(GoalType.peace),
          ),

          const Spacer(),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedGoals.isEmpty ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6366f1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: const Color(0xffe2e8f0),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Skip button
          Center(
            child: TextButton(
              onPressed: _skipOnboarding,
              child: const Text(
                'Saltar por ahora',
                style: TextStyle(
                  color: Color(0xff64748b),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required GoalType goal,
    required String emoji,
    required String text,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _handleGoalToggle(goal),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffeef2ff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xff6366f1)
                : const Color(0xffe2e8f0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xff6366f1).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xff6366f1)
                      : const Color(0xff1e293b),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? const Color(0xff6366f1)
                  : const Color(0xffcbd5e1),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeQuestion() {
    final selectedTime = ref.watch(timeCommitmentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cuánto tiempo diario?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona tu compromiso de tiempo',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 32),

          // Time options
          _buildTimeOption(
            time: TimeCommitment.short,
            text: '5-10 minutos',
            description: 'Perfecto para empezar',
            isSelected: selectedTime == TimeCommitment.short,
          ),
          const SizedBox(height: 16),
          _buildTimeOption(
            time: TimeCommitment.medium,
            text: '10-20 minutos',
            description: 'Equilibrio ideal',
            isSelected: selectedTime == TimeCommitment.medium,
          ),
          const SizedBox(height: 16),
          _buildTimeOption(
            time: TimeCommitment.long,
            text: '20+ minutos',
            description: 'Compromiso profundo',
            isSelected: selectedTime == TimeCommitment.long,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTimeOption({
    required TimeCommitment time,
    required String text,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _handleTimeSelection(time),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffeef2ff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xff6366f1)
                : const Color(0xffe2e8f0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xff6366f1).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xff6366f1)
                          : const Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xff6366f1).withValues(alpha: 0.7)
                          : const Color(0xff64748b),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? const Color(0xff6366f1)
                  : const Color(0xffcbd5e1),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelQuestion() {
    final selectedLevel = ref.watch(experienceLevelProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Tu nivel actual?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xff1e293b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sé honesto, esto nos ayuda a personalizarlo',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff64748b),
            ),
          ),
          const SizedBox(height: 32),

          // Level options
          _buildLevelOption(
            level: ExperienceLevel.newbie,
            emoji: '🌱',
            text: 'Nuevo',
            description: 'Estoy comenzando mi camino',
            isSelected: selectedLevel == ExperienceLevel.newbie,
          ),
          const SizedBox(height: 16),
          _buildLevelOption(
            level: ExperienceLevel.growing,
            emoji: '🌿',
            text: 'Creciendo',
            description: 'Tengo algo de experiencia',
            isSelected: selectedLevel == ExperienceLevel.growing,
          ),
          const SizedBox(height: 16),
          _buildLevelOption(
            level: ExperienceLevel.consistent,
            emoji: '🌳',
            text: 'Consistente',
            description: 'Mantengo hábitos regularmente',
            isSelected: selectedLevel == ExperienceLevel.consistent,
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLevelOption({
    required ExperienceLevel level,
    required String emoji,
    required String text,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _handleLevelSelection(level),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffeef2ff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xff6366f1)
                : const Color(0xffe2e8f0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xff6366f1).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xff6366f1)
                          : const Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xff6366f1).withValues(alpha: 0.7)
                          : const Color(0xff64748b),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? const Color(0xff6366f1)
                  : const Color(0xffcbd5e1),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
