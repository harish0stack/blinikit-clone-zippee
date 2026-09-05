import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/auth_service.dart';

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
    Future.delayed(const Duration(milliseconds: 1400), () async {
      bool isLoggedIn = false;
      bool isGuest = false;
      try {
        isLoggedIn = FirebaseAuth.instance.currentUser != null;
        isGuest = await AuthService().isGuestUser();
      } catch (_) {
        // Fallback gracefully in test/headless environments
      }

      final targetRoute = (isLoggedIn || isGuest) ? '/home' : '/login';

      if (mounted) {
        _exitController.forward().then((_) {
          if (mounted) {
            context.go(targetRoute);
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
              final currentScale = _exitController.isAnimating ||
                      _exitController.isCompleted
                  ? _exitZoomAnim.value * _entryScaleAnim.value
                  : _entryScaleAnim.value;

              final currentOpacity = _exitController.isAnimating ||
                      _exitController.isCompleted
                  ? _exitFadeAnim.value
                  : _entryFadeAnim.value;

              return Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: currentScale,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: 590,
              height: 590,
              child: Image.asset(
                'assets/figma-assests/icons/splash-screen.avif',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/figma-assests/icons/splash-screen.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.shopping_bag_outlined,
                        size: 90,
                        color: Color(0xFF1E1E1E),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
