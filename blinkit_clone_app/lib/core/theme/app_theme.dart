// lib/core/theme/app_theme.dart
// STUB: full design tokens in Phase 1
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _blinkitYellow = Color(0xFFFFCC00);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _blinkitYellow),
        useMaterial3: true,
        // TODO Phase 1: typography, component themes, spacing tokens
      );
}
