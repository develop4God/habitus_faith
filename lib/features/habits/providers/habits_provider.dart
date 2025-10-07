import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/firestore_provider.dart';

// Provider for habits stream filtered by userId
final habitsProvider = StreamProvider<List<HabitModel>>((ref) {
  final userId = ref.watch(userIdProvider);
  final firestore = ref.watch(firestoreProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('habits')
      .where('userId', isEqualTo: userId)
      .where('isArchived', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
  });
});

// Provider for habit actions
final habitsActionsProvider = Provider<HabitsActions>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(userIdProvider);
  return HabitsActions(firestore: firestore, userId: userId);
});

class HabitsActions {
  final FirebaseFirestore firestore;
  final String? userId;

  HabitsActions({required this.firestore, required this.userId});

  Future<void> addHabit({
    required String name,
    required String description,
    HabitCategory category = HabitCategory.other,
  }) async {
    if (userId == null) return;

    const uuid = Uuid();
    final habit = HabitModel.create(
      id: uuid.v4(),
      userId: userId!,
      name: name,
      description: description,
      category: category,
    );

    await firestore
        .collection('habits')
        .doc(habit.id)
        .set(habit.toFirestore());
  }

  Future<void> completeHabit(HabitModel habit) async {
    final updatedHabit = habit.completeToday();
    
    await firestore
        .collection('habits')
        .doc(habit.id)
        .update(updatedHabit.toFirestore());
  }

  Future<void> deleteHabit(String habitId) async {
    await firestore.collection('habits').doc(habitId).delete();
  }
}
