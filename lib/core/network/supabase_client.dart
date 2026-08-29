// lib/core/network/supabase_client.dart
// STUB: fully wired in Phase 3
// NOTE: App connects to Supabase via REST/Realtime (no direct DB port).
//       Server-side DB connections use Supavisor pooler port 6543 (Edge Functions only).
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Call once from main() before runApp()
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
    // TODO Phase 3: authOptions, realtimeClientOptions
  );
}

/// Global Supabase client accessor
SupabaseClient get supabase => Supabase.instance.client;
