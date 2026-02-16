import 'dart:async';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/providers/auth_provider.dart';
import 'package:habitus_faith/core/providers/firebase_init_provider.dart';
import 'package:habitus_faith/core/providers/firebase_services_provider.dart';
import 'package:mocktail/mocktail.dart';
import '../utils/firebase_mocks.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  group('AuthProvider Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockUserCredential mockCredential;
    late MockFirebaseApp mockApp;
    late ProviderContainer container;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = mockFirebaseUser(uid: 'test-uid-123', isAnonymous: true);
      mockCredential = MockUserCredential();
      mockApp = MockFirebaseApp();

      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInAnonymously())
          .thenAnswer((_) async => mockCredential);
    });

    tearDown(() {
      container.dispose();
    });

    group('authInitProvider', () {
      test('signs in anonymously when no current user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseInitProvider.overrideWith((ref) async => mockApp),
          ],
        );

        final result = await container.read(authInitProvider.future);

        expect(result, equals(mockUser));
        verify(() => mockAuth.signInAnonymously()).called(1);
      });

      test('returns existing user when already signed in', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseInitProvider.overrideWith((ref) async => mockApp),
          ],
        );

        final result = await container.read(authInitProvider.future);

        expect(result, equals(mockUser));
        verifyNever(() => mockAuth.signInAnonymously());
      });

      test('waits for Firebase initialization', () async {
        bool initCalled = false;
        when(() => mockAuth.currentUser).thenReturn(null);

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseInitProvider.overrideWith((ref) async {
              // ignore: prefer_const_constructors
              await Future.delayed(Duration(milliseconds: 10));
              initCalled = true;
              return mockApp;
            }),
          ],
        );

        final result = await container.read(authInitProvider.future);

        expect(initCalled, isTrue);
        expect(result, equals(mockUser));
      });
    });

    group('currentUserProvider', () {
      test('emits user when signed in', () async {
        when(() => mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseReadyProvider.overrideWith((ref) => true),
          ],
        );

        final result = await container.read(currentUserProvider.future);
        expect(result, equals(mockUser));
      });

      test('emits null when signed out', () async {
        when(() => mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseReadyProvider.overrideWith((ref) => true),
          ],
        );

        final result = await container.read(currentUserProvider.future);
        expect(result, isNull);
      });

      test('emits null when Firebase not ready', () async {
        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseReadyProvider.overrideWith((ref) => false),
          ],
        );

        final result = await container.read(currentUserProvider.future);
        expect(result, isNull);
      });
    });

    group('userIdProvider', () {
      test('extracts user ID', () async {
        when(() => mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );
        when(() => mockUser.uid).thenReturn('extracted-uid');

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseReadyProvider.overrideWith((ref) => true),
          ],
        );

        await container.read(currentUserProvider.future);
        final userId = container.read(userIdProvider);
        expect(userId, equals('extracted-uid'));
      });

      test('returns null when no user', () async {
        when(() => mockAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );

        container = ProviderContainer(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firebaseReadyProvider.overrideWith((ref) => true),
          ],
        );

        await container.read(currentUserProvider.future);
        final userId = container.read(userIdProvider);
        expect(userId, isNull);
      });
    });
  });
}
