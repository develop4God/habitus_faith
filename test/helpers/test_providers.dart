import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitus_fe/core/providers/auth_provider.dart';
import 'package:habitus_fe/core/providers/firestore_provider.dart';

ProviderContainer createTestContainer({
  FakeFirebaseFirestore? firestore,
  MockFirebaseAuth? auth,
}) {
  final testFirestore = firestore ?? FakeFirebaseFirestore();
  final testAuth = auth ?? MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(
      uid: 'test-user',
      email: 'test@example.com',
    ),
  );

  return ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(testFirestore),
      firebaseAuthProvider.overrideWithValue(testAuth),
    ],
  );
}
