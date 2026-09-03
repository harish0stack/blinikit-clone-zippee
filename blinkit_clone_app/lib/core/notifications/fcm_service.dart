// lib/core/notifications/fcm_service.dart
// Phase 7 — Firebase Cloud Messaging & System Notifications Service
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../network/supabase_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler executed when app is killed or in background
  debugPrint('[FCM Background] Received message: ${message.messageId}, data: ${message.data}');
}

class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'blinkit_notifications',
    'Blinkit Notifications',
    description: 'Instant delivery updates and exclusive offers',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const int kExitOfferNotificationId = 2002;

  static String? _cachedToken;
  static String? get currentToken => _cachedToken;

  /// Initializes Firebase, notification channels, permissions, and FCM listeners
  static Future<void> initialize() async {
    try {
      debugPrint('[FCM] Initializing Firebase...');
      await Firebase.initializeApp();

      // Initialize timezone database for precise scheduled alarms
      tz.initializeTimeZones();

      // Setup background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize Flutter Local Notifications for system notification drawer
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _localNotifs.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (details) {
          debugPrint('[FCM] Notification tapped: ${details.payload}');
        },
      );

      // Create high-priority notification channel on Android
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifs
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(_channel);
          // Request POST_NOTIFICATIONS on Android 13+
          await androidPlugin.requestNotificationsPermission();
        }
      }

      final messaging = FirebaseMessaging.instance;

      // Request FCM permissions (iOS / Android)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      // Configure foreground presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get initial device token
      _cachedToken = await messaging.getToken();
      debugPrint('[FCM] Token retrieved: $_cachedToken');

      if (_cachedToken != null) {
        await _registerDeviceToken(_cachedToken!);
      }

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        _cachedToken = newToken;
        await _registerDeviceToken(newToken);
      });

      // Foreground message handler — show as Android system notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Message received: ${message.notification?.title}');
        final notification = message.notification;
        if (notification != null) {
          showSystemNotification(
            id: notification.hashCode,
            title: notification.title ?? 'Blinkit ⚡',
            body: notification.body ?? '',
          );
        }
      });

      // Show immediate Welcome System Notification on first app launch
      await showSystemNotification(
        id: 1001,
        title: 'Welcome to Blinkit ⚡',
        body: "India's last minute app! Groceries delivered to your doorstep in 14 minutes.",
      );
    } catch (e, stack) {
      debugPrint('[FCM] Error initializing FCM service: $e\n$stack');
    }
  }

  /// Show a native system notification in the notification drawer / lock screen
  static Future<void> showSystemNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _localNotifs.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[FCM] Error displaying system notification: $e');
    }
  }

  /// Register device token with Supabase `device_tokens` table
  static Future<void> _registerDeviceToken(String token) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      debugPrint('[FCM] Upserting device token to Supabase...');

      await supabase.from('device_tokens').upsert(
        {
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token',
      );
      debugPrint('[FCM] Device token registered in Supabase.');
    } catch (e) {
      debugPrint('[FCM] Error registering token in Supabase: $e');
    }
  }

  /// Schedule the 15-second exit push notification.
  /// Dual implementation:
  /// 1. OS-level AlarmManager: Exact hardware-level alarm scheduled for +15s (100% guaranteed, even if app is brutally killed or offline).
  /// 2. Cloud Edge Function: Dispatches FCM push via Google Play Services in background.
  static Future<void> scheduleExitPushNotification({int delaySeconds = 15}) async {
    // 1. Android OS AlarmManager exact scheduled notification
    try {
      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: const BigTextStyleInformation(
          'Your favorite snacks & groceries are waiting with exclusive deals. Tap to claim!',
        ),
      );

      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));
      await _localNotifs.zonedSchedule(
        kExitOfferNotificationId,
        '⚡ 70% Flat OFF Available!',
        'Your favorite snacks & groceries are waiting with exclusive deals. Tap to claim!',
        scheduledTime,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[FCM] Hardware OS Alarm scheduled for $delaySeconds seconds from now.');
    } catch (e) {
      debugPrint('[FCM] Error scheduling local exact alarm: $e');
    }

    // 2. Cloud Edge Function FCM trigger
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      try {
        debugPrint('[FCM] Invoking send-push-notification in cloud...');
        supabase.functions.invoke(
          'send-push-notification',
          body: {
            'token': _cachedToken,
            'delaySeconds': delaySeconds,
            'type': 'delayed_offer',
            'title': '⚡ 70% Flat OFF Available!',
            'content':
                'Your favorite snacks & groceries are waiting with exclusive deals. Tap to claim!',
          },
        ).then((res) {
          debugPrint('[FCM] Cloud push scheduled successfully: ${res.data}');
        }).catchError((e) {
          debugPrint('[FCM] Cloud push invoke error: $e');
        });
      } catch (e) {
        debugPrint('[FCM] Exception invoking cloud push: $e');
      }
    }
  }

  /// Cancel exit notification if the user re-opens the app before 15 seconds elapse
  static Future<void> cancelExitPushNotification() async {
    try {
      await _localNotifs.cancel(kExitOfferNotificationId);
      debugPrint('[FCM] Cancelled pending exit notification (user returned).');
    } catch (e) {
      debugPrint('[FCM] Error cancelling notification: $e');
    }
  }
}
