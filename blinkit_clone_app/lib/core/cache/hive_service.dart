// lib/core/cache/hive_service.dart
// STUB: full implementation in Phase 6 (Performance Layer)
import 'package:hive_flutter/hive_flutter.dart';
// ignore: unused_import — CacheKeys used by callers of openBox()
import 'cache_keys.dart'; // exported for convenience

class HiveService {
  HiveService._();

  /// Call once from main() after Supabase init
  static Future<void> init() async {
    await Hive.initFlutter();
    // TODO Phase 6: register TypeAdapters for Category, Product, etc.
  }

  /// Generic box accessor — opens lazily
  static Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) return Hive.box<T>(boxName);
    return Hive.openBox<T>(boxName);
  }

  /// Clear all local cache (call on sign-out)
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
}
