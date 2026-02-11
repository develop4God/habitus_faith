import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_init_provider.dart';

// Provider for FirebaseAuth instance (waits for Firebase to be ready)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  // Watch Firebase initialization to ensure it's ready
  ref.watch(firebaseInitProvider);
  return FirebaseAuth.instance;
});

// Provider that initializes anonymous auth if needed
// This will automatically wait for Firebase to initialize
final authInitProvider = FutureProvider<User?>((ref) async {
  // Ensure Firebase is initialized first
  await ref.watch(firebaseInitProvider.future);

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
  // Ensure Firebase is initialized
  final firebaseReady = ref.watch(firebaseReadyProvider);

  if (!firebaseReady) {
    // Return empty stream while Firebase initializes
    return Stream.value(null);
  }

  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Provider for current user ID
final userIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.whenData((user) => user?.uid).value;
});
