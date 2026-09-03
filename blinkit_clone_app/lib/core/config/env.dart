// lib/core/config/env.dart
// Environment values injected via --dart-define at build time.
// NEVER hardcode secrets here.
// Service-role key stays in Supabase Edge Function env vars ONLY.
class Env {
  Env._();

  /// Supabase project REST/Realtime URL
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bbupnuatcjtcwuzwgvrh.supabase.co',
  );

  /// Supabase anon (publishable) key — safe to expose to clients
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJidXBudWF0Y2p0Y3d1endndnJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYzMjg1MzEsImV4cCI6MjEwMTkwNDUzMX0.oqEae9MvAOSiZ6EpTWCNiSq31qhkBHSE1hgja8YFiRU',
  );
}
