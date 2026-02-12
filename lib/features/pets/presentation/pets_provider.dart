import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet_model.dart';

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

final availablePetsProvider = Provider<List<Pet>>((ref) {
  return [
    const Pet(
      name: 'Perrito',
      lottieAsset: 'assets/lottie/pets/box_dog.json',
      emoji: '🐶',
      isUnlocked: true,
    ),
    const Pet(
      name: 'Gatito',
      lottieAsset: 'assets/lottie/pets/cat_play_ball.json',
      emoji: '🐱',
      isUnlocked: true,
    ),
    const Pet(
      name: 'Tigre',
      lottieAsset: 'assets/lottie/pets/tiger_cute.json',
      emoji: '🐯',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Pez León',
      lottieAsset: 'assets/lottie/pets/lion_fish.json',
      emoji: '🐠',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Leoncito',
      lottieAsset: 'assets/lottie/pets/lion_cute.json',
      emoji: '🦁',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Panda',
      lottieAsset: 'assets/lottie/pets/panda_cute.json',
      emoji: '🐼',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Unicornio',
      lottieAsset: 'assets/lottie/pets/unicorn_cute.json',
      emoji: '🦄',
      isUnlocked: false,
    ),
  ];
});

final selectedPetProvider = StateProvider<Pet>((ref) {
  final pets = ref.watch(availablePetsProvider);
  return pets.firstWhere((p) => p.isUnlocked, orElse: () => pets.first);
});
