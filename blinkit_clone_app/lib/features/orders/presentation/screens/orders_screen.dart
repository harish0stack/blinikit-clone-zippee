// lib/features/orders/presentation/screens/orders_screen.dart
// Phase 1 — Stub "Order Again" screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.headerGradientTop,
        title: Text(
          'Order Again',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No previous orders',
              style: GoogleFonts.inter(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Order history will appear here in Phase 4',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
