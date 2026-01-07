import 'dart:convert';
import 'dart:math' as math;
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
///
/// **Budget Optimization:**
/// - Uses 10% sampling to reduce Firestore writes (10K/day → 1K/day)
/// - Batches records (writes every 100 records instead of per prediction)
/// - Target: <200 writes/day total across all users
class MLTelemetryService {
  final FirebaseFirestore? _firestore;
  final Clock clock;
  final String appVersion;
  
  // Batching configuration
  static const int batchSize = 100; // Write after 100 records
  final double samplingRate; // Configurable sampling rate for testing
  
  // Internal buffer for batching
  final List<Map<String, dynamic>> _buffer = [];
  final math.Random _random;

  MLTelemetryService({
    FirebaseFirestore? firestore,
    Clock? clock,
    this.appVersion = '1.0.0', // Default version, should be injected
    this.samplingRate = 0.10, // Default 10% sampling, 1.0 = 100% for tests
    math.Random? random, // Allow injection for testing
  })  : _firestore = firestore,
        clock = clock ?? const Clock.system(),
        _random = random ?? math.Random();

  /// Log a prediction with all features for monitoring
  ///
  /// **Budget Optimization:**
  /// - Samples 10% of predictions (reduces 10K writes/day → 1K/day)
  /// - Buffers records and writes in batches of 100
  /// - Automatically flushes when buffer is full
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

    // Sampling: Only log 10% of predictions to reduce costs
    if (_random.nextDouble() > samplingRate) {
      debugPrint(
        'MLTelemetryService: Skipped prediction (sampling: ${(samplingRate * 100).toInt()}%)',
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
        'timestamp': Timestamp.fromDate(now), // Use Timestamp for buffering
        'days_since_last_completion': daysSinceLastCompletion,
      };

      // Add to buffer instead of immediate write
      _buffer.add(telemetryData);

      debugPrint(
        'MLTelemetryService: Buffered prediction for habit ${habit.id} '
        '(risk=$predictedRisk, abandoned=$isAbandoned, buffer: ${_buffer.length}/$batchSize)',
      );

      // Flush if buffer is full
      if (_buffer.length >= batchSize) {
        await flush();
      }
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to log prediction: $e');
      // Non-critical - don't throw
    }
  }

  /// Flush buffered telemetry records to Firestore
  ///
  /// Writes all buffered records in a single batch operation
  /// Call this manually before app termination or when needed
  Future<void> flush() async {
    if (_firestore == null || _buffer.isEmpty) {
      return;
    }

    try {
      final batch = _firestore!.batch();
      final collection = _firestore!.collection('ml_telemetry');

      for (final record in _buffer) {
        final docRef = collection.doc(); // Auto-generate unique ID
        batch.set(docRef, record);
      }

      await batch.commit();

      debugPrint(
        'MLTelemetryService: Flushed ${_buffer.length} records to Firestore',
      );

      _buffer.clear();
    } catch (e) {
      debugPrint('MLTelemetryService: Failed to flush buffer: $e');
      // Keep records in buffer for retry
    }
  }

  /// Get current buffer size
  ///
  /// Useful for monitoring and testing
  int get bufferSize => _buffer.length;

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
