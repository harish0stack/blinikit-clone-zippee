// lib/features/checkout/presentation/screens/payment_result_screen.dart
// Displays Payment Success with animated green checkmark or Failure with animated red cross
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/payment_status_animations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class PaymentResultScreen extends ConsumerWidget {
  final bool isSuccess;
  final String orderId;
  final double amount;
  final String? utr;
  final String? senderName;
  final String? errorMessage;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    required this.orderId,
    required this.amount,
    this.utr,
    this.senderName,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If payment was successful, clear the cart
    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(cartProvider.notifier).clearCart();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Icon: Green Circle with Checkmark OR Red Circle with Cross
              Center(
                child: isSuccess
                    ? const PaymentSuccessAnimation(size: 150)
                    : const PaymentFailureAnimation(size: 140),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                isSuccess ? 'Payment Successful!' : 'Payment Incomplete',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isSuccess
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle / Amount
              Text(
                isSuccess
                    ? '₹${amount.toStringAsFixed(2)} paid successfully'
                    : errorMessage ?? 'The payment could not be confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSuccess
                      ? const Color(0xFF0C831F)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 28),

              // Receipt Details Card (Success only)
              if (isSuccess) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('Transaction Ref', orderId),
                      const Divider(height: 16, color: Color(0xFFE5E7EB)),
                      _buildReceiptRow('Bank UTR', utr ?? '42409823101'),
                      const Divider(height: 16, color: Color(0xFFE5E7EB)),
                      _buildReceiptRow(
                          'Paid To', 'Blinkit Commerce (FamPay)'),
                      const Divider(height: 16, color: Color(0xFFE5E7EB)),
                      _buildReceiptRow('Delivery Time', '⚡ In 8 minutes'),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Action Buttons
              if (isSuccess) ...[
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C831F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  child: Text(
                    'Done & Return Home',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/orders'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0C831F),
                    side: const BorderSide(color: Color(0xFF0C831F)),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Track Order',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Try Payment Again',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Cancel and Return to Home',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
