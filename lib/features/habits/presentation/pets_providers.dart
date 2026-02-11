import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/pet_repository.dart';
import '../domain/models/pet_model.dart';
import '../../../../core/providers/auth_provider.dart';

final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;

  if (user == null) {
    return [];
  }

  final repository = ref.read(petRepositoryProvider);
  return repository.getPets(user.uid);
});

final petsNotifierProvider =
    StateNotifierProvider<PetsNotifier, AsyncValue<List<Pet>>>((ref) {
  return PetsNotifier(ref);
});

class PetsNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  final Ref ref;

  PetsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadPets();
  }

  Future<void> _loadPets() async {
    state = const AsyncValue.loading();
    try {
      final userAsync = ref.read(currentUserProvider);
      final user = userAsync.value;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final repository = ref.read(petRepositoryProvider);
      final pets = await repository.getPets(user.uid);
      state = AsyncValue.data(pets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPet(String name, String emoji) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    final pet = Pet(
      id: const Uuid().v4(),
      userId: user.uid,
      name: name,
      emoji: emoji,
      createdAt: DateTime.now(),
    );

    final repository = ref.read(petRepositoryProvider);
    await repository.savePet(pet);
    await _loadPets();
  }

  Future<void> deletePet(String petId) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    if (user == null) return;

    final repository = ref.read(petRepositoryProvider);
    await repository.deletePet(user.uid, petId);
    await _loadPets();
  }
}
