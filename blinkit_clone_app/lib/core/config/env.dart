// lib/core/config/env.dart
// Environment values injected via --dart-define at build time.
// NEVER hardcode secrets here.
// Service-role key stays in Supabase Edge Function env vars ONLY.
class Env {
  Env._();

  /// Supabase project REST/Realtime URL
  /// Pass via: --dart-define=SUPABASE_URL=https://bbupnuatcjtcwuzwgvrh.supabase.co
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon (publishable) key — safe to expose to clients
  /// Pass via: --dart-define=SUPABASE_ANON_KEY=eyJ...
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
