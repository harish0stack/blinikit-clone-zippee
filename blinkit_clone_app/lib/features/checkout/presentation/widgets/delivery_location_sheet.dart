// lib/features/checkout/presentation/widgets/delivery_location_sheet.dart
// Screen 5 — "Select Delivery Location" Bottom Sheet with GPS Geocoding & Chained Payment Route Handoff
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/providers/location_provider.dart';

class DeliveryLocationSheet extends ConsumerStatefulWidget {
  const DeliveryLocationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => const DeliveryLocationSheet(),
    );
  }

  @override
  ConsumerState<DeliveryLocationSheet> createState() =>
      _DeliveryLocationSheetState();
}

class _DeliveryLocationSheetState extends ConsumerState<DeliveryLocationSheet> {
  bool _showCurrentLocationPrompt = false;

  void _proceedToPayment(String selectedAddress) {
    // Chained Transition: dismiss sheet and push payment screen immediately
    Navigator.of(context).pop();
    context.push('/checkout/payment');
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final currentAddress =
        locationState.valueOrNull ?? 'Sewree, Parmanand Wadi, Parel, Mumbai';

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular 'X' close affordance
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),

          // Main Location Sheet Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: _showCurrentLocationPrompt
                ? _buildCurrentLocationCard(currentAddress)
                : _buildAddressOptionsList(currentAddress),
          ),
        ],
      ),
    );
  }

  // Initial Address Options List (matches address-demand-modal-screen.jpg)
  Widget _buildAddressOptionsList(String currentAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Select delivery location',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 18),

        // Row 1: + Add new address
        InkWell(
          onTap: () {
            setState(() {
              _showCurrentLocationPrompt = true;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                const Icon(Icons.add, color: Color(0xFF0C831F), size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Add new address',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C831F),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),

        // Row 2: Request address from someone...
        InkWell(
          onTap: () => _proceedToPayment(currentAddress),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Request address from someone...',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),

        // Row 3: Import your addresses from Zomato...
        InkWell(
          onTap: () => _proceedToPayment(currentAddress),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCB202D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'zomato',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Import your addresses from Zomato...',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Nested Current Location Prompt (matches further-demand-address-access-permission.jpg)
  Widget _buildCurrentLocationCard(String currentAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Location Pin Illustration
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.location_on, size: 42, color: Color(0xFF0C831F)),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'Do you want this order at\nyour current location?',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // Option 1: Yes, deliver at my current location (Green border)
        InkWell(
          onTap: () => _proceedToPayment(currentAddress),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0C831F), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.my_location, color: Color(0xFF0C831F), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yes, deliver at my current location',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0C831F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Option 2: No, at some other location
        InkWell(
          onTap: () => _proceedToPayment('Connaught Place, New Delhi'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E2E6)),
            ),
            child: Center(
              child: Text(
                'No, at some other location',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0C831F),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
