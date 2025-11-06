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
import '../../l10n/app_localizations.dart';

/// Provider for managing daily habit predictions and interventions
/// Runs predictions daily at 6am via background task
final habitPredictorProvider = Provider<HabitPredictorService>((ref) {
  final habitsRepository = ref.watch(jsonHabitsRepositoryProvider);
  final predictor = ref.watch(abandonmentPredictorProvider);

  return HabitPredictorService(
    habitsRepository: habitsRepository,
    predictor: predictor,
  );
});

/// Service for running daily habit predictions and triggering interventions
class HabitPredictorService {
  final dynamic habitsRepository; // JsonHabitsRepository
  final AbandonmentPredictor predictor;

  HabitPredictorService({
    required this.habitsRepository,
    required this.predictor,
  });

  /// Run daily predictions for all habits
  /// Called by background task at 6:00 AM
  ///
  /// For each habit:
  /// 1. Predict abandonment risk using ML model
  /// 2. Update abandonmentRisk field
  /// 3. If risk >= intervention threshold: calculate new difficulty and show nudge notification
  Future<void> runDailyPredictions() async {
    developer.log(
      'HabitPredictorService: Starting daily predictions',
      name: 'HabitPredictorService',
    );

    try {
      // Get all active (non-archived) habits
      final habits = await habitsRepository.getAllHabits();
      final activeHabits = habits.where((h) => !h.isArchived).toList();

      developer.log(
        'HabitPredictorService: Processing ${activeHabits.length} active habits',
        name: 'HabitPredictorService',
      );

      int processedCount = 0;
      int highRiskCount = 0;

      for (final habit in activeHabits) {
        try {
          await _processSingleHabit(habit);
          processedCount++;

          // Track high-risk habits
          if (habit.abandonmentRisk > 0.65) {
            highRiskCount++;
          }
        } catch (e) {
          developer.log(
            'HabitPredictorService: Error processing habit ${habit.id}: $e',
            name: 'HabitPredictorService',
            error: e,
          );
        }
      }

      developer.log(
        'HabitPredictorService: Daily predictions complete. '
        'Processed: $processedCount, High-risk: $highRiskCount',
        name: 'HabitPredictorService',
      );
    } catch (e) {
      developer.log(
        'HabitPredictorService: Daily predictions failed: $e',
        name: 'HabitPredictorService',
        error: e,
      );
    }
  }

  /// Process a single habit: predict risk, update fields, send notifications
  Future<void> _processSingleHabit(Habit habit) async {
    // Skip habits already completed today
    if (habit.completedToday) {
      developer.log(
        'HabitPredictorService: Skipping habit ${habit.name} (already completed)',
        name: 'HabitPredictorService',
      );
      return;
    }

    // Predict abandonment risk
    final risk = await predictor.predictRisk(habit);

    developer.log(
      'HabitPredictorService: Habit "${habit.name}" risk: ${(risk * 100).toStringAsFixed(1)}%',
      name: 'HabitPredictorService',
    );

    // Update abandonmentRisk field
    final updatedHabit = habit.copyWith(abandonmentRisk: risk);

    // If risk requires intervention: apply intervention
    if (RiskThresholds.requiresIntervention(risk)) {
      await _applyIntervention(updatedHabit);
    } else {
      // Just update the risk value
      await habitsRepository.updateHabit(updatedHabit);
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
      final engine = BehavioralEngine();
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
      await habitsRepository.updateHabit(habit);
    } catch (e) {
      developer.log(
        'HabitPredictorService: Error applying intervention for habit ${habit.id}: $e',
        name: 'HabitPredictorService',
        error: e,
      );
    }
  }

  /// Show nudge notification suggesting difficulty reduction
  Future<void> _showNudgeNotification({
    required String habitName,
    required int currentMinutes,
    required int suggestedMinutes,
    required String habitId,
  }) async {
    try {
      // Get locale from SharedPreferences (since we're in background/isolate)
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString('locale') ?? 'es';

      // Load localized strings without BuildContext
      final locale = Locale(localeCode);
      final localizations = lookupAppLocalizations(locale);

      // Get localized title and body using parameterized methods
      final title = localizations.abandonmentNudgeTitle(habitName);
      final body = localizations.abandonmentNudgeBody(suggestedMinutes);

      final notificationService = NotificationService();

      await notificationService.showImmediateNotification(
        title,
        body,
        payload: 'habit_nudge:$habitId:$suggestedMinutes',
        id: habitId.hashCode,
      );

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
        final habits = await habitsRepository.getAllHabits();
        final habit = habits.firstWhere((h) => h.id == habitId);

        // Calculate new difficulty level from suggested minutes
        final newDifficultyLevel = Habit.targetMinutesByLevel.entries
            .firstWhere((entry) => entry.value == suggestedMinutes,
                orElse: () => const MapEntry(3, 20))
            .key;

        final updatedHabit = habit.copyWith(
          difficultyLevel: newDifficultyLevel,
          targetMinutes: suggestedMinutes,
          lastAdjustedAt: DateTime.now(),
        );

        await habitsRepository.updateHabit(updatedHabit);

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
