import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider that initializes anonymous auth if needed
final authInitProvider = FutureProvider<User?>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);

  // Check if user is already signed in
  if (auth.currentUser != null) {
    return auth.currentUser;
  }

  // Sign in anonymously
  final userCredential = await auth.signInAnonymously();
  return userCredential.user;
});

// Provider for current user stream
final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Provider for current user ID
final userIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenData((user) => user?.uid).value;
});
