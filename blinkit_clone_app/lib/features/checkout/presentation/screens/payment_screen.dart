// lib/features/checkout/presentation/screens/payment_screen.dart
// Screen 6 — Payment Page with Real On-Device UPI Self-Detection, Grouped Instrument Cards & Dynamic Bill Header
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/upi_detector_service.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../controllers/payment_controller.dart';
import 'confirming_payment_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  List<UpiAppInfo> _detectedUpiApps = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _detectUpi();
  }

  Future<void> _detectUpi() async {
    final apps = await UpiDetectorService.getAvailableUpiApps();
    if (mounted) {
      setState(() {
        _detectedUpiApps = apps;
        _isLoadingApps = false;
      });
    }
  }

  void _handleUpiPay(double amount, UpiAppInfo app) async {
    final controller = PaymentController();

    // 1. Generate order ID, start payment flow, and launch targeted UPI intent
    final session = await controller.startPaymentFlow(
      amount: amount,
      preferredPackage: app.packageName,
    );

    // 2. Handle failure if targeted launch could not open
    if (!session.launched && app.packageName.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${app.name} isn\'t installed on this device'),
            backgroundColor: const Color(0xFFD64426),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 4. Navigate to Confirming Payment holding screen with live Realtime listener
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmingPaymentScreen(
            controller: controller,
            orderId: session.orderId,
            payableAmount: session.payableAmount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final subtotal = cartState.totalAmount;
    final total = subtotal > 0 ? subtotal + 2.0 : 60.0; // ₹2 handling charge fallback
    final recommendedApp = _detectedUpiApps.isNotEmpty
        ? _detectedUpiApps.first
        : UpiDetectorService.knownUpiApps.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Bill total: ₹${total.toStringAsFixed(0)}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E1E),
          ),
        ),
      ),
      body: _isLoadingApps
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C831F)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
              children: [
                // ── SECTION 1: RECOMMENDED (UPI APP DETECTION) ──
                _buildSectionHeader('Recommended'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    _buildUpiItem(total, recommendedApp),
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 2: UPI (ALL DETECTED APPS) ──
                _buildSectionHeader('UPI Options'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    for (int i = 0; i < _detectedUpiApps.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, indent: 68, color: Color(0xFFF0F0F0)),
                      _buildUpiItem(total, _detectedUpiApps[i]),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 3: CARDS ──
                _buildSectionHeader('Cards'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    _buildRow(
                      icon: Icons.credit_card_outlined,
                      title: 'Add credit or debit...',
                      actionLabel: 'ADD',
                      onAction: () {},
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF0F0F0)),
                    _buildRow(
                      customIcon: Container(
                        width: 38,
                        height: 26,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E2E6)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'pluxee',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                      ),
                      title: 'Pluxee',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 4: WALLETS ──
                _buildSectionHeader('Wallets'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    _buildRow(
                      customIcon: Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F9A27),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            '₹',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      title: 'Zippee Money',
                      subtitle: 'Balance: ₹0',
                      showChevron: true,
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF0F0F0)),
                    _buildRow(
                      customIcon: Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF232F3E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'pay',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      title: 'Amazon Pay Balance',
                      subtitle: 'Link your Amazon Pay Bal...',
                      actionLabel: 'ADD',
                      onAction: () {},
                    ),
                    const Divider(height: 1, indent: 56, color: Color(0xFFF0F0F0)),
                    _buildRow(
                      customIcon: Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0073CF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'M',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      title: 'Mobikwik',
                      subtitle: 'Link your Mobikwik wallet',
                      actionLabel: 'ADD',
                      onAction: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 5: PAY LATER ──
                _buildSectionHeader('Pay Later'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    _buildRow(
                      customIcon: Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF04F5E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'LZ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      title: 'LazyPay',
                      subtitle: 'Link your LazyPay account',
                      actionLabel: 'ADD',
                      onAction: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 6: NETBANKING ──
                _buildSectionHeader('Netbanking'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    _buildRow(
                      icon: Icons.account_balance_outlined,
                      title: 'Netbanking',
                      actionLabel: 'ADD',
                      onAction: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── SECTION 7: PAY ON DELIVERY ──
                _buildSectionHeader('Pay On Delivery'),
                const SizedBox(height: 8),
                _buildCard(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFDDDDDD)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.money_outlined,
                                    color: Color(0xFF9E9E9E), size: 18),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Cash on Delivery',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9E9E9E), // Disabled appearance
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF1F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cash on delivery is not available between 12:00 AM and 6:00 AM.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD64426),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E1E1E),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow({
    IconData? icon,
    Widget? customIcon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool showChevron = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (customIcon != null)
            customIcon
          else
            Container(
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E2E6)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: const Color(0xFF1E1E1E), size: 18),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0C831F),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(40, 30),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C831F),
                ),
              ),
            )
          else if (showChevron)
            const Icon(Icons.chevron_right, color: Color(0xFF7E7E7E), size: 20),
        ],
      ),
    );
  }

  Widget _buildUpiItem(double total, UpiAppInfo app) {
    Widget iconWidget;

    if (app.assetIcon.isNotEmpty) {
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          app.assetIcon,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFF0C831F),
            size: 22,
          ),
        ),
      );
    } else {
      iconWidget = const Icon(
        Icons.qr_code_2,
        color: Color(0xFF0C831F),
        size: 24,
      );
    }

    return InkWell(
      onTap: () => _handleUpiPay(total, app),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    'Instant payment via ${app.name}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7E7E7E), size: 20),
          ],
        ),
      ),
    );
  }
}
