// lib/routing/app_router.dart
// STUB: one placeholder route — full routing implemented in Phase 1
// Uses go_router (declarative, deep-link ready)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      // TODO Phase 1: replace with HomeScreen()
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text(
            'Blinkit Clone\nPhase 0 — scaffold ready',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ],
);
