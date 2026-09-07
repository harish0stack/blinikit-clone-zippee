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
import '../cache/hive_service.dart';
import '../cache/cache_keys.dart';

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

      // Show Welcome System Notification ONCE for fresh install / new session
      try {
        final box = await HiveService.openBox<bool>(CacheKeys.userProfile);
        final hasShownWelcome = box.get('has_shown_welcome_notification') ?? false;

        if (!hasShownWelcome) {
          await showSystemNotification(
            id: 1001,
            title: 'Welcome to Blinkit ⚡',
            body: "India's last minute app! Groceries delivered to your doorstep in 14 minutes.",
          );
          await box.put('has_shown_welcome_notification', true);
          debugPrint('[FCM] Welcome notification triggered for new user.');
        } else {
          debugPrint('[FCM] Welcome notification skipped (already triggered for this user session).');
        }
      } catch (e) {
        debugPrint('[FCM] Error checking welcome notification status: $e');
      }
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

  /// Cancel exit notification if the user re-opens the app
  static Future<void> cancelExitPushNotification() async {
    try {
      await _localNotifs.cancel(kExitOfferNotificationId);
      debugPrint('[FCM] Cancelled pending exit notification (user returned).');
    } catch (e) {
      debugPrint('[FCM] Error cancelling notification: $e');
    }
  }
}
