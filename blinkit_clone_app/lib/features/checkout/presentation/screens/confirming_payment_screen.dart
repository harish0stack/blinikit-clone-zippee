// lib/features/checkout/presentation/screens/confirming_payment_screen.dart
// Holding screen shown when user switches back from UPI app
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/upi_detector_service.dart';
import '../controllers/payment_controller.dart';
import 'payment_result_screen.dart';

class ConfirmingPaymentScreen extends StatefulWidget {
  final PaymentController controller;
  final String orderId;
  final double payableAmount;

  const ConfirmingPaymentScreen({
    super.key,
    required this.controller,
    required this.orderId,
    required this.payableAmount,
  });

  @override
  State<ConfirmingPaymentScreen> createState() =>
      _ConfirmingPaymentScreenState();
}

class _ConfirmingPaymentScreenState extends State<ConfirmingPaymentScreen> {
  StreamSubscription<PaymentVerificationResult>? _sub;
  int _secondsElapsed = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    _sub = widget.controller.statusStream.listen((result) {
      if (!mounted) return;

      if (result.status == PaymentVerificationStatus.paid) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentResultScreen(
              isSuccess: true,
              orderId: result.orderId,
              amount: result.payableAmount,
              utr: result.utr ?? '42409823101',
              senderName: result.senderName,
            ),
          ),
        );
      } else if (result.status == PaymentVerificationStatus.failed ||
          result.status == PaymentVerificationStatus.timedOut) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentResultScreen(
              isSuccess: false,
              orderId: result.orderId,
              amount: result.payableAmount,
              errorMessage: result.failureReason,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Pulsing Center Graphic
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDCFCE7), width: 2),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0C831F)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Confirming your payment…',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'Waiting for confirmation from your bank.\nThis usually takes 3–5 seconds.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Amount Card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Ref',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.orderId,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${widget.payableAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0C831F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Elapsed timer & Cancel / Help
              Text(
                'Time elapsed: $_secondsElapsed seconds',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: () => _showQrModal(context),
                icon: const Icon(Icons.qr_code_2, color: Color(0xFF0C831F), size: 18),
                label: Text(
                  'Show QR Code to Scan & Pay',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C831F),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0C831F)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel and try another method',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context) {
    final qrUrl = UpiDetectorService.buildQrCodeUrl(
      amount: widget.payableAmount,
      orderId: widget.orderId,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan & Pay ₹${widget.payableAmount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan with any UPI app (Google Pay, PhonePe, Paytm, FamPay)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  qrUrl,
                  width: 220,
                  height: 220,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0C831F),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'UPI ID: ${UpiDetectorService.defaultReceiverVpa}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              Text(
                'Note: Order_${widget.orderId}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
