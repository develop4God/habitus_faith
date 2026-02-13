import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/habits/domain/habit.dart';
import '../../features/habits/domain/models/risk_level.dart';
import '../../features/habits/data/storage/storage_providers.dart';
import '../services/ml/abandonment_predictor.dart';
import '../services/ai/behavioral_engine.dart';
import '../services/notifications/notification_service.dart';
import '../providers/ml_providers.dart';
import '../providers/remote_config_provider.dart';
import '../providers/notification_provider.dart';
import '../../l10n/app_localizations.dart';
import '../services/time/time.dart';
import 'clock_provider.dart';

/// Provider for managing daily habit predictions and interventions
/// Runs predictions daily at configured hour via background task
final habitPredictorProvider = Provider<HabitPredictorService>((ref) {
  final habitsRepository = ref.watch(jsonHabitsRepositoryProvider);
  final predictor = ref.watch(abandonmentPredictorProvider);
  final clock = ref.watch(clockProvider);
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return HabitPredictorService(
    habitsRepository: habitsRepository,
    predictor: predictor,
    clock: clock,
    remoteConfigFuture: remoteConfig,
    notificationService: notificationService,
  );
});

/// Provider that ensures predictor is fully initialized before use
/// Use this in background tasks where initialization must be guaranteed
final habitPredictorInitializedProvider = FutureProvider<HabitPredictorService>((ref) async {
  final habitsRepository = ref.watch(jsonHabitsRepositoryProvider);
  final predictor = await ref.watch(abandonmentPredictorInitializedProvider.future);
  final clock = ref.watch(clockProvider);
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  return HabitPredictorService(
    habitsRepository: habitsRepository,
    predictor: predictor,
    clock: clock,
    remoteConfigFuture: remoteConfig,
    notificationService: notificationService,
  );
});

/// Service for running daily habit predictions and triggering interventions
class HabitPredictorService {
  final dynamic habitsRepository; // JsonHabitsRepository
  final AbandonmentPredictor predictor;
  final Clock clock;
  final AsyncValue<dynamic> remoteConfigFuture; // RemoteConfigService
  final NotificationService notificationService;

  // Nudge notification cooldown (hours)
  static const int _nudgeCooldownHours =
      24; // Don't send same nudge more than once per day

  HabitPredictorService({
    required this.habitsRepository,
    required this.predictor,
    required this.clock,
    required this.remoteConfigFuture,
    required this.notificationService,
  });

  /// Run daily predictions for all habits
  /// Called by background task at 6:00 AM
  ///
  /// For each habit:
  /// 1. Predict abandonment risk using ML model
  /// 2. Update abandonmentRisk field
  /// 3. If risk >= intervention threshold: calculate new difficulty and show nudge notification
  Future<void> runDailyPredictions() async {
    debugPrint('PREDICTOR 🧠 runDailyPredictions: Fetching all habits...');

    try {
      // Check if ML predictor is enabled via Remote Config
      final remoteConfig = remoteConfigFuture.value;
      if (remoteConfig == null) {
        debugPrint(
            'PREDICTOR 🧠 ⚠️ Remote Config not available, using default (enabled)');
      } else if (!remoteConfig.isMLPredictorEnabled) {
        debugPrint('PREDICTOR 🧠 ⏭️ ML Predictor disabled via Remote Config');
        return;
      }

      // Get all active (non-archived) habits
      final habits = await habitsRepository.getHabits();
      debugPrint(
          'PREDICTOR 🧠 runDailyPredictions: getHabits returned ${habits.length} habits.');
      final activeHabits = habits.where((h) => !h.isArchived).toList();
      debugPrint(
          'PREDICTOR 🧠 runDailyPredictions: ${activeHabits.length} active habits.');

      int processedCount = 0;
      int highRiskCount = 0;

      for (final habit in activeHabits) {
        try {
          debugPrint(
              'PREDICTOR 🧠 Processing habit: id=\\${habit.id}, name=\\${habit.name}, completedToday=\\${habit.completedToday}');
          await _processSingleHabit(habit);
          processedCount++;

          // Track high-risk habits
          if (habit.abandonmentRisk > 0.65) {
            highRiskCount++;
          }
        } catch (e) {
          debugPrint('PREDICTOR 🧠 ❌ Error processing habit \\${habit.id}: $e');
        }
      }

      debugPrint(
        'PREDICTOR 🧠 ✅ Daily predictions complete. Processed: $processedCount, High-risk: $highRiskCount',
      );
    } catch (e) {
      debugPrint('PREDICTOR 🧠 ❌ Daily predictions failed: $e');
    }
  }

  /// Process a single habit: predict risk, update fields, send notifications
  Future<void> _processSingleHabit(Habit habit) async {
    // Skip habits already completed today
    if (habit.completedToday) {
      debugPrint(
          'PREDICTOR 🧠 ⏭️ Skipping habit (already completed today): id=\\${habit.id}, name=\\${habit.name}');
      return;
    }

    // Predict abandonment risk
    final risk = await predictor.predictRisk(habit);
    debugPrint(
        'PREDICTOR 🧠 📊 Habit "${habit.name}" predicted risk: ${(risk * 100).toStringAsFixed(1)}%');

    // Update abandonmentRisk field
    final updatedHabit = habit.copyWith(abandonmentRisk: risk);

    // If risk requires intervention: apply intervention
    if (RiskThresholds.requiresIntervention(risk)) {
      await _applyIntervention(updatedHabit);
    } else {
      // Just update the risk value
      final result = await habitsRepository.updateHabitInstance(updatedHabit);
      result.fold(
        (failure) => debugPrint(
            'PREDICTOR 🧠 ❌ Failed to update habit ${habit.id}: $failure'),
        (success) => debugPrint(
            'PREDICTOR 🧠 ✅ Updated "${habit.name}" with risk ${risk.toStringAsFixed(3)}'),
      );
    }
  }

  /// Apply intervention for high-risk habit
  /// 1. Calculate new difficulty using BehavioralEngine
  /// 2. Show notification with suggested adjustment
  Future<void> _applyIntervention(Habit habit) async {
    developer.log(
      'HabitPredictorService: Applying intervention for habit "${habit.name}"',
      name: 'HabitPredictorService',
    );

    try {
      // Calculate new difficulty using Behavioral Engine
      final engine = BehavioralEngine(clock: clock);
      final newDifficultyLevel = engine.calculateNextDifficulty(habit);

      // Only suggest reduction if it's actually lower
      if (newDifficultyLevel < habit.difficultyLevel) {
        final newTargetMinutes =
            Habit.targetMinutesByLevel[newDifficultyLevel] ??
                habit.targetMinutes;

        // Show nudge notification
        await _showNudgeNotification(
          habitName: habit.name,
          currentMinutes: habit.targetMinutes,
          suggestedMinutes: newTargetMinutes,
          habitId: habit.id,
        );

        developer.log(
          'HabitPredictorService: Suggested difficulty reduction for "${habit.name}": '
          '${habit.targetMinutes}min → ${newTargetMinutes}min',
          name: 'HabitPredictorService',
        );
      }

      // Update habit with new abandonment risk
      final result = await habitsRepository.updateHabitInstance(habit);
      result.fold(
        (failure) => debugPrint(
            'PREDICTOR 🧠 ❌ Failed to update habit ${habit.id} during intervention: $failure'),
        (success) => debugPrint(
            'PREDICTOR 🧠 ✅ Successfully updated habit "${habit.name}" with intervention'),
      );
    } catch (e) {
      developer.log(
        'HabitPredictorService: Error applying intervention for habit ${habit.id}: $e',
        name: 'HabitPredictorService',
        error: e,
      );
    }
  }

  /// Show nudge notification suggesting difficulty reduction
  /// Implements a 24-hour cooldown per habit to avoid notification spam
  Future<void> _showNudgeNotification({
    required String habitName,
    required int currentMinutes,
    required int suggestedMinutes,
    required String habitId,
  }) async {
    try {
      // Get locale from SharedPreferences (since we're in background/isolate)
      final prefs = await SharedPreferences.getInstance();

      // Check cooldown - don't send same nudge more than once per 24 hours
      final cooldownKey = '${NotificationService.nudgeSentPrefix}$habitId';
      final lastSentStr = prefs.getString(cooldownKey);

      if (lastSentStr != null) {
        final lastSent = DateTime.parse(lastSentStr);
        final hoursSinceLastSent = clock.now().difference(lastSent).inHours;

        // In FAST_TIME mode (288x speed), disable cooldown for rapid testing
        // In normal mode, use standard 24-hour cooldown
        const fastTime = bool.fromEnvironment('FAST_TIME');
        const cooldownHours = fastTime ? 0 : _nudgeCooldownHours;

        if (hoursSinceLastSent < cooldownHours) {
          developer.log(
            'HabitPredictorService: Nudge notification for habit "$habitName" skipped '
            '(cooldown: sent $hoursSinceLastSent hours ago)',
            name: 'HabitPredictorService',
          );
          return; // Skip notification - cooldown not expired
        }
      }

      final localeCode = prefs.getString('locale') ?? 'es';

      // Load localized strings without BuildContext
      final locale = Locale(localeCode);
      final localizations = lookupAppLocalizations(locale);

      // Get localized title and body using parameterized methods
      final title = localizations.abandonmentNudgeTitle(habitName);
      final body = localizations.abandonmentNudgeBody(suggestedMinutes);

      await notificationService.showImmediateNotification(
        title,
        body,
        payload: 'habit_nudge:$habitId:$suggestedMinutes',
        id: habitId.hashCode,
      );

      // Store timestamp of sent notification for cooldown tracking
      await prefs.setString(cooldownKey, clock.now().toIso8601String());

      developer.log(
        'HabitPredictorService: Nudge notification sent for habit "$habitName" (locale: $localeCode)',
        name: 'HabitPredictorService',
      );
    } catch (e) {
      developer.log(
        'HabitPredictorService: Error showing nudge notification: $e',
        name: 'HabitPredictorService',
        error: e,
      );
    }
  }

  /// Handle user response to nudge notification
  /// Called when user accepts or declines the suggestion
  Future<void> handleNudgeResponse({
    required String habitId,
    required bool accepted,
    required int suggestedMinutes,
  }) async {
    try {
      if (accepted) {
        // User accepted: apply the difficulty reduction
        final habits = await habitsRepository.getHabits();
        final habit = habits.firstWhere((h) => h.id == habitId);

        // Calculate new difficulty level from suggested minutes
        final newDifficultyLevel = Habit.targetMinutesByLevel.entries
            .firstWhere(
              (entry) => entry.value == suggestedMinutes,
              orElse: () => const MapEntry(3, 20),
            )
            .key;

        final updatedHabit = habit.copyWith(
          difficultyLevel: newDifficultyLevel,
          targetMinutes: suggestedMinutes,
          lastAdjustedAt: clock.now(),
        );

        await habitsRepository.updateHabitInstance(updatedHabit);

        developer.log(
          'HabitPredictorService: User accepted nudge for habit ${habit.name}',
          name: 'HabitPredictorService',
        );
      } else {
        developer.log(
          'HabitPredictorService: User declined nudge for habit $habitId',
          name: 'HabitPredictorService',
        );
      }
    } catch (e) {
      developer.log(
        'HabitPredictorService: Error handling nudge response: $e',
        name: 'HabitPredictorService',
        error: e,
      );
    }
  }
}
