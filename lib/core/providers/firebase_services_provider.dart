import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_init_provider.dart';

/// Provider for FirebaseAuth instance
/// Ensures Firebase is initialized before providing the instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  ref.watch(firebaseInitProvider);
  return FirebaseAuth.instance;
});

/// Provider for FirebaseFirestore instance
/// Ensures Firebase is initialized before providing the instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  ref.watch(firebaseInitProvider);
  return FirebaseFirestore.instance;
});

/// Provider for FirebaseMessaging instance
/// Ensures Firebase is initialized before providing the instance
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  ref.watch(firebaseInitProvider);
  return FirebaseMessaging.instance;
});
