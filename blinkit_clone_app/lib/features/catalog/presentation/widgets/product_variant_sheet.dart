// lib/features/catalog/presentation/widgets/product_variant_sheet.dart
// Screen 2 — Product Variant Selector Bottom Sheet (~55% height)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/models/product_model.dart';

class ProductVariant {
  final String id;
  final String title;
  final String unit;
  final double price;
  final double originalPrice;
  final String unitRate;
  final String imageUrl;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.unit,
    required this.price,
    required this.originalPrice,
    required this.unitRate,
    required this.imageUrl,
  });
}

class ProductVariantSheet extends ConsumerWidget {
  final ProductModel baseProduct;

  const ProductVariantSheet({
    super.key,
    required this.baseProduct,
  });

  static Future<void> show(BuildContext context, ProductModel product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => ProductVariantSheet(baseProduct: product),
    );
  }

  List<ProductVariant> _generateVariants() {
    final selling = baseProduct.sellingPrice;
    final mrp = baseProduct.mrp > selling ? baseProduct.mrp : selling + 5;

    return [
      ProductVariant(
        id: baseProduct.id,
        title: baseProduct.name,
        unit: baseProduct.unit.isNotEmpty ? baseProduct.unit : '500 ml',
        price: selling,
        originalPrice: mrp,
        unitRate: '₹${(selling / 5).toStringAsFixed(1)}/100 ml',
        imageUrl: baseProduct.imageUrl,
      ),
      ProductVariant(
        id: '${baseProduct.id}_1L',
        title: '${baseProduct.name} (Large)',
        unit: '1 ltr',
        price: (selling * 1.95).roundToDouble(),
        originalPrice: (mrp * 2.1).roundToDouble(),
        unitRate: '₹${((selling * 1.95) / 10).toStringAsFixed(1)}/100 ml',
        imageUrl: baseProduct.imageUrl,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variants = _generateVariants();
    final cartState = ref.watch(cartProvider);

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

          // Main Variant Sheet Container (~55% height)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Title
                Text(
                  baseProduct.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 18),

                // Side-by-side Variant Cards (matches reference frame 3 & 4)
                Row(
                  children: variants.map((variant) {
                    final qty = cartState.getQuantity(variant.id);
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: qty > 0
                                ? const Color(0xFF0C831F)
                                : const Color(0xFFE8E8ED),
                            width: qty > 0 ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Variant Image
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AppNetworkImage(
                                  imageUrl: variant.imageUrl,
                                  width: 100,
                                  height: 90,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ADD Button / Stepper Row
                            Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: qty == 0
                                    ? OutlinedButton(
                                        key: const ValueKey('add_btn'),
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).addItem(
                                                productId: variant.id,
                                                productName: variant.title,
                                                imageUrl: variant.imageUrl,
                                                price: variant.price,
                                              );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF0C831F),
                                          side: const BorderSide(
                                              color: Color(0xFF0C831F), width: 1.2),
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          minimumSize: const Size(90, 34),
                                        ),
                                        child: Text(
                                          'ADD',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('stepper_btn'),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0C831F),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .removeItem(variant.id),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 6),
                                                child: Icon(Icons.remove, color: Colors.white, size: 16),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                '$qty',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .addItem(
                                                    productId: variant.id,
                                                    productName: variant.title,
                                                    imageUrl: variant.imageUrl,
                                                    price: variant.price,
                                                  ),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 6),
                                                child: Icon(Icons.add, color: Colors.white, size: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Variant Unit (e.g. 500 ml)
                            Text(
                              variant.unit,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Variant Price
                            Text(
                              '₹${variant.price.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Unit rate (e.g. ₹6/100 ml)
                            Text(
                              variant.unitRate,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF7E7E7E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
