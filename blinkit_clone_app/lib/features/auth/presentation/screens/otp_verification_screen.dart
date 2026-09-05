// lib/features/auth/presentation/screens/otp_verification_screen.dart
// Pixel-perfect OTP Verification Screen with Countdown Timer and Auto-Submit
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<String> _otpDigits = ['', '', '', '', '', ''];
  int _currentDigitIndex = 0;
  Timer? _countdownTimer;
  int _remainingSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = 30;
      _canResend = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onKeyPress(String value) {
    if (_currentDigitIndex < 6) {
      setState(() {
        _otpDigits[_currentDigitIndex] = value;
        _currentDigitIndex++;
      });

      if (_currentDigitIndex == 6) {
        _submitOtp();
      }
    }
  }

  void _onBackspace() {
    if (_currentDigitIndex > 0) {
      setState(() {
        _currentDigitIndex--;
        _otpDigits[_currentDigitIndex] = '';
      });
    }
  }

  Future<void> _submitOtp() async {
    final smsCode = _otpDigits.join();
    if (smsCode.length < 6) return;

    final success =
        await ref.read(authNotifierProvider.notifier).verifyOtp(smsCode);

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Invalid verification code'),
          backgroundColor: const Color(0xFFD64426),
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;
    final phone = ref.read(authNotifierProvider).phoneNumber ?? '';
    final countryCode = phone.startsWith('+91') ? '+91' : '+1';
    final rawNumber = phone.replaceFirst(countryCode, '');

    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendOtp(rawNumber, countryCode);

    if (success && mounted) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: Color(0xFF328614),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final phoneNumber = authState.phoneNumber ?? '+91 8779635760';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E1E1E), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'OTP Verification',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // Subtitle info
                  Text(
                    'We have sent a verification code to',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  if (authState.isDevOtpFallback) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                      ),
                      child: Text(
                        'Demo Mode: Enter 123456 to verify',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // OTP 6-Box Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _currentDigitIndex;
                      final isCurrent = index == _currentDigitIndex;
                      final digit = _otpDigits[index];

                      return Container(
                        width: 46,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF328614)
                                : isFilled
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFFD1D5DB),
                            width: isCurrent ? 2 : 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            digit,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  // Resend OTP Countdown / Action
                  if (authState.isLoading)
                    const CircularProgressIndicator(
                      color: Color(0xFF328614),
                      strokeWidth: 2.5,
                    )
                  else if (_canResend)
                    GestureDetector(
                      onTap: _handleResendOtp,
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF328614),
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend OTP in $_remainingSeconds',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── SYSTEM / CUSTOM NUMPAD ──
          _buildNumericKeypad(),
        ],
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      color: const Color(0xFFE5E7EB),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKey('1', ''),
              _buildKey('2', 'ABC'),
              _buildKey('3', 'DEF'),
            ],
          ),
          Row(
            children: [
              _buildKey('4', 'GHI'),
              _buildKey('5', 'JKL'),
              _buildKey('6', 'MNO'),
            ],
          ),
          Row(
            children: [
              _buildKey('7', 'PQRS'),
              _buildKey('8', 'TUV'),
              _buildKey('9', 'WXYZ'),
            ],
          ),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _buildKey('0', ''),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: InkWell(
                    onTap: _onBackspace,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.backspace_outlined, size: 22, color: Color(0xFF1E1E1E)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number, String letters) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: () => _onKeyPress(number),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
