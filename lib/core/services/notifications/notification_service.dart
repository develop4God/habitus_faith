// lib/core/services/notifications/notification_service.dart
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// Background handler for notifications
@pragma('vm:entry-point')
void flutterLocalNotificationsBackgroundHandler(
  NotificationResponse notificationResponse,
) async {
  developer.log(
    'flutterLocalNotificationsBackgroundHandler: ${notificationResponse.payload}',
    name: 'NotificationServiceBackground',
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _defaultNotificationTime = '09:00';
  static const String _fcmTokenKey = 'fcm_token';

  Function(String? payload)? onNotificationTapped;

  /// Update lastLogin field when user enters the app
  Future<void> updateLastLogin() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      await userDocRef.set(
        {'lastLogin': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      developer.log(
        'NotificationService: lastLogin updated for user ${user.uid}',
        name: 'NotificationService',
      );
    }
  }

  Future<void> initialize() async {
    try {
      // Initialize timezones
      tzdata.initializeTimeZones();
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      developer.log(
        'NotificationService: tz.local.name: ${tz.local.name}, tz.local.currentTimeZone: ${tz.local.currentTimeZone}',
        name: 'NotificationService',
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) =>
            _onNotificationTapped(details),
        onDidReceiveBackgroundNotificationResponse:
            flutterLocalNotificationsBackgroundHandler,
      );

      await _requestPermissions();
      developer.log(
        'NotificationService: Initialized',
        name: 'NotificationService',
      );

      // Listen to auth state changes before initializing FCM and saving settings
      _auth.authStateChanges().listen((user) async {
        if (user != null) {
          developer.log(
            'NotificationService: Authenticated user detected: ${user.uid}',
            name: 'NotificationService',
          );

          // Initialize FCM and manage token only if there's a user
          await _initializeFCM();

          // Handle initial message if app was opened from a notification
          final RemoteMessage? initialMessage =
              await _firebaseMessaging.getInitialMessage();
          if (initialMessage != null) {
            developer.log(
              'NotificationService: App opened from initial notification: ${initialMessage.messageId}',
              name: 'NotificationService',
            );
            _handleMessage(initialMessage);
          }

          // Ensure notification configuration is complete in Firestore
          final userId = user.uid;
          final currentDeviceTimezone =
              await FlutterTimezone.getLocalTimezone();

          final settingsDoc = await _firestore
              .collection('users')
              .doc(userId)
              .collection('settings')
              .doc('notifications')
              .get();

          bool initialNotificationsEnabled = settingsDoc.exists
              ? (settingsDoc.data()?['notificationsEnabled'] ?? true)
              : true;
          String initialNotificationTime = settingsDoc.exists
              ? (settingsDoc.data()?['notificationTime'] ??
                  _defaultNotificationTime)
              : _defaultNotificationTime;
          String initialUserTimezone = settingsDoc.exists
              ? (settingsDoc.data()?['userTimezone'] ?? currentDeviceTimezone)
              : currentDeviceTimezone;

          await _saveNotificationSettingsToFirestore(
            userId,
            initialNotificationsEnabled,
            initialNotificationTime,
            initialUserTimezone,
          );
        } else {
          developer.log(
            'NotificationService: No authenticated user.',
            name: 'NotificationService',
          );
        }
      });
    } catch (e) {
      developer.log(
        'ERROR in NotificationService: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  // Initialize FCM, get/save token and configure listeners
  Future<void> _initializeFCM() async {
    try {
      // Request permission for notifications (iOS and Android 13+)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        'NotificationService: User permission granted: ${settings.authorizationStatus}',
        name: 'NotificationService',
      );

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      developer.log(
        'NotificationService: FCM token obtained: $token',
        name: 'NotificationService',
      );
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Listen for token changes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        developer.log(
          'NotificationService: FCM token refreshed: $newToken',
          name: 'NotificationService',
        );
        _saveFcmToken(newToken);
      });

      // Listener for FCM messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'NotificationService: FCM message in foreground: ${message.messageId}',
          name: 'NotificationService',
        );
        _handleMessage(message);
      });

      // Listener for when user taps a FCM notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log(
          'NotificationService: App opened from notification: ${message.messageId}',
          name: 'NotificationService',
        );
        _handleMessage(message);
      });
    } catch (e) {
      developer.log(
        'ERROR in _initializeFCM: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  // Handle FCM messages and show them locally
  void _handleMessage(RemoteMessage message) {
    if (message.notification != null || message.data.isNotEmpty) {
      developer.log(
        'NotificationService: FCM message received. ID: ${message.messageId}',
        name: 'NotificationService',
      );

      // If message is data-only and you want to show a notification:
      if (message.notification == null && message.data.isNotEmpty) {
        developer.log(
          'NotificationService: FCM message contains only data, showing local notification.',
          name: 'NotificationService',
        );
        showImmediateNotification(
          message.data['title'] ?? 'Data Notification',
          message.data['body'] ?? 'Data content',
          payload: message.data['payload'] as String?,
          id: message.messageId.hashCode,
        );
      } else if (message.notification != null) {
        developer.log(
          'NotificationService: FCM message contains notification (already shown by OS).',
          name: 'NotificationService',
        );
      }
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveFcmToken(String token) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        developer.log(
          'NotificationService: User not authenticated, cannot save FCM token.',
          name: 'NotificationService',
        );
        return;
      }

      final userDocRef = _firestore.collection('users').doc(user.uid);
      await userDocRef.set(
        {'lastLogin': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      final tokenRef = userDocRef.collection('fcmTokens').doc(token);

      await tokenRef.set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.toString(),
      }, SetOptions(merge: true));

      developer.log(
        'NotificationService: FCM token and lastLogin saved to Firestore for user ${user.uid}',
        name: 'NotificationService',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      developer.log(
        'NotificationService: FCM token saved to SharedPreferences.',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'ERROR in _saveFcmToken: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  // Unified method to save ALL notification settings
  Future<void> _saveNotificationSettingsToFirestore(
    String userId,
    bool notificationsEnabled,
    String notificationTime,
    String userTimezone,
  ) async {
    try {
      String currentLanguage = await _getCurrentAppLanguage();
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications');

      await docRef.set(
        {
          'notificationsEnabled': notificationsEnabled,
          'notificationTime': notificationTime,
          'userTimezone': userTimezone,
          'lastUpdated': FieldValue.serverTimestamp(),
          'preferredLanguage': currentLanguage,
        },
        SetOptions(merge: true),
      );
      developer.log(
        'NotificationService: Notification settings saved for $userId: '
        'Enabled: $notificationsEnabled, Time: $notificationTime, Timezone: $userTimezone, Language: $currentLanguage',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'Error saving notification settings for user $userId: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    developer.log(
      'Notification tapped: ${notificationResponse.payload}',
      name: 'NotificationService',
    );
    if (onNotificationTapped != null) {
      onNotificationTapped!(notificationResponse.payload);
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      bool allPermissionsGranted = true;

      if (defaultTargetPlatform == TargetPlatform.android) {
        final notificationStatus = await Permission.notification.request();
        allPermissionsGranted = allPermissionsGranted &&
            (notificationStatus == PermissionStatus.granted);

        if (await Permission.scheduleExactAlarm.isDenied) {
          final alarmStatus = await Permission.scheduleExactAlarm.request();
          allPermissionsGranted = allPermissionsGranted &&
              (alarmStatus == PermissionStatus.granted);
        }

        if (await Permission.ignoreBatteryOptimizations.isDenied) {
          final batteryStatus =
              await Permission.ignoreBatteryOptimizations.request();
          allPermissionsGranted = allPermissionsGranted &&
              (batteryStatus == PermissionStatus.granted);
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        allPermissionsGranted = result ?? false;
      }
      developer.log(
        'NotificationService: Permissions granted: $allPermissionsGranted',
        name: 'NotificationService',
      );
      return allPermissionsGranted;
    } catch (e) {
      developer.log(
        'ERROR in _requestPermissions: $e',
        name: 'NotificationService',
        error: e,
      );
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    developer.log(
      'NotificationService: Notifications enabled set to $enabled',
      name: 'NotificationService',
    );

    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final settingsDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .get();
        String currentNotificationTime =
            settingsDoc.data()?['notificationTime'] ?? _defaultNotificationTime;
        String currentUserTimezone = settingsDoc.data()?['userTimezone'] ??
            await FlutterTimezone.getLocalTimezone();

        await _saveNotificationSettingsToFirestore(
          user.uid,
          enabled,
          currentNotificationTime,
          currentUserTimezone,
        );
        developer.log(
          'NotificationService: Notification state ($enabled) saved to Firestore for user ${user.uid}',
          name: 'NotificationService',
        );
      } catch (e) {
        developer.log(
          'ERROR in setNotificationsEnabled when saving to Firestore: $e',
          name: 'NotificationService',
          error: e,
        );
      }
    }
  }

  Future<String> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationTimeKey) ?? _defaultNotificationTime;
  }

  Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, time);
    developer.log(
      'NotificationService: Notification time set to $time',
      name: 'NotificationService',
    );

    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final settingsDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('notifications')
            .get();
        bool currentNotificationsEnabled =
            settingsDoc.data()?['notificationsEnabled'] ?? true;
        String currentUserTimezone = settingsDoc.data()?['userTimezone'] ??
            await FlutterTimezone.getLocalTimezone();

        await _saveNotificationSettingsToFirestore(
          user.uid,
          currentNotificationsEnabled,
          time,
          currentUserTimezone,
        );
        developer.log(
          'NotificationService: Notification time ($time) saved to Firestore for user ${user.uid}',
          name: 'NotificationService',
        );
      } catch (e) {
        developer.log(
          'ERROR in setNotificationTime when saving to Firestore: $e',
          name: 'NotificationService',
          error: e,
        );
      }
    }
  }

  Future<void> showImmediateNotification(
    String title,
    String body, {
    String? payload,
    int? id,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'immediate_habitus',
        'Habitus Faith Immediate',
        channelDescription: 'Immediate notification from Habitus Faith',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id ?? 1,
        title,
        body,
        platformChannelSpecifics,
        payload: payload ?? 'immediate_habitus',
      );
      developer.log(
        'Immediate notification shown: $title',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'ERROR in showImmediateNotification: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  Future<void> scheduleDailyNotification() async {
    await cancelScheduledNotifications();

    final User? user = _auth.currentUser;
    if (user == null) {
      developer.log(
        'NotificationService: User not authenticated for scheduling local notification.',
        name: 'NotificationService',
      );
      return;
    }

    final docSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('notifications')
        .get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      developer.log(
        'NotificationService: No notification settings found for scheduling.',
        name: 'NotificationService',
      );
      return;
    }

    final data = docSnapshot.data()!;
    bool notificationsEnabled = data['notificationsEnabled'] ?? false;
    String notificationTimeStr =
        data['notificationTime'] ?? _defaultNotificationTime;
    String userTimezoneStr =
        data['userTimezone'] ?? await FlutterTimezone.getLocalTimezone();

    if (!notificationsEnabled) {
      developer.log(
        'NotificationService: Local notifications disabled, not scheduling.',
        name: 'NotificationService',
      );
      await cancelScheduledNotifications();
      return;
    }

    // Parse notification time and timezone
    final parts = notificationTimeStr.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    // Set user timezone for scheduling notification
    try {
      tz.setLocalLocation(tz.getLocation(userTimezoneStr));
      developer.log(
        'NotificationService: Local timezone set to: $userTimezoneStr',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'ERROR setting local timezone to $userTimezoneStr. Using default timezone. Error: $e',
        name: 'NotificationService',
        error: e,
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Calculate next notification time
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    developer.log(
      'NotificationService: tz.TZDateTime.now(tz.local) obtained: $now',
      name: 'NotificationService',
    );
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    developer.log(
      'NotificationService: Final scheduled date for daily notification: $scheduledDate',
      name: 'NotificationService',
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_habitus',
      'Habitus Faith Daily',
      channelDescription: 'Daily reminder for Habitus Faith',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Time for your daily Habitus Faith!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_habitus_payload',
    );
    developer.log(
      'Daily notification scheduled for: $scheduledDate',
      name: 'NotificationService',
    );
  }

  Future<void> cancelScheduledNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log(
      'NotificationService: All scheduled notifications cancelled',
      name: 'NotificationService',
    );
  }

  // Get current app language from SharedPreferences
  Future<String> _getCurrentAppLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('locale') ?? 'en';
    } catch (e) {
      developer.log(
        'Error getting current language: $e',
        name: 'NotificationService',
      );
      return 'en';
    }
  }
}
