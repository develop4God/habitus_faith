import 'package:flutter/material.dart';

enum GoalType {
  year,
  month,
  week,
  custom;

  String get displayName {
    switch (this) {
      case GoalType.year:
        return 'Anual';
      case GoalType.month:
        return 'Mensual';
      case GoalType.week:
        return 'Semanal';
      case GoalType.custom:
        return 'Personalizado';
    }
  }
}

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalType type;
  final DateTime deadline;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String? emoji;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.deadline,
    this.progress = 0.0,
    this.isCompleted = false,
    this.emoji,
    required this.createdAt,
  });

  Goal copyWith({
    String? title,
    String? description,
    GoalType? type,
    DateTime? deadline,
    double? progress,
    bool? isCompleted,
    String? emoji,
  }) {
    return Goal(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'deadline': deadline.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      deadline: DateTime.parse(json['deadline'] as String),
      progress: (json['progress'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool,
      emoji: json['emoji'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
