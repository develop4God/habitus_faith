/// Onboarding models for adaptive user intent flow
enum UserIntent {
  faithBased,
  wellness,
  both;

  String toJson() => name;

  static UserIntent fromJson(String json) {
    return UserIntent.values.firstWhere((e) => e.name == json);
  }
}

/// Onboarding profile that captures user intent and preferences
class OnboardingProfile {
  final UserIntent primaryIntent;
  final List<String> motivations;
  final String challenge;
  final String supportLevel;
  final String? spiritualMaturity; // null if wellness-only
  final String commitment;
  final DateTime completedAt;

  const OnboardingProfile({
    required this.primaryIntent,
    required this.motivations,
    required this.challenge,
    required this.supportLevel,
    this.spiritualMaturity,
    required this.commitment,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryIntent': primaryIntent.toJson(),
      'motivations': motivations,
      'challenge': challenge,
      'supportLevel': supportLevel,
      'spiritualMaturity': spiritualMaturity,
      'commitment': commitment,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      primaryIntent: UserIntent.fromJson(json['primaryIntent'] as String),
      motivations: (json['motivations'] as List<dynamic>).cast<String>(),
      challenge: json['challenge'] as String,
      supportLevel: json['supportLevel'] as String,
      spiritualMaturity: json['spiritualMaturity'] as String?,
      commitment: json['commitment'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  OnboardingProfile copyWith({
    UserIntent? primaryIntent,
    List<String>? motivations,
    String? challenge,
    String? supportLevel,
    String? spiritualMaturity,
    String? commitment,
    DateTime? completedAt,
  }) {
    return OnboardingProfile(
      primaryIntent: primaryIntent ?? this.primaryIntent,
      motivations: motivations ?? this.motivations,
      challenge: challenge ?? this.challenge,
      supportLevel: supportLevel ?? this.supportLevel,
      spiritualMaturity: spiritualMaturity ?? this.spiritualMaturity,
      commitment: commitment ?? this.commitment,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

extension OnboardingProfileCache on OnboardingProfile {
  String get cacheFingerprint {
    final key = '${primaryIntent.name}_${spiritualMaturity}_${motivations.join('_')}_$challenge';
    return key.hashCode.toString();
  }

  double similarityTo(OnboardingProfile other) {
    double score = 0.0;
    // Intent match (peso: 40%)
    if (primaryIntent == other.primaryIntent) score += 0.4;
    // Spiritual maturity (peso: 20%)
    if (spiritualMaturity == other.spiritualMaturity) score += 0.2;
    // Motivations overlap (peso: 20%)
    final commonMotivations = motivations.toSet().intersection(other.motivations.toSet());
    score += 0.2 * (commonMotivations.length / motivations.length);
    // Challenge similarity (peso: 20%)
    if (challenge == other.challenge) score += 0.2;
    return score;
  }
}
