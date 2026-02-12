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
      lottieAsset: 'assets/lottie/animation.json',
      emoji: '🐱',
      isUnlocked: true,
    ),
  ];
});

final selectedPetProvider = StateProvider<Pet>((ref) {
  final pets = ref.watch(availablePetsProvider);
  return pets.first;
});
