import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../firebase_options.dart';

/// Provider that lazily initializes Firebase when first accessed
/// This allows the app to start without waiting for Firebase
final firebaseInitProvider = FutureProvider<FirebaseApp>((ref) async {
  final startTime = DateTime.now();

  try {
    if (Firebase.apps.isEmpty) {
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('🔥 [Firebase] Initialized in ${duration}ms');
      return app;
    } else {
      debugPrint(
          '🔥 [Firebase] Already initialized (${Firebase.apps.length} apps)');
      return Firebase.app();
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('🔥 [Firebase] Already initialized by native code');
      return Firebase.app();
    }
    debugPrint('❌ [Firebase] Initialization error: $e');
    rethrow;
  }
});

/// Provider for Firestore instance that waits for Firebase initialization
final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  final firebaseAsync = ref.watch(firebaseInitProvider);

  return firebaseAsync.when(
    data: (_) => FirebaseFirestore.instance,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider that indicates if Firebase is ready
final firebaseReadyProvider = Provider<bool>((ref) {
  final firebaseAsync = ref.watch(firebaseInitProvider);
  return firebaseAsync.hasValue;
});
