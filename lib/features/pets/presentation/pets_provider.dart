import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet_model.dart';
import '../../../l10n/app_localizations.dart';

class PetBackgroundTheme {
  final String id;
  final List<Color> colors;

  const PetBackgroundTheme({required this.id, required this.colors});
}

final petThemesProvider = Provider<List<PetBackgroundTheme>>((ref) {
  return [
    const PetBackgroundTheme(
      id: 'sunset',
      colors: [Color(0xFFFF7043), Color(0xFFFFB74D)], // Original Orange
    ),
    const PetBackgroundTheme(
      id: 'ocean',
      colors: [Color(0xFF2196F3), Color(0xFF4FC3F7)], // Blue
    ),
    const PetBackgroundTheme(
      id: 'forest',
      colors: [Color(0xFF66BB6A), Color(0xFF9CCC65)], // Green
    ),
    const PetBackgroundTheme(
      id: 'royal',
      colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)], // Purple
    ),
    const PetBackgroundTheme(
      id: 'berry',
      colors: [Color(0xFFEC407A), Color(0xFFF48FB1)], // Pink
    ),
    const PetBackgroundTheme(
      id: 'midnight',
      colors: [Color(0xFF263238), Color(0xFF455A64)], // Dark Grey
    ),
  ];
});

final selectedPetThemeProvider = StateProvider<PetBackgroundTheme>((ref) {
  final themes = ref.watch(petThemesProvider);
  return themes.first;
});

// Internal pet definitions with i18n keys
const _petDefinitions = [
  Pet(
    name: 'pet_Perrito',
    lottieAsset: 'assets/lottie/pets/box_dog.json',
    emoji: '🐶',
    isUnlocked: true,
  ),
  Pet(
    name: 'pet_Gatito',
    lottieAsset: 'assets/lottie/pets/cat_play_ball.json',
    emoji: '🐱',
    isUnlocked: true,
  ),
  Pet(
    name: 'pet_Tigre',
    lottieAsset: 'assets/lottie/pets/tiger_cute.json',
    emoji: '🐯',
    isUnlocked: false,
  ),
  Pet(
    name: 'pet_PezLeon',
    lottieAsset: 'assets/lottie/pets/lion_fish.json',
    emoji: '🐠',
    isUnlocked: false,
  ),
  Pet(
    name: 'pet_Leoncito',
    lottieAsset: 'assets/lottie/pets/lion_cute.json',
    emoji: '🦁',
    isUnlocked: false,
  ),
  Pet(
    name: 'pet_Panda',
    lottieAsset: 'assets/lottie/pets/panda_cute.json',
    emoji: '🐼',
    isUnlocked: false,
  ),
  Pet(
    name: 'pet_Unicornio',
    lottieAsset: 'assets/lottie/pets/unicorn_cute.json',
    emoji: '🦄',
    isUnlocked: false,
  ),
];

final availablePetsProvider = Provider<List<Pet>>((ref) {
  return _petDefinitions;
});

final selectedPetProvider = StateProvider<Pet>((ref) {
  final pets = ref.watch(availablePetsProvider);
  return pets.firstWhere((p) => p.isUnlocked, orElse: () => pets.first);
});

final previewPetProvider = StateProvider<Pet>((ref) {
  return ref.watch(selectedPetProvider);
});

/// Provider that returns pets with localized names
/// This converts the i18n keys to actual translated strings for display
final localizedPetsProvider = Provider<List<Pet>>((ref) {
  // This provider needs BuildContext, so we'll use a different approach
  // For now, return with i18n keys - will be translated at display time
  return ref.watch(availablePetsProvider);
});

/// Extension to easily translate a pet's name
extension PetLocalization on Pet {
  /// Get the localized name for this pet
  String getLocalizedName(AppLocalizations l10n) {
    return getLocalizedPetName(l10n, name);
  }
}

/// Helper function to get localized pet name from i18n key
String getLocalizedPetName(AppLocalizations l10n, String petNameKey) {
  switch (petNameKey) {
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
      return petNameKey;
  }
}
