// lib/main.dart
// Phase 0 — minimal runnable entry point
// Full initialization (Supabase, Hive) happens in Phase 3
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO Phase 3: await initSupabase()
  // TODO Phase 3: await HiveService.init()
  runApp(const BlinkitApp());
}
