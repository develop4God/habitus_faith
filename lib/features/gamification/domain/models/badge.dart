/// Represents the nine fruits of the Spirit as collectible badges
enum FruitOfSpirit {
  love,
  joy,
  peace,
  patience,
  kindness,
  goodness,
  faithfulness,
  gentleness,
  selfControl;

  String get displayName {
    switch (this) {
      case FruitOfSpirit.love:
        return 'Love';
      case FruitOfSpirit.joy:
        return 'Joy';
      case FruitOfSpirit.peace:
        return 'Peace';
      case FruitOfSpirit.patience:
        return 'Patience';
      case FruitOfSpirit.kindness:
        return 'Kindness';
      case FruitOfSpirit.goodness:
        return 'Goodness';
      case FruitOfSpirit.faithfulness:
        return 'Faithfulness';
      case FruitOfSpirit.gentleness:
        return 'Gentleness';
      case FruitOfSpirit.selfControl:
        return 'Self-Control';
    }
  }

  String get description {
    switch (this) {
      case FruitOfSpirit.love:
        return 'Complete 50 spiritual habits';
      case FruitOfSpirit.joy:
        return 'Maintain a 7-day streak';
      case FruitOfSpirit.peace:
        return 'Complete all daily habits for 3 consecutive days';
      case FruitOfSpirit.patience:
        return 'Continue practicing for 30 days';
      case FruitOfSpirit.kindness:
        return 'Complete 20 relational habits';
      case FruitOfSpirit.goodness:
        return 'Complete 100 total habits';
      case FruitOfSpirit.faithfulness:
        return 'Maintain a 30-day streak';
      case FruitOfSpirit.gentleness:
        return 'Help others by sharing habits';
      case FruitOfSpirit.selfControl:
        return 'Complete 50 physical or mental habits';
    }
  }

  String get emoji {
    switch (this) {
      case FruitOfSpirit.love:
        return '❤️';
      case FruitOfSpirit.joy:
        return '😊';
      case FruitOfSpirit.peace:
        return '🕊️';
      case FruitOfSpirit.patience:
        return '⏳';
      case FruitOfSpirit.kindness:
        return '🤝';
      case FruitOfSpirit.goodness:
        return '✨';
      case FruitOfSpirit.faithfulness:
        return '🛡️';
      case FruitOfSpirit.gentleness:
        return '🌸';
      case FruitOfSpirit.selfControl:
        return '💪';
    }
  }

  /// Points required to unlock this badge
  int get requiredPoints {
    switch (this) {
      case FruitOfSpirit.love:
        return 200;
      case FruitOfSpirit.joy:
        return 150;
      case FruitOfSpirit.peace:
        return 100;
      case FruitOfSpirit.patience:
        return 400;
      case FruitOfSpirit.kindness:
        return 250;
      case FruitOfSpirit.goodness:
        return 500;
      case FruitOfSpirit.faithfulness:
        return 800;
      case FruitOfSpirit.gentleness:
        return 300;
      case FruitOfSpirit.selfControl:
        return 350;
    }
  }
}

class Badge {
  final String id;
  final String userId;
  final FruitOfSpirit fruit;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const Badge({
    required this.id,
    required this.userId,
    required this.fruit,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Badge unlock(DateTime timestamp) {
    return Badge(
      id: id,
      userId: userId,
      fruit: fruit,
      unlockedAt: timestamp,
      isUnlocked: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fruit': fruit.name,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fruit: FruitOfSpirit.values.firstWhere(
        (f) => f.name == json['fruit'],
      ),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool,
    );
  }
}
