// lib/app.dart
// Phase 0 — top-level app widget (bare MaterialApp.router)
// Phase 1: wrap with ProviderScope, wire full GoRouter
import 'package:flutter/material.dart';
import 'routing/app_router.dart';

class BlinkitApp extends StatelessWidget {
  const BlinkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Phase 1: wrap with ProviderScope
    return MaterialApp.router(
      title: 'Blinkit Clone',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
