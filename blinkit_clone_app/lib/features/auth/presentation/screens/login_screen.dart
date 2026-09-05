// lib/features/auth/presentation/screens/login_screen.dart
// Pixel-perfect Blinkit Onboarding & Phone Auth Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../widgets/infinite_scroll_row.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';
  String _selectedCountryFlag = '🇮🇳';
  bool _isButtonEnabled = false;

  // Curated product assets across 4 scrolling rows
  final List<String> _row1Images = const [
    'assets/product-images/Fresh Vegetables Online/img-5.png',
    'assets/product-images/dairy-bread-eggs/img-1.png',
    'assets/product-images/biscuits and cookies/img-1.png',
    'assets/product-images/chips and namkeen/img-1.png',
    'assets/product-images/Energy Drinks and juices/img-1.png',
  ];

  final List<String> _row2Images = const [
    'assets/product-images/dairy-bread-eggs/img-2.png',
    'assets/product-images/Energy Drinks and juices/img-2.png',
    'assets/product-images/biscuits and cookies/img-2.png',
    'assets/product-images/Fresh Vegetables Online/img-2.png',
    'assets/product-images/chips and namkeen/img-2.png',
  ];

  final List<String> _row3Images = const [
    'assets/product-images/pet food and supplies/img-1.png',
    'assets/product-images/Energy Drinks and juices/img-3.png',
    'assets/product-images/chips and namkeen/img-4.png',
    'assets/product-images/dairy-bread-eggs/img-3.png',
    'assets/product-images/biscuits and cookies/img-3.png',
  ];

  final List<String> _row4Images = const [
    'assets/product-images/chips and namkeen/img-3.png',
    'assets/product-images/Energy Drinks and juices/img-4.png',
    'assets/product-images/dairy-bread-eggs/img-4.png',
    'assets/product-images/Fresh Vegetables Online/img-7.png',
    'assets/product-images/pet food and supplies/img-2.png',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    final isValid = text.length >= 10;
    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_isButtonEnabled) return;
    final phone = _phoneController.text.trim();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendOtp(phone, _selectedCountryCode);

    if (success && mounted) {
      context.push('/verify-otp');
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFD64426),
          ),
        );
      }
    }
  }

  void _handleSkipLogin() async {
    await ref.read(authNotifierProvider.notifier).skipLogin();
    if (mounted) {
      context.go('/home');
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                title: const Text('India (+91)'),
                onTap: () {
                  setState(() {
                    _selectedCountryFlag = '🇮🇳';
                    _selectedCountryCode = '+91';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('United States (+1)'),
                onTap: () {
                  setState(() {
                    _selectedCountryFlag = '🇺🇸';
                    _selectedCountryCode = '+1';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── 1. HERO SECTION: 4-ROW PRODUCT CAROUSEL (TOP) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.56,
            child: Stack(
              children: [
                ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: 520,
                    minHeight: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        InfiniteScrollRow(images: _row1Images, reverse: false, speed: 20),
                        InfiniteScrollRow(images: _row2Images, reverse: true, speed: 18),
                        InfiniteScrollRow(images: _row3Images, reverse: false, speed: 22),
                        InfiniteScrollRow(images: _row4Images, reverse: true, speed: 19),
                      ],
                    ),
                  ),
                ),

                // Deep, seamless white gradient fade dissolving the bottom of the hero section
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 190,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.65),
                          Colors.white.withValues(alpha: 0.92),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.25, 0.55, 0.82, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Right "Skip login" Pill Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _handleSkipLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Skip login',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ),
          ),

          // ── 2. SOLID WHITE BOTTOM CARD (PREVENTS OVERLAPPING ON KEYBOARD OPEN) ──
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Logo (from figma-assests/icons/app-logo.avif)
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF7CB45).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/figma-assests/icons/app-logo.avif',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/figma-assests/icons/app-logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFF7CB45),
                                        child: Center(
                                          child: Text(
                                            'blinkit',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF1E1E1E),
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Headline
                          Text(
                            "India's last minute\napp",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E1E1E),
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            'Log in or sign up',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Phone Input Row
                          Row(
                            children: [
                              // Country Selector Pill
                              GestureDetector(
                                onTap: _showCountryPicker,
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(horizontal: 9.5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCountryFlag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF4B5563),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Number Field
                              Expanded(
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      width: 1.2,
                                    ),boxShadow: [
                                      BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                   ],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedCountryCode,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1E1E1E),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E1E1E),
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                            hintText: 'Enter mobile number',
                                            hintStyle: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (_isButtonEnabled && !authState.isLoading)
                                  ? _handleContinue
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF328614), // Exact Blinkit Green
                                disabledBackgroundColor: const Color(0xFFA5B0C0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Continue',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Footer Terms of Service & Privacy Policy
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'By continuing, you agree to our ',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Terms of service',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                              ),
                              Text(
                                ' & ',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Privacy policy',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
