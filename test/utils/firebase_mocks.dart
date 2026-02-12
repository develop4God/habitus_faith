import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';

// Firebase Auth Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

// Firestore Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// class MockCollectionReference extends Mock
//     implements CollectionReference<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockTransaction extends Mock implements Transaction {}

// Firebase Messaging Mocks
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockRemoteMessage extends Mock implements RemoteMessage {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

// Local Notifications Mocks
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

/// Helper to setup mock Firebase user
MockUser mockFirebaseUser({
  String uid = 'test-user-123',
  String? email,
  String? displayName,
  bool isAnonymous = false,
}) {
  final user = MockUser();
  when(() => user.uid).thenReturn(uid);
  when(() => user.email).thenReturn(email);
  when(() => user.displayName).thenReturn(displayName);
  when(() => user.isAnonymous).thenReturn(isAnonymous);
  return user;
}
