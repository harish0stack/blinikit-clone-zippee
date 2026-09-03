// lib/app.dart
// Phase 1 — Top-level app widget with ProviderScope + theme + GoRouter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

class BlinkitApp extends StatelessWidget {
  final List<Override> overrides;
  const BlinkitApp({super.key, this.overrides = const []});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        title: 'Zippee',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: appRouter,
      ),
    );
  }
}
