// lib/core/utils/logger.dart
// Thin logging wrapper — swap with a structured logger in Phase 6
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message${error != null ? '\n$error' : ''}');
    }
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO]  $message');
  }

  static void warning(String message, [Object? error]) {
    debugPrint('[WARN]  $message${error != null ? '\n$error' : ''}');
  }

  static void error(String message, [Object? err, StackTrace? stack]) {
    debugPrint('[ERROR] $message${err != null ? '\n$err' : ''}');
    if (stack != null && kDebugMode) debugPrint(stack.toString());
  }
}
