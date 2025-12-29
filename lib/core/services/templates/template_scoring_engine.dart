import '../../../features/habits/presentation/onboarding/onboarding_models.dart';

/// Confidence level for template matching scores
enum MatchConfidence {
  /// Excellent match (score ≥ 0.90)
  excellent,

  /// Good match (score ≥ 0.75)
  good,

  /// Low confidence match (score < 0.75)
  low;

  /// Create confidence from score
  static MatchConfidence fromScore(double score) {
    if (score >= 0.90) return MatchConfidence.excellent;
    if (score >= 0.75) return MatchConfidence.good;
    return MatchConfidence.low;
  }
}

/// User profile vector extracted from OnboardingProfile for scoring
class UserProfileVector {
  final UserIntent primaryIntent;
  final String supportLevel;
  final String challenge;
  final List<String> motivations;
  final String? spiritualMaturity;

  const UserProfileVector({
    required this.primaryIntent,
    required this.supportLevel,
    required this.challenge,
    required this.motivations,
    this.spiritualMaturity,
  });

  /// Create from OnboardingProfile
  factory UserProfileVector.fromProfile(OnboardingProfile profile) {
    return UserProfileVector(
      primaryIntent: profile.primaryIntent,
      supportLevel: profile.supportLevel,
      challenge: profile.challenge,
      motivations: profile.motivations,
      spiritualMaturity: profile.spiritualMaturity,
    );
  }
}

/// Template metadata parsed from template JSON
class TemplateMetadata {
  final String patternId;
  final UserIntent primaryIntent;
  final String supportLevel;
  final String challenge;
  final List<String> motivations;
  final String? spiritualMaturity;

  const TemplateMetadata({
    required this.patternId,
    required this.primaryIntent,
    required this.supportLevel,
    required this.challenge,
    required this.motivations,
    this.spiritualMaturity,
  });

  /// Parse from pattern ID string
  /// Format: intent_supportLevel_challenge_motivation1_motivation2_maturity
  factory TemplateMetadata.fromPatternId(String patternId) {
    final parts = patternId.split('_');
    if (parts.length < 5) {
      throw ArgumentError('Invalid pattern ID format: $patternId');
    }

    // Parse intent
    final intent = UserIntent.values.firstWhere(
      (e) => e.name == parts[0],
      orElse: () => UserIntent.faithBased,
    );

    // Extract motivations (positions 3 and 4)
    final motivations = <String>[];
    if (parts.length > 3) motivations.add(parts[3]);
    if (parts.length > 4) motivations.add(parts[4]);

    // Spiritual maturity is the last part
    final maturity = parts.length > 5 ? parts[5] : null;

    return TemplateMetadata(
      patternId: patternId,
      primaryIntent: intent,
      supportLevel: parts[1],
      challenge: parts[2],
      motivations: motivations,
      spiritualMaturity: maturity,
    );
  }
}

/// Template match score with dimension breakdown
class TemplateMatchScore {
  /// Total weighted score (0.0 to 1.0)
  final double totalScore;

  /// Individual dimension scores
  final Map<String, double> dimensionScores;

  /// Match confidence level
  final MatchConfidence confidence;

  /// Template pattern ID
  final String patternId;

  const TemplateMatchScore({
    required this.totalScore,
    required this.dimensionScores,
    required this.confidence,
    required this.patternId,
  });
}

/// Scoring engine that calculates similarity between user profiles and templates
class TemplateScoringEngine {
  /// Scoring weights (must sum to 1.0)
  final double intentWeight;
  final double supportLevelWeight;
  final double challengeWeight;
  final double motivationsWeight;
  final double spiritualMaturityWeight;

  /// Support level similarity map
  static const Map<String, Map<String, double>> _supportLevelSimilarity = {
    'strong': {'strong': 1.0, 'growing': 0.7, 'inconsistent': 0.3},
    'growing': {'strong': 0.7, 'growing': 1.0, 'inconsistent': 0.6},
    'inconsistent': {'strong': 0.3, 'growing': 0.6, 'inconsistent': 1.0},
    'normal': {
      'normal': 1.0,
      'strong': 0.8,
      'growing': 0.8,
      'inconsistent': 0.5
    },
  };

  /// Related challenges by domain
  static const Map<String, List<String>> _challengeDomains = {
    'time': ['lackOfTime', 'dontKnowStart'],
    'motivation': ['lackOfMotivation', 'givingUp'],
    'knowledge': ['dontKnowStart', 'lackOfMotivation'],
  };

  /// Spiritual maturity progression
  static const List<String> _maturityProgression = [
    'new',
    'growing',
    'passionate',
  ];

  /// Create scoring engine with default or custom weights
  TemplateScoringEngine({
    this.intentWeight = 0.40,
    this.supportLevelWeight = 0.20,
    this.challengeWeight = 0.20,
    this.motivationsWeight = 0.15,
    this.spiritualMaturityWeight = 0.05,
  }) {
    // Validate weights sum to 1.0 (with small tolerance for floating point)
    final sum = intentWeight +
        supportLevelWeight +
        challengeWeight +
        motivationsWeight +
        spiritualMaturityWeight;
    if ((sum - 1.0).abs() > 0.001) {
      throw ArgumentError('Weights must sum to 1.0, got $sum');
    }
  }

  /// Calculate match score between user profile and template
  TemplateMatchScore calculateScore(
    UserProfileVector user,
    TemplateMetadata template,
  ) {
    final dimensionScores = <String, double>{};

    // Calculate individual dimension scores
    dimensionScores['intent'] = _scoreIntent(user, template);
    dimensionScores['supportLevel'] = _scoreSupportLevel(user, template);
    dimensionScores['challenge'] = _scoreChallenge(user, template);
    dimensionScores['motivations'] = _scoreMotivations(user, template);
    dimensionScores['spiritualMaturity'] = _scoreMaturity(user, template);

    // Calculate weighted total score
    final totalScore = (dimensionScores['intent']! * intentWeight) +
        (dimensionScores['supportLevel']! * supportLevelWeight) +
        (dimensionScores['challenge']! * challengeWeight) +
        (dimensionScores['motivations']! * motivationsWeight) +
        (dimensionScores['spiritualMaturity']! * spiritualMaturityWeight);

    final confidence = MatchConfidence.fromScore(totalScore);

    return TemplateMatchScore(
      totalScore: totalScore,
      dimensionScores: dimensionScores,
      confidence: confidence,
      patternId: template.patternId,
    );
  }

  /// Score primary intent match
  /// - 1.0 for exact match
  /// - 0.7 for 'both' compatibility
  /// - 0.0 otherwise
  double _scoreIntent(UserProfileVector user, TemplateMetadata template) {
    if (user.primaryIntent == template.primaryIntent) {
      return 1.0;
    }
    // 'both' is compatible with both faithBased and wellness
    if (user.primaryIntent == UserIntent.both ||
        template.primaryIntent == UserIntent.both) {
      return 0.7;
    }
    return 0.0;
  }

  /// Score support level similarity
  /// Uses predefined similarity map
  double _scoreSupportLevel(UserProfileVector user, TemplateMetadata template) {
    final userLevel = user.supportLevel;
    final templateLevel = template.supportLevel;

    // Try exact mapping first
    if (_supportLevelSimilarity.containsKey(userLevel)) {
      final similarities = _supportLevelSimilarity[userLevel]!;
      if (similarities.containsKey(templateLevel)) {
        return similarities[templateLevel]!;
      }
    }

    // Fallback: exact match gets 1.0, otherwise 0.5
    return userLevel == templateLevel ? 1.0 : 0.5;
  }

  /// Score challenge match
  /// - 1.0 for exact match
  /// - 0.6 for related challenges (same domain)
  /// - 0.2 for different but same general domain
  double _scoreChallenge(UserProfileVector user, TemplateMetadata template) {
    if (user.challenge == template.challenge) {
      return 1.0;
    }

    // Check if challenges are in the same domain
    for (final domain in _challengeDomains.values) {
      if (domain.contains(user.challenge) &&
          domain.contains(template.challenge)) {
        return 0.6;
      }
    }

    return 0.2;
  }

  /// Score motivations using Jaccard similarity
  /// Jaccard = |intersection| / |union|
  double _scoreMotivations(UserProfileVector user, TemplateMetadata template) {
    final userSet = user.motivations.toSet();
    final templateSet = template.motivations.toSet();

    if (userSet.isEmpty && templateSet.isEmpty) {
      return 1.0;
    }

    final intersection = userSet.intersection(templateSet);
    final union = userSet.union(templateSet);

    if (union.isEmpty) {
      return 0.0;
    }

    return intersection.length / union.length;
  }

  /// Score spiritual maturity match
  /// - 1.0 for exact match
  /// - 0.7 for adjacent levels
  /// - 0.4 otherwise
  double _scoreMaturity(UserProfileVector user, TemplateMetadata template) {
    // If either is null, handle gracefully
    if (user.spiritualMaturity == null && template.spiritualMaturity == null) {
      return 1.0;
    }
    if (user.spiritualMaturity == null || template.spiritualMaturity == null) {
      return 0.4;
    }

    if (user.spiritualMaturity == template.spiritualMaturity) {
      return 1.0;
    }

    // Check if they are adjacent in progression
    final userIndex = _maturityProgression.indexOf(user.spiritualMaturity!);
    final templateIndex =
        _maturityProgression.indexOf(template.spiritualMaturity!);

    if (userIndex != -1 && templateIndex != -1) {
      final distance = (userIndex - templateIndex).abs();
      if (distance == 1) {
        return 0.7; // Adjacent levels
      }
    }

    return 0.4;
  }
}
