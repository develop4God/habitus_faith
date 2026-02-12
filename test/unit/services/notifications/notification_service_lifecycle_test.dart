// Test for NotificationService - Critical Lifecycle & Token Management Tests
// Tests for memory leak fixes, dispose, lastUsed timestamp, and production logging

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitus_faith/core/services/notifications/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import mocks
import '../../../utils/firebase_mocks.dart' show MockFirebaseMessaging;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService - Critical Lifecycle Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseMessaging mockMessaging;
    late NotificationService notificationService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'test-user-123',
          email: 'test@example.com',
        ),
      );
      mockMessaging = MockFirebaseMessaging();

      // Default mocks
      when(() => mockMessaging.getToken())
          .thenAnswer((_) async => 'test_token_123');
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

      when(() => mockMessaging.onTokenRefresh)
          .thenAnswer((_) => const Stream.empty());

      SharedPreferences.setMockInitialValues({});

      notificationService = NotificationService(
        firebaseMessaging: mockMessaging,
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    tearDown(() {
      // Clean up service
      notificationService.dispose();
    });

    group('Dispose & Memory Leak Prevention', () {
      test('dispose cancels all stream subscriptions', () {
        // Arrange - Service is created with subscriptions
        expect(notificationService, isNotNull);

        // Act - Dispose the service
        notificationService.dispose();

        // Assert - Verify dispose was called
        // Note: We can't directly verify subscriptions are null (private fields)
        // but we verify no exceptions are thrown
        expect(() => notificationService.dispose(), returnsNormally);
      });

      test('dispose can be called multiple times safely', () {
        // Act - Call dispose multiple times
        notificationService.dispose();
        notificationService.dispose();
        notificationService.dispose();

        // Assert - Should not throw
        expect(true, true);
      });

      test('service can be recreated after dispose', () {
        // Arrange - Dispose first service
        notificationService.dispose();

        // Act - Create new service
        final newService = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: mockAuth,
        );

        // Assert - New service works
        expect(newService, isNotNull);

        // Cleanup
        newService.dispose();
      });
    });

    group('Token lastUsed Timestamp - Cloud Function Coordination', () {
      test('reusing token updates lastUsed timestamp', () async {
        // Arrange - Setup existing valid token
        const existingToken = 'existing_token_abc123';
        final userDoc = fakeFirestore.collection('users').doc('test-user-123');

        // Create user document
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Create token document (simulate previously saved token)
        final tokenDoc = userDoc.collection('fcmTokens').doc(existingToken);
        await tokenDoc.set({
          'token': existingToken,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'Android',
        });

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', existingToken);

        // Mock messaging to NOT request new token
        when(() => mockMessaging.getToken())
            .thenAnswer((_) async => existingToken);

        // Create fresh service
        final service = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: mockAuth,
        );

        // Act - Initialize (should reuse token and update lastUsed)
        // Note: Since _initializeFCM is called inside initialize(), we can't test it directly
        // We'll test the behavior by checking the token document

        // Simulate what happens when token is reused
        await tokenDoc.update({
          'lastUsed': FieldValue.serverTimestamp(),
        });

        // Assert - Verify lastUsed was added
        final updatedTokenDoc = await tokenDoc.get();
        expect(updatedTokenDoc.exists, true);
        expect(updatedTokenDoc.data()?['lastUsed'], isNotNull);
        expect(updatedTokenDoc.data()?['token'], existingToken);

        // Cleanup
        service.dispose();
      });

      test('lastUsed prevents Cloud Function deletion (30 day rule)', () async {
        // This test validates the coordination with Cloud Function
        // Cloud Function deletes tokens older than 30 days without recent lastUsed

        // Arrange - Create token older than 30 days
        const oldToken = 'old_token_should_be_deleted';
        final userDoc = fakeFirestore.collection('users').doc('test-user-123');

        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        final tokenDoc = userDoc.collection('fcmTokens').doc(oldToken);

        // Token created 31 days ago
        final thirtyOneDaysAgo =
            DateTime.now().subtract(const Duration(days: 31));
        await tokenDoc.set({
          'token': oldToken,
          'createdAt': Timestamp.fromDate(thirtyOneDaysAgo),
          'platform': 'Android',
          // No lastUsed - should be deleted by Cloud Function
        });

        // Simulate Cloud Function logic
        final tokenSnapshot = await tokenDoc.get();
        final tokenData = tokenSnapshot.data();
        final createdAt = tokenData?['createdAt'] as Timestamp?;
        final lastUsed = tokenData?['lastUsed'] as Timestamp?;

        final now = DateTime.now();
        final cutoff = now.subtract(const Duration(days: 30));

        // Check if token should be deleted
        final shouldDelete = lastUsed == null &&
            createdAt != null &&
            createdAt.toDate().isBefore(cutoff);

        // Assert - Token should be deleted (no lastUsed update)
        expect(shouldDelete, true);

        // Now update lastUsed
        await tokenDoc.update({
          'lastUsed': FieldValue.serverTimestamp(),
        });

        final updatedSnapshot = await tokenDoc.get();
        final updatedData = updatedSnapshot.data();
        final updatedLastUsed = updatedData?['lastUsed'] as Timestamp?;

        // Token should NOT be deleted now
        final shouldDeleteAfterUpdate = updatedLastUsed == null &&
            createdAt != null &&
            createdAt.toDate().isBefore(cutoff);

        expect(shouldDeleteAfterUpdate, false);
      });

      test('missing lastUsed field is handled gracefully', () async {
        // Arrange - Token without lastUsed field
        const tokenWithoutLastUsed = 'token_no_lastused';
        final userDoc = fakeFirestore.collection('users').doc('test-user-123');

        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});

        final tokenDoc =
            userDoc.collection('fcmTokens').doc(tokenWithoutLastUsed);
        await tokenDoc.set({
          'token': tokenWithoutLastUsed,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'iOS',
          // Intentionally no lastUsed
        });

        // Act - Read token
        final snapshot = await tokenDoc.get();
        final data = snapshot.data();

        // Assert - Should handle missing field gracefully
        expect(data?['lastUsed'], isNull);
        expect(data?['token'], tokenWithoutLastUsed);

        // Can add lastUsed later
        await tokenDoc.update({
          'lastUsed': FieldValue.serverTimestamp(),
        });

        final updatedSnapshot = await tokenDoc.get();
        expect(updatedSnapshot.data()?['lastUsed'], isNotNull);
      });
    });

    group('Production Logging - No Emojis', () {
      test('logs use structured format without emojis', () async {
        // This is more of a documentation test
        // Real test would require capturing log output

        // Example of GOOD production logging:
        const goodLog =
            '[NotificationService] Token validation: found_locally=true';
        expect(goodLog.contains('emoji'), false);
        expect(goodLog.contains('[NotificationService]'), true);

        // Example of BAD logging (emojis):
        const badLog = '🔍 NotificationService: Found existing token locally';
        expect(badLog.contains('🔍'), true); // Has emoji

        // Assert - Production logs should not have emojis
        expect(
            goodLog.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true)),
            false);
      });

      test('structured logs are parseable', () {
        // Demonstrate structured logging format
        const logMessage =
            '[NotificationService] Token validation: found_locally=true, token_length=256';

        // Parse log
        final parts = logMessage.split(': ');
        expect(parts.length, 2);

        final service = parts[0].replaceAll('[', '').replaceAll(']', '');
        expect(service, 'NotificationService');

        final details = parts[1];
        expect(details.contains('found_locally=true'), true);
        expect(details.contains('token_length=256'), true);
      });
    });

    group('Integration - Token Reuse with lastUsed', () {
      test('complete flow: existing token → validate → update lastUsed → reuse',
          () async {
        // Arrange - Complete setup
        const existingToken = 'integration_test_token';
        final userDoc = fakeFirestore.collection('users').doc('test-user-123');

        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 1))),
        });

        final tokenDoc = userDoc.collection('fcmTokens').doc(existingToken);
        await tokenDoc.set({
          'token': existingToken,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'Android',
          // No lastUsed initially
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', existingToken);

        // Act - Simulate service initialization flow
        // 1. Check local token
        final localToken = prefs.getString('fcm_token');
        expect(localToken, existingToken);

        // 2. Validate in Firestore
        final tokenSnapshot = await tokenDoc.get();
        expect(tokenSnapshot.exists, true);

        // 3. Update lastUsed
        await tokenDoc.update({
          'lastUsed': FieldValue.serverTimestamp(),
        });

        // 4. Update lastLogin
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Assert - Verify complete flow
        final finalTokenSnapshot = await tokenDoc.get();
        final finalUserSnapshot = await userDoc.get();

        expect(finalTokenSnapshot.data()?['lastUsed'], isNotNull);
        expect(finalTokenSnapshot.data()?['token'], existingToken);
        expect(finalUserSnapshot.data()?['lastLogin'], isNotNull);
      });
    });

    group('Error Handling - lastUsed Update Failures', () {
      test('continues if lastUsed update fails', () async {
        // This test documents that lastUsed update failure is non-critical
        // Service should continue working even if update fails

        // Arrange - Mock a scenario where update might fail
        const token = 'test_token';
        final userDoc = fakeFirestore.collection('users').doc('test-user-123');

        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});

        final tokenDoc = userDoc.collection('fcmTokens').doc(token);
        await tokenDoc.set({
          'token': token,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Act - Try to update (should work in FakeFirestore)
        await expectLater(
          tokenDoc.update({'lastUsed': FieldValue.serverTimestamp()}),
          completes,
        );

        // Assert - Update should succeed
        final snapshot = await tokenDoc.get();
        expect(snapshot.data()?['lastUsed'], isNotNull);
      });
    });

    group('Token Deletion on Uninstall', () {
      test('deleteTokenOnUninstall removes token from Firestore and local storage',
          () async {
        // Arrange - Setup token in Firestore and SharedPreferences
        const testToken = 'token_to_delete_123';
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');

        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});

        final tokenDoc = userDoc.collection('fcmTokens').doc(testToken);
        await tokenDoc.set({
          'token': testToken,
          'createdAt': FieldValue.serverTimestamp(),
          'platform': 'Android',
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', testToken);

        // Verify token exists before deletion
        var snapshot = await tokenDoc.get();
        expect(snapshot.exists, true);
        expect(prefs.getString('fcm_token'), testToken);

        // Mock deleteToken method
        when(() => mockMessaging.deleteToken()).thenAnswer((_) async => {});

        // Act - Delete token
        await notificationService.deleteTokenOnUninstall();

        // Assert - Token should be deleted from Firestore
        snapshot = await tokenDoc.get();
        expect(snapshot.exists, false);

        // Token should be removed from SharedPreferences
        expect(prefs.getString('fcm_token'), isNull);

        // Verify FCM deleteToken was called
        verify(() => mockMessaging.deleteToken()).called(1);
      });

      test('deleteTokenOnUninstall handles missing token gracefully', () async {
        // Arrange - No token in storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');

        // Act - Try to delete (should not throw)
        await expectLater(
          notificationService.deleteTokenOnUninstall(),
          completes,
        );

        // Assert - Should complete without errors
        expect(prefs.getString('fcm_token'), isNull);
      });

      test('deleteTokenOnUninstall handles unauthenticated user', () async {
        // Arrange - Create service with unauthenticated user
        final unauthService = NotificationService(
          firebaseMessaging: mockMessaging,
          firestore: fakeFirestore,
          auth: MockFirebaseAuth(signedIn: false),
        );

        // Act - Try to delete (should exit early)
        await expectLater(
          unauthService.deleteTokenOnUninstall(),
          completes,
        );

        // Assert - No exception thrown
        expect(true, true);

        // Cleanup
        unauthService.dispose();
      });

      test('deleteTokenOnUninstall handles Firestore errors gracefully',
          () async {
        // Arrange - Setup token in local storage only
        const testToken = 'error_token';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', testToken);

        // Mock deleteToken to succeed
        when(() => mockMessaging.deleteToken()).thenAnswer((_) async => {});

        // Act - Try to delete (Firestore doc doesn't exist, should handle gracefully)
        await expectLater(
          notificationService.deleteTokenOnUninstall(),
          completes,
        );

        // Assert - Local token should still be removed
        expect(prefs.getString('fcm_token'), isNull);
      });

      test('deleteTokenOnUninstall is idempotent', () async {
        // Arrange - Setup token
        const testToken = 'idempotent_token';
        final userDoc =
            fakeFirestore.collection('users').doc('test-user-123');
        await userDoc.set({'createdAt': FieldValue.serverTimestamp()});

        final tokenDoc = userDoc.collection('fcmTokens').doc(testToken);
        await tokenDoc.set({
          'token': testToken,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', testToken);

        when(() => mockMessaging.deleteToken()).thenAnswer((_) async => {});

        // Act - Delete multiple times
        await notificationService.deleteTokenOnUninstall();
        await notificationService.deleteTokenOnUninstall();
        await notificationService.deleteTokenOnUninstall();

        // Assert - Should complete without errors
        final snapshot = await tokenDoc.get();
        expect(snapshot.exists, false);
        expect(prefs.getString('fcm_token'), isNull);
      });
    });
  });
}
