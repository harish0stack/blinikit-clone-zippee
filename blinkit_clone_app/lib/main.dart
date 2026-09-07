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

  runApp(const BlinkitApp());
}
