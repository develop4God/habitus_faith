import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/domain/ml_features_calculator.dart';
import '../time/time.dart';

/// ML Telemetry Service for collecting prediction data and exporting for retraining
///
/// Responsibilities:
/// - Log all prediction features for quality monitoring
/// - Track abandoned vs completed habits (7-day inactivity rule)
/// - Add metadata (app version, user segment)
/// - Enable batch export to JSON/CSV for model retraining
class MLTelemetryService {
  final FirebaseFirestore? _firestore;
  final Clock clock;
  final String appVersion;

  MLTelemetryService({
    FirebaseFirestore? firestore,
    Clock? clock,
    this.appVersion = '1.0.0', // Default version, should be injected
  })  : _firestore = firestore,
        clock = clock ?? const Clock.system();

  /// Log a prediction with all features for monitoring
  ///
  /// Features logged (matching training pipeline):
  /// 1. hourOfDay - Hour when prediction was made
  /// 2. dayOfWeek - Day of week when prediction was made
  /// 3. currentStreak - User's current streak
  /// 4. failuresLast7Days - Failures in last 7 days
  /// 5. hoursFromReminder - Hours from scheduled reminder
  ///
  /// Additional metadata:
  /// - predicted_risk: The model's output (0.0-1.0)
  /// - app_version: Current app version
  /// - user_segment: User engagement level (new/active/veteran)
  /// - timestamp: When prediction was made
  /// - habit_category: Category of the habit
  Future<void> logPrediction({
    required Habit habit,
    required double predictedRisk,
  }) async {
    if (_firestore == null) {
      debugPrint(
        'MLTelemetryService: Firestore not available, skipping telemetry',
      );
      return;
    }

    try {
      final now = clock.now();

      // Calculate all features (matching training pipeline order)
      final hourOfDay = now.hour;
      final dayOfWeek = now.weekday;
      final currentStreak = habit.currentStreak;
      final failuresLast7Days = MLFeaturesCalculator.countRecentFailures(
        habit,
        7,
        now: now,
      );
      final hoursFromReminder = MLFeaturesCalculator.calculateHoursFromReminder(
        habit,
        now,
      );

      // Determine user segment based on habit history
      final userSegment = _calculateUserSegment(habit);

      // Calculate if habit is abandoned (7-day inactivity rule)
      final daysSinceLastCompletion = habit.lastCompletedAt != null
          ? now.difference(habit.lastCompletedAt!).inDays
          : 999;
      final isAbandoned = daysSinceLastCompletion >= 7;

      final telemetryData = {
        // Features (exact order as training pipeline)
        'feature_1_hourOfDay': hourOfDay,
        'feature_2_dayOfWeek': dayOfWeek,
        'feature_3_currentStreak': currentStreak,
        'feature_4_failuresLast7Days': failuresLast7Days,
        'feature_5_hoursFromReminder': hoursFromReminder,

        // Labels
        'predicted_risk': predictedRisk,
        'abandoned': isAbandoned,
        'completed': !isAbandoned,

        // Metadata
        'app_version': appVersion,
        'user_segment': userSegment,
        'habit_category': habit.category.name,
        'habit_id': habit.id,
        'user_id': habit.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'days_since_last_completion': daysSinceLastCompletion,
      };

      await _firestore!
          .collection('ml_telemetry')
          .add(telemetryData); // Use add() for auto-generated unique IDs
      // This ensures each prediction is logged separately even if multiple
      // predictions happen in the same millisecond (e.g., batch processing)

      debugPrint(
        'MLTelemetryService: Logged prediction for habit ${habit.id} '
        '(risk=$predictedRisk, abandoned=$isAbandoned)',
      );
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to log prediction: $e');
      // Non-critical - don't throw
    }
  }

  /// Calculate user engagement segment
  String _calculateUserSegment(Habit habit) {
    final totalCompletions = habit.completionHistory.length;
    final habitAgeDays = clock.now().difference(habit.createdAt).inDays;

    // New user: habit < 7 days old or < 5 completions
    if (habitAgeDays < 7 || totalCompletions < 5) {
      return 'new';
    }

    // Veteran: habit > 30 days old with > 50 completions
    if (habitAgeDays > 30 && totalCompletions > 50) {
      return 'veteran';
    }

    // Active: everything in between
    return 'active';
  }

  /// Export telemetry data for a specific user to JSON format
  ///
  /// Useful for batch retraining or debugging
  /// Returns list of telemetry records ready for ML training
  Future<List<Map<String, dynamic>>> exportUserTelemetry({
    required String userId,
    DateTime? since,
    int? limit,
  }) async {
    if (_firestore == null) {
      debugPrint('MLTelemetryService: Firestore not available');
      return [];
    }

    try {
      var query = _firestore!
          .collection('ml_telemetry')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final records = snapshot.docs.map((doc) => doc.data()).toList();

      debugPrint(
        'MLTelemetryService: Exported ${records.length} telemetry records for user $userId',
      );

      return records;
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to export telemetry: $e');
      return [];
    }
  }

  /// Export all telemetry data to JSON format
  ///
  /// Format matches ml_pipeline/data/ schema for retraining
  /// Returns JSON string ready for file export or API transmission
  Future<String> exportAllTelemetryAsJson({
    DateTime? since,
    int? limit,
  }) async {
    if (_firestore == null) {
      debugPrint('MLTelemetryService: Firestore not available');
      return '[]';
    }

    try {
      var query = _firestore!
          .collection('ml_telemetry')
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        // Transform to training format
        return {
          'hourOfDay': data['feature_1_hourOfDay'],
          'dayOfWeek': data['feature_2_dayOfWeek'],
          'streakAtTime': data['feature_3_currentStreak'],
          'failuresLast7Days': data['feature_4_failuresLast7Days'],
          'hoursFromReminder': data['feature_5_hoursFromReminder'],
          'abandoned': data['abandoned'],
          'predicted_risk': data['predicted_risk'],
          'app_version': data['app_version'],
          'user_segment': data['user_segment'],
          'habit_category': data['habit_category'],
        };
      }).toList();

      final jsonString = jsonEncode(records);

      debugPrint(
        'MLTelemetryService: Exported ${records.length} records as JSON',
      );

      return jsonString;
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to export JSON: $e');
      return '[]';
    }
  }

  /// Export telemetry data to CSV format
  ///
  /// Format matches ml_pipeline expectations for training
  Future<String> exportAllTelemetryAsCsv({
    DateTime? since,
    int? limit,
  }) async {
    if (_firestore == null) {
      debugPrint('MLTelemetryService: Firestore not available');
      return '';
    }

    try {
      var query = _firestore!
          .collection('ml_telemetry')
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      // CSV header (matching training data format)
      final csvLines = <String>[
        'hourOfDay,dayOfWeek,streakAtTime,failuresLast7Days,hoursFromReminder,abandoned',
      ];

      // CSV rows
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final row = [
          data['feature_1_hourOfDay'],
          data['feature_2_dayOfWeek'],
          data['feature_3_currentStreak'],
          data['feature_4_failuresLast7Days'],
          data['feature_5_hoursFromReminder'],
          data['abandoned'] ? 1 : 0,
        ].join(',');
        csvLines.add(row);
      }

      final csv = csvLines.join('\n');

      debugPrint(
        'MLTelemetryService: Exported ${csvLines.length - 1} records as CSV',
      );

      return csv;
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to export CSV: $e');
      return '';
    }
  }

  /// Get telemetry statistics
  ///
  /// Useful for monitoring data collection quality
  Future<Map<String, dynamic>> getTelemetryStats() async {
    if (_firestore == null) {
      return {
        'total_records': 0,
        'abandoned_count': 0,
        'completed_count': 0,
      };
    }

    try {
      final snapshot = await _firestore!.collection('ml_telemetry').get();

      var abandonedCount = 0;
      var completedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['abandoned'] == true) {
          abandonedCount++;
        } else {
          completedCount++;
        }
      }

      return {
        'total_records': snapshot.docs.length,
        'abandoned_count': abandonedCount,
        'completed_count': completedCount,
        'abandoned_rate': snapshot.docs.isNotEmpty
            ? abandonedCount / snapshot.docs.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to get stats: $e');
      return {
        'total_records': 0,
        'abandoned_count': 0,
        'completed_count': 0,
        'error': e.toString(),
      };
    }
  }
}
