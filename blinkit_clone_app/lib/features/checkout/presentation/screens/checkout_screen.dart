// lib/features/checkout/presentation/screens/checkout_screen.dart
// Screen 4 — Full-Screen Checkout / Cart Page with Skeleton Loading & Recommendation Carousel
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/models/product_model.dart';
import '../../../home/presentation/providers/catalog_providers.dart';
import '../widgets/delivery_location_sheet.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Brief initial shimmer skeleton loading (matches reference recording)
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final items = cartState.itemList;
    final productsAsync = ref.watch(allProductsProvider);

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
          'Checkout',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E1E1E)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1E1E1E)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonCheckout()
          : items.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Delivery in 8 minutes Card
                          _buildDeliveryTimeCard(cartState.totalItems),
                          const SizedBox(height: 14),

                          // 2. Cart Items Card
                          _buildCartItemsCard(items),
                          const SizedBox(height: 20),

                          // 3. "You might also like" Recommendation Carousel
                          _buildCrossSellSection(productsAsync),
                          const SizedBox(height: 20),

                          // 4. Bill Details Breakdown
                          _buildBillDetailsCard(cartState.totalAmount),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Sticky Bottom CTA Bar: "Choose address at next step"
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 16,
                      child: SafeArea(
                        child: ElevatedButton(
                          onPressed: () => DeliveryLocationSheet.show(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16873C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Choose address',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // Card 1: Delivery in 8 minutes (matches cart-page.png)
  Widget _buildDeliveryTimeCard(int totalItems) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.access_time_filled,
                  color: Color(0xFF0C831F), size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery in 8 minutes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Shipment of $totalItems item${totalItems > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Cart Items (matches cart-page.png)
  Widget _buildCartItemsCard(List<CartItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: items.map((cartItem) {
          final qty = cartItem.qty;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppNetworkImage(
                    imageUrl: cartItem.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),

                // Name, Unit & Move to Wishlist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.productName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Standard pack',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Move to wishlist',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF666666),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stepper & Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C831F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .removeItem(cartItem.productId),
                            child: const Icon(Icons.remove,
                                color: Colors.white, size: 14),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$qty',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(cartProvider.notifier).addItem(
                                  productId: cartItem.productId,
                                  productName: cartItem.productName,
                                  imageUrl: cartItem.imageUrl,
                                  price: cartItem.price,
                                ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${(cartItem.price * qty).toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Section 3: "You might also like" Horizontal Carousel
  Widget _buildCrossSellSection(AsyncValue<List<ProductModel>> productsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You might also like',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: productsAsync.when(
            data: (products) {
              final recs = products.take(6).toList();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    _buildCrossSellCard(recs[index]),
              );
            },
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const SkeletonShimmer(
                  width: 130, height: 220, borderRadius: 12),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildCrossSellCard(ProductModel product) {
    final cartState = ref.watch(cartProvider);
    final qty = cartState.getQuantity(product.id);

    return Container(
      width: 132,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                imageUrl: product.imageUrl,
                width: 90,
                height: 75,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Unit & ADD button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.unit.isNotEmpty ? product.unit : '100 g',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF666666)),
              ),
              InkWell(
                onTap: () => ref.read(cartProvider.notifier).addProduct(product),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF0C831F)),
                  ),
                  child: Text(
                    qty > 0 ? '$qty' : 'ADD',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0C831F),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Price & MRP
          Row(
            children: [
              Text(
                '₹${product.sellingPrice.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(width: 4),
              if (product.mrp > product.sellingPrice)
                Text(
                  '₹${product.mrp.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF888888),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),

          // Discount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FC),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${product.discountPercent > 0 ? product.discountPercent : 15}% OFF on MRP',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1868DB),
              ),
            ),
          ),
          const SizedBox(height: 3),

          // Title
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }

  // Card 4: Bill Details
  Widget _buildBillDetailsCard(double subtotal) {
    const deliveryFee = 0.0; // Free delivery
    const handlingFee = 2.0;
    final total = subtotal + handlingFee + deliveryFee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill details',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Items total', '₹${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildBillRow('Handling charge', '₹$handlingFee'),
          const SizedBox(height: 8),
          _buildBillRow('Delivery fee', 'FREE', isFree: true),
          const Divider(height: 20, color: Color(0xFFF0F0F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand total',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF666666)),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isFree ? const Color(0xFF0C831F) : const Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  // Skeleton Loading View (matches skeleton-page-of -cart-page.jpg)
  Widget _buildSkeletonCheckout() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonShimmer(width: double.infinity, height: 70, borderRadius: 14),
          SizedBox(height: 16),
          SkeletonShimmer(width: double.infinity, height: 100, borderRadius: 14),
          SizedBox(height: 20),
          SkeletonShimmer(width: 160, height: 20, borderRadius: 6),
          SizedBox(height: 14),
          Row(
            children: [
              SkeletonShimmer(width: 130, height: 190, borderRadius: 12),
              SizedBox(width: 12),
              SkeletonShimmer(width: 130, height: 190, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: Color(0xFF999999)),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C831F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }
}
