import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet_model.dart';

final availablePetsProvider = Provider<List<Pet>>((ref) {
  return [
    const Pet(
      name: 'Perrito',
      lottieAsset: 'assets/lottie/pets/box_dog.json',
      emoji: '🐶',
      isUnlocked: true,
    ),
    const Pet(
      name: 'Tigre',
      lottieAsset: 'assets/lottie/pets/tiger_cute.json',
      emoji: '🐯',
      isUnlocked: true,
    ),
    const Pet(
      name: 'Gatito',
      lottieAsset: 'assets/lottie/pets/cat_play_ball.json',
      emoji: '🐱',
      isUnlocked: true,
    ),
    const Pet(
      name: 'Pez León',
      lottieAsset: 'assets/lottie/pets/lion_fish.json',
      emoji: '🐠',
      isUnlocked: true,
    ),
    // Locked pets for FOMO
    const Pet(
      name: 'Leoncito',
      lottieAsset: 'assets/lottie/pets/lion_cute.json', // Placeholder asset
      emoji: '🦁',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Panda',
      lottieAsset: 'assets/lottie/pets/panda_cute.json', // Placeholder asset
      emoji: '🐼',
      isUnlocked: false,
    ),
    const Pet(
      name: 'Unicornio',
      lottieAsset: 'assets/lottie/pets/unicorn_cute.json', // Placeholder asset
      emoji: '🦄',
      isUnlocked: false,
    ),
  ];
});

final selectedPetProvider = StateProvider<Pet>((ref) {
  final pets = ref.watch(availablePetsProvider);
  return pets.first;
});
