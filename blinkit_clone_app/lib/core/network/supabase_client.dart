// lib/core/network/supabase_client.dart
// Supabase Client with standard publishable key for public edge queries
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Call once from main() before runApp()
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
}

/// Global Supabase client accessor
SupabaseClient get supabase => Supabase.instance.client;

