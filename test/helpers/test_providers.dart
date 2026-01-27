import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_faith/core/providers/auth_provider.dart';
import 'package:habitus_faith/core/providers/firestore_provider.dart';
import 'package:habitus_faith/features/habits/data/firestore_habits_repository.dart';
import 'package:habitus_faith/features/habits/presentation/habits_providers.dart';

/// Create test container with injectable ID generator for deterministic tests
ProviderContainer createTestContainer({
  FakeFirebaseFirestore? firestore,
  MockFirebaseAuth? auth,
  String Function()? idGenerator,
}) {
  final testFirestore = firestore ?? FakeFirebaseFirestore();
  final testAuth = auth ??
      MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'test-user', email: 'test@example.com'),
      );

  return ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(testFirestore),
      firebaseAuthProvider.overrideWithValue(testAuth),
      // Override repository with custom ID generator for testing
      if (idGenerator != null)
        habitsRepositoryProvider.overrideWithValue(
          FirestoreHabitsRepository(
            firestore: testFirestore,
            userId: testAuth.currentUser?.uid,
            idGenerator: idGenerator,
          ),
        ),
    ],
  );
}
