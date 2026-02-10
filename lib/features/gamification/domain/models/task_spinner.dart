/// Represents a task in the spinner for non-spiritual habits/chores
class TaskSpinnerItem {
  final String id;
  final String userId;
  final String taskName;
  final String? emoji;
  final int priority; // 1-5, affects probability in spinner
  final DateTime createdAt;
  final DateTime? lastCompletedAt;
  final int timesCompleted;
  final bool isActive;

  const TaskSpinnerItem({
    required this.id,
    required this.userId,
    required this.taskName,
    this.emoji,
    this.priority = 3,
    required this.createdAt,
    this.lastCompletedAt,
    this.timesCompleted = 0,
    this.isActive = true,
  });

  /// Mark task as completed
  TaskSpinnerItem complete(DateTime timestamp) {
    return TaskSpinnerItem(
      id: id,
      userId: userId,
      taskName: taskName,
      emoji: emoji,
      priority: priority,
      createdAt: createdAt,
      lastCompletedAt: timestamp,
      timesCompleted: timesCompleted + 1,
      isActive: isActive,
    );
  }

  /// Toggle active status
  TaskSpinnerItem toggleActive() {
    return TaskSpinnerItem(
      id: id,
      userId: userId,
      taskName: taskName,
      emoji: emoji,
      priority: priority,
      createdAt: createdAt,
      lastCompletedAt: lastCompletedAt,
      timesCompleted: timesCompleted,
      isActive: !isActive,
    );
  }

  /// Calculate weight for spinner (higher priority = more likely to be selected)
  double get spinnerWeight {
    // Priority 1-5 → weight 1-5
    // Tasks not done today get 2x weight boost
    final baseWeight = priority.toDouble();
    
    if (lastCompletedAt == null) {
      return baseWeight * 2; // Never completed, boost weight
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    
    if (lastCompleted == today) {
      return baseWeight * 0.5; // Already done today, reduce weight
    }
    
    return baseWeight * 2; // Not done today, boost weight
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taskName': taskName,
      'emoji': emoji,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'timesCompleted': timesCompleted,
      'isActive': isActive,
    };
  }

  factory TaskSpinnerItem.fromJson(Map<String, dynamic> json) {
    return TaskSpinnerItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskName: json['taskName'] as String,
      emoji: json['emoji'] as String?,
      priority: json['priority'] as int? ?? 3,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      timesCompleted: json['timesCompleted'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

/// Result of spinning the wheel
class SpinResult {
  final TaskSpinnerItem selectedTask;
  final DateTime spunAt;
  final int pointsAwarded;

  const SpinResult({
    required this.selectedTask,
    required this.spunAt,
    this.pointsAwarded = 10, // Base points for completing a spinner task
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedTask': selectedTask.toJson(),
      'spunAt': spunAt.toIso8601String(),
      'pointsAwarded': pointsAwarded,
    };
  }

  factory SpinResult.fromJson(Map<String, dynamic> json) {
    return SpinResult(
      selectedTask:
          TaskSpinnerItem.fromJson(json['selectedTask'] as Map<String, dynamic>),
      spunAt: DateTime.parse(json['spunAt'] as String),
      pointsAwarded: json['pointsAwarded'] as int? ?? 10,
    );
  }
}
