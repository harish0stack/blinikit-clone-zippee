// lib/core/cache/cache_keys.dart
// Hive box name constants — single source of truth
class CacheKeys {
  CacheKeys._();

  static const String catalog = 'catalog_cache';
  static const String categories = 'categories_cache';
  static const String cart = 'cart_cache';
  static const String userProfile = 'user_profile_cache';
  // TODO Phase 6: add TTL metadata box
}
