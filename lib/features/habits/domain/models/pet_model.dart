import '../../../../l10n/app_localizations.dart';

/// Pet model for companion feature
class Pet {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final DateTime createdAt;

  const Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Pet copyWith({
    String? id,
    String? userId,
    String? name,
    String? emoji,
    DateTime? createdAt,
  }) {
    return Pet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Extension to localize pet names stored in Firebase
extension FirebasePetLocalization on Pet {
  /// Get the localized name for this pet
  String getLocalizedName(AppLocalizations l10n) {
    // Map i18n keys to translated strings
    switch (name) {
      case 'pet_Perrito':
        return l10n.pet_Perrito;
      case 'pet_Gatito':
        return l10n.pet_Gatito;
      case 'pet_Tigre':
        return l10n.pet_Tigre;
      case 'pet_PezLeon':
        return l10n.pet_PezLeon;
      case 'pet_Leoncito':
        return l10n.pet_Leoncito;
      case 'pet_Panda':
        return l10n.pet_Panda;
      case 'pet_Unicornio':
        return l10n.pet_Unicornio;
      default:
        return name; // Fallback if not an i18n key
    }
  }
}
