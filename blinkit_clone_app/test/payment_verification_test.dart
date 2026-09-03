// test/payment_verification_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/core/widgets/payment_status_animations.dart';
import 'package:blinkit_clone_app/features/checkout/presentation/screens/payment_result_screen.dart';

void main() {
  group('Payment Verification UI Tests', () {
    testWidgets('PaymentSuccessAnimation renders without overflow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PaymentSuccessAnimation(size: 140),
            ),
          ),
        ),
      );

      expect(find.byType(PaymentSuccessAnimation), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('PaymentFailureAnimation renders without overflow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PaymentFailureAnimation(size: 140),
            ),
          ),
        ),
      );

      expect(find.byType(PaymentFailureAnimation), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('PaymentResultScreen displays success details and clears cart',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentResultScreen(
              isSuccess: true,
              orderId: 'FG_TEST_123',
              amount: 2.04,
              utr: 'UTR9988776655',
            ),
          ),
        ),
      );

      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.text('₹2.04 paid successfully'), findsOneWidget);
      expect(find.text('FG_TEST_123'), findsOneWidget);
      expect(find.text('UTR9988776655'), findsOneWidget);
      expect(find.text('Done & Return Home'), findsOneWidget);
    });

    testWidgets('PaymentResultScreen displays failure state properly',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentResultScreen(
              isSuccess: false,
              orderId: 'FG_TEST_456',
              amount: 2.04,
              errorMessage: 'Payment marked as failed by bank.',
            ),
          ),
        ),
      );

      expect(find.text('Payment Incomplete'), findsOneWidget);
      expect(find.text('Payment marked as failed by bank.'), findsOneWidget);
      expect(find.text('Try Payment Again'), findsOneWidget);
    });
  });
}
