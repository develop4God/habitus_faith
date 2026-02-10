/// Represents unlockable devotional content
enum ContentType {
  bibleStudyPlan,
  devotional,
  prayer,
  meditation;

  String get displayName {
    switch (this) {
      case ContentType.bibleStudyPlan:
        return 'Bible Study Plan';
      case ContentType.devotional:
        return 'Devotional';
      case ContentType.prayer:
        return 'Prayer Guide';
      case ContentType.meditation:
        return 'Meditation';
    }
  }
}

class UnlockableContent {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final int requiredPoints;
  final int? requiredStageIndex; // Index in JourneyStage enum
  final String? contentUrl;
  final String? thumbnailUrl;
  final bool isPremium; // Premium content differentiator

  const UnlockableContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredPoints,
    this.requiredStageIndex,
    this.contentUrl,
    this.thumbnailUrl,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'requiredPoints': requiredPoints,
      'requiredStageIndex': requiredStageIndex,
      'contentUrl': contentUrl,
      'thumbnailUrl': thumbnailUrl,
      'isPremium': isPremium,
    };
  }

  factory UnlockableContent.fromJson(Map<String, dynamic> json) {
    return UnlockableContent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ContentType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      requiredPoints: json['requiredPoints'] as int,
      requiredStageIndex: json['requiredStageIndex'] as int?,
      contentUrl: json['contentUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}

class UserUnlock {
  final String userId;
  final String contentId;
  final DateTime unlockedAt;

  const UserUnlock({
    required this.userId,
    required this.contentId,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'contentId': contentId,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory UserUnlock.fromJson(Map<String, dynamic> json) {
    return UserUnlock(
      userId: json['userId'] as String,
      contentId: json['contentId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }
}
