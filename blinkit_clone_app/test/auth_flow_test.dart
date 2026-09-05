// test/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/features/auth/presentation/screens/login_screen.dart';
import 'package:blinkit_clone_app/features/auth/presentation/screens/otp_verification_screen.dart';

void main() {
  group('Auth Onboarding UI Tests', () {
    testWidgets('LoginScreen renders hero headline, phone input, and Continue button',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify headline and subtitle
      expect(find.textContaining("India's last minute"), findsOneWidget);
      expect(find.text('Log in or sign up'), findsOneWidget);
      expect(find.text('Skip login'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Verify phone input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter mobile number'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen renders verification boxes and resend timer',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerificationScreen(),
          ),
        ),
      );

      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('We have sent a verification code to'), findsOneWidget);
      expect(find.textContaining('Resend OTP in'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
