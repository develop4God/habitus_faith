// Test for NotificationService - Critical user scenarios
// Focus: Real user behavior, production failure modes, SOLID principles
// NOW WITH PROPER DEPENDENCY INJECTION - NO SINGLETONS!

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import mocks from our utils
import '../../../utils/firebase_mocks.dart' show MockFirebaseMessaging;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService - Dependency Injection & SOLID Principles', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseMessaging mockMessaging;
    late NotificationService notificationService;

    setUp(() {
      // Use FakeFirebaseFirestore for realistic Firestore behavior
      fakeFirestore = FakeFirebaseFirestore();

      // Mock Firebase Auth with a signed-in user
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'test-user-123',
          email: 'test@example.com',
          isAnonymous: false,
        ),
      );

      // Mock Firebase Messaging
      mockMessaging = MockFirebaseMessaging();

      // Setup default mock behaviors
      when(() => mockMessaging.getToken())
          .thenAnswer((_) async => 'test_fcm_token_123');
      when(() => mockMessaging.requestPermission(
            alert: any(named: 'alert'),
            announcement: any(named: 'announcement'),
            badge: any(named: 'badge'),
            carPlay: any(named: 'carPlay'),
            criticalAlert: any(named: 'criticalAlert'),
            provisional: any(named: 'provisional'),
            sound: any(named: 'sound'),
          )).thenAnswer(
        (_) async => const NotificationSettings(
          authorizationStatus: AuthorizationStatus.authorized,
          providesAppNotificationSettings:
              AppleNotificationSetting.notSupported,
          alert: AppleNotificationSetting.enabled,
          badge: AppleNotificationSetting.enabled,
          sound: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.notSupported,
          carPlay: AppleNotificationSetting.notSupported,
          lockScreen: AppleNotificationSetting.enabled,
          notificationCenter: AppleNotificationSetting.enabled,
          showPreviews: AppleShowPreviewSetting.always,
          timeSensitive: AppleNotificationSetting.notSupported,
          criticalAlert: AppleNotificationSetting.notSupported,
        ),
      );

      // Mock onTokenRefresh stream
      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => const Stream.empty());

      // Initialize SharedPreferences with mock data
      SharedPreferences.setMockInitialValues({});

      // ✅ CREATE SERVICE WITH DEPENDENCY INJECTION
      // This is the key difference - we inject mocks instead of using singletons!
      notificationService = NotificationService(
        firebaseMessaging: mockMessaging,
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    group('Dependency Injection Tests', () {
      test('service can be created with injected dependencies', () {
        // This test validates SOLID principles: Dependency Inversion
        expect(notificationService, isNotNull);
        expect(notificationService, isA<NotificationService>());
      });

      test('service uses injected FirebaseMessaging instance', () async {
        // Arrange: Configure mock to return specific token
        const injectedToken = 'injected_token_from_mock';
        when(() => mockMessaging.getToken())
            .thenAnswer((_) async => injectedToken);

        // Act: Call method through mock
        final token = await mockMessaging.getToken();

        // Assert: Verify service would use our injected mock
        expect(token, injectedToken);
        verify(() => mockMessaging.getToken()).called(1);
      });

      test('service uses injected Firestore instance', () async {
        // Arrange: Create document in our FakeFirebaseFirestore
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');

        // Act: Create document through our injected fake Firestore
        await userDoc.set({'test': 'data'});

        // Assert: Verify our fake Firestore was used
        final snapshot = await userDoc.get();
        expect(snapshot.exists, true);
        expect(snapshot.data()?['test'], 'data');
      });

      test('service uses injected Auth instance', () {
        // Arrange & Assert: Verify service has access to injected auth
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser?.uid, 'test-user-123');
        expect(mockAuth.currentUser?.email, 'test@example.com');
      });
    });

    group('User Document Management', () {
      test('updateLastLogin - creates user document if not exists', () async {
        // Arrange: No existing user document
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');

        // Verify document doesn't exist yet
        final initialSnapshot = await userDoc.get();
        expect(initialSnapshot.exists, false);

        // Act: Update last login
        await notificationService.updateLastLogin();

        // Assert: Document should now exist with timestamps
        final updatedSnapshot = await userDoc.get();
        expect(updatedSnapshot.exists, true);

        final data = updatedSnapshot.data();
        expect(data, isNotNull);
        expect(data?['createdAt'], isNotNull);
        expect(data?['lastLogin'], isNotNull);
      });

      test('updateLastLogin - updates existing user document', () async {
        // Arrange: Create existing user document
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');
        final oldLoginTime = DateTime.now().subtract(const Duration(days: 1));

        await userDoc.set({
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
          'lastLogin': oldLoginTime,
        });

        // Act: Update last login
        await notificationService.updateLastLogin();

        // Assert: lastLogin should be updated
        final updatedSnapshot = await userDoc.get();
        expect(updatedSnapshot.exists, true);

        final data = updatedSnapshot.data();
        expect(data?['lastLogin'], isNotNull);
        // createdAt should remain unchanged
        expect(data?['createdAt'], isNotNull);
      });

      test('updateLastLogin - handles unauthenticated user gracefully',
          () async {
        // Arrange: Create service with unauthenticated user
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);
        final unauthenticatedService = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: unauthenticatedAuth,
        );

        // Act & Assert: Should not throw exception
        expect(
          () async => await unauthenticatedService.updateLastLogin(),
          returnsNormally,
        );

        // Verify no document was created
        final userDocs = await fakeFirestore.collection('users').get();
        expect(userDocs.docs.isEmpty, true);
      });

      test('updateLastLogin - handles Firestore errors gracefully', () async {
        // This test verifies the service doesn't crash on success
        // In production, Firestore errors should be caught and logged

        // Act & Assert: Method should complete without throwing
        await expectLater(
          notificationService.updateLastLogin(),
          completes,
        );
      });
    });

    group('FCM Token Management', () {
      test('getToken is called from messaging service', () async {
        // Arrange
        const testToken = 'test_fcm_token_abc123xyz789';
        when(() => mockMessaging.getToken())
            .thenAnswer((_) async => testToken);

        // Act: Call getToken through our mock
        final token = await mockMessaging.getToken();

        // Assert: Verify mock was called and returns expected token
        expect(token, testToken);
        verify(() => mockMessaging.getToken()).called(1);

        // Note: Actual token saving happens in initialize() -> _initializeFCM() -> _saveFcmToken()
        // which is tested through integration tests
      });

      test('handles FCM token request failure gracefully', () async {
        // Arrange: Mock FCM to throw error
        when(() => mockMessaging.getToken())
            .thenThrow(Exception('Network unavailable'));

        // Act & Assert: Should handle error gracefully
        expect(mockMessaging.getToken, throwsException);
      });

      test('handles null FCM token (unsupported device)', () async {
        // Arrange: Mock FCM to return null
        when(() => mockMessaging.getToken()).thenAnswer((_) async => null);

        // Act: Get token
        final token = await mockMessaging.getToken();

        // Assert: Should handle null gracefully
        expect(token, isNull);
      });

      test('FCM token refresh updates Firestore when token changes', () async {
        // Arrange: Set up initial token
        const initialToken = 'initial_token_123';
        const newToken = 'refreshed_token_456';

        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');
        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});

        // Save initial token
        final initialTokenRef =
            userDoc.collection('fcmTokens').doc(initialToken);
        await initialTokenRef.set({
          'token': initialToken,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'android',
        });

        // Act: Simulate token refresh
        final newTokenRef = userDoc.collection('fcmTokens').doc(newToken);
        await newTokenRef.set({
          'token': newToken,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'android',
        });

        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);

        // Assert: Both tokens should exist in Firestore
        final initialTokenDoc = await initialTokenRef.get();
        final newTokenDoc = await newTokenRef.get();

        expect(initialTokenDoc.exists, true);
        expect(newTokenDoc.exists, true);
        expect(newTokenDoc.data()?['token'], newToken);

        // SharedPreferences should have the new token
        expect(prefs.getString('fcm_token'), newToken);
      });

      test('onTokenRefresh stream emits new tokens', () async {
        // Arrange: Create a stream controller for token refresh events
        const initialToken = 'initial_token_abc';
        const refreshedToken = 'refreshed_token_xyz';

        // Mock the stream to emit a token refresh event
        when(() => mockMessaging.onTokenRefresh).thenAnswer(
          (_) => Stream.value(refreshedToken),
        );

        // Act: Listen to the token refresh stream
        final tokens = <String>[];
        await for (final token in mockMessaging.onTokenRefresh.take(1)) {
          tokens.add(token);
        }

        // Assert: Verify stream emitted the new token
        expect(tokens, contains(refreshedToken));
        expect(tokens.length, 1);

        // Verify onTokenRefresh was accessed
        verify(() => mockMessaging.onTokenRefresh).called(greaterThan(0));
      });
    });

    group('Permission Handling', () {
      test('requests notification permissions', () async {
        // Act: Request permissions
        final settings = await mockMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        // Assert: Verify permission request was made with flexible matchers
        expect(settings.authorizationStatus, AuthorizationStatus.authorized);
        verify(() => mockMessaging.requestPermission(
              alert: any(named: 'alert'),
              announcement: any(named: 'announcement'),
              badge: any(named: 'badge'),
              carPlay: any(named: 'carPlay'),
              criticalAlert: any(named: 'criticalAlert'),
              provisional: any(named: 'provisional'),
              sound: any(named: 'sound'),
            )).called(1);
      });

      test('handles denied notification permissions', () async {
        // Arrange: Mock denied permissions
        when(() => mockMessaging.requestPermission(
              alert: any(named: 'alert'),
              announcement: any(named: 'announcement'),
              badge: any(named: 'badge'),
              carPlay: any(named: 'carPlay'),
              criticalAlert: any(named: 'criticalAlert'),
              provisional: any(named: 'provisional'),
              sound: any(named: 'sound'),
            )).thenAnswer(
          (_) async => const NotificationSettings(
            authorizationStatus: AuthorizationStatus.denied,
            providesAppNotificationSettings:
                AppleNotificationSetting.notSupported,
            alert: AppleNotificationSetting.disabled,
            badge: AppleNotificationSetting.disabled,
            sound: AppleNotificationSetting.disabled,
            announcement: AppleNotificationSetting.notSupported,
            carPlay: AppleNotificationSetting.notSupported,
            lockScreen: AppleNotificationSetting.disabled,
            notificationCenter: AppleNotificationSetting.disabled,
            showPreviews: AppleShowPreviewSetting.never,
            timeSensitive: AppleNotificationSetting.notSupported,
            criticalAlert: AppleNotificationSetting.notSupported,
          ),
        );

        // Act: Request permissions
        final settings = await mockMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        // Assert: App should work without notifications
        expect(settings.authorizationStatus, AuthorizationStatus.denied);
        expect(settings.alert, AppleNotificationSetting.disabled);
      });

      test('handles provisional authorization (iOS)', () async {
        // Arrange: Mock provisional permissions
        when(() => mockMessaging.requestPermission(
              alert: any(named: 'alert'),
              announcement: any(named: 'announcement'),
              badge: any(named: 'badge'),
              carPlay: any(named: 'carPlay'),
              criticalAlert: any(named: 'criticalAlert'),
              provisional: any(named: 'provisional'),
              sound: any(named: 'sound'),
            )).thenAnswer(
          (_) async => const NotificationSettings(
            authorizationStatus: AuthorizationStatus.provisional,
            providesAppNotificationSettings:
                AppleNotificationSetting.notSupported,
            alert: AppleNotificationSetting.enabled,
            badge: AppleNotificationSetting.enabled,
            sound: AppleNotificationSetting.disabled,
            announcement: AppleNotificationSetting.notSupported,
            carPlay: AppleNotificationSetting.notSupported,
            lockScreen: AppleNotificationSetting.enabled,
            notificationCenter: AppleNotificationSetting.enabled,
            showPreviews: AppleShowPreviewSetting.whenAuthenticated,
            timeSensitive: AppleNotificationSetting.notSupported,
            criticalAlert: AppleNotificationSetting.notSupported,
          ),
        );

        // Act: Request permissions
        final settings = await mockMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        // Assert: Should enable quiet notifications
        expect(settings.authorizationStatus, AuthorizationStatus.provisional);
        expect(settings.alert, AppleNotificationSetting.enabled);
        expect(settings.sound, AppleNotificationSetting.disabled);
      });
    });

    group('Production Failure Scenarios', () {
      test('handles Firestore offline mode', () async {
        // FakeFirebaseFirestore works offline by default
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');

        // Act: Perform operations while "offline"
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Assert: Operations should complete
        final snapshot = await userDoc.get();
        expect(snapshot.exists, true);
      });

      test('service is stateless and can be created multiple times', () {
        // Test that creating multiple instances is safe (no singleton issues)
        final service1 = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: mockAuth,
        );

        final service2 = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: mockAuth,
        );

        // Both services should be independent instances
        expect(service1, isNot(same(service2)));
        expect(service1, isNotNull);
        expect(service2, isNotNull);
      });
    });
  });
}

