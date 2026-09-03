import 'package:flutter/material.dart';
import 'app.dart';
import 'core/network/supabase_client.dart';
import 'core/cache/hive_service.dart';
import 'core/notifications/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  await HiveService.init();

  // Initialize Firebase Cloud Messaging & System Notifications
  await FcmService.initialize();

  // Listen to lifecycle events: when the app is exited or swiped away from RAM
  AppLifecycleListener(
    onResume: () {
      debugPrint('[Lifecycle] App resumed');
      FcmService.cancelExitPushNotification();
    },
    onPause: () {
      debugPrint('[Lifecycle] App paused (minimized / exiting)');
      FcmService.scheduleExitPushNotification(delaySeconds: 15);
    },
    onDetach: () {
      debugPrint('[Lifecycle] App detached (process being terminated)');
      FcmService.scheduleExitPushNotification(delaySeconds: 15);
    },
  );

  runApp(const BlinkitApp());
}
