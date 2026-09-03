// lib/features/home/presentation/screens/splash_screen.dart
// Pixel-perfect Blinkit splash screen with #F7CB45 background
// and smooth Zoom-In + Fade-Out (Dissolve) exit transition to Home
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _entryFadeAnim;
  late final Animation<double> _entryScaleAnim;

  late final AnimationController _exitController;
  late final Animation<double> _exitZoomAnim;
  late final Animation<double> _exitFadeAnim;

  @override
  void initState() {
    super.initState();

    // 1. Entry Animation: Smooth fade and subtle settle (0ms - 600ms)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entryFadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _entryScaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 2. Exit Animation: Zoom-In + Disappear Dissolve (1600ms - 2200ms)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitZoomAnim = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _exitFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _entryController.forward();

    // 3. Trigger exit sequence after brief brand showcase
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _exitController.forward().then((_) {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const splashBgColor = Color(0xFFF7CB45);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: splashBgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: splashBgColor,
        body: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_entryController, _exitController]),
            builder: (context, child) {
              final scale = _entryScaleAnim.value * _exitZoomAnim.value;
              final opacity = (_entryFadeAnim.value * _exitFadeAnim.value).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Image.asset(
                'assets/figma-assests/icons/splash-screen.avif',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
