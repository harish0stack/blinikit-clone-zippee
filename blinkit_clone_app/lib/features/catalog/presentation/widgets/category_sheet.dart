// lib/features/catalog/presentation/widgets/category_sheet.dart
// Screen 1 — Category & Subcategory Listing Modal Bottom Sheet (~92% height)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/models/category_model.dart';
import '../../../home/models/product_model.dart';
import '../../../home/presentation/providers/catalog_providers.dart';
import 'product_variant_sheet.dart';

class CategorySheet extends ConsumerStatefulWidget {
  final CategoryModel initialCategory;

  const CategorySheet({
    super.key,
    required this.initialCategory,
  });

  static Future<void> show(BuildContext context, CategoryModel category) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => CategorySheet(initialCategory: category),
    );
  }

  @override
  ConsumerState<CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<CategorySheet> {
  late String _selectedSubcategory;
  bool _isLoading = true;

  // Subcategories derived for the category
  final List<Map<String, String>> _subcategories = [
    {'id': 'milk', 'name': 'Milk', 'icon': 'assets/figma-assests/icons/milk.png'},
    {'id': 'bread', 'name': 'Bread &\nPav', 'icon': 'assets/figma-assests/icons/bread.png'},
    {'id': 'eggs', 'name': 'Eggs', 'icon': 'assets/figma-assests/icons/eggs.png'},
    {'id': 'curd', 'name': 'Curd &\nYogurt', 'icon': 'assets/figma-assests/icons/curd.png'},
    {'id': 'cheese', 'name': 'Cheese\n& Butter', 'icon': 'assets/figma-assests/icons/cheese.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = _subcategories.first['id']!;
    // Brief initial skeleton transition
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final cartState = ref.watch(cartProvider);
    final sheetHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Floating handle bar at top of sheet
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.initialCategory.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // Main Body: Left Rail + Right Products Grid
              Expanded(
                child: Row(
                  children: [
                    // Left Subcategories Rail (80px)
                    _buildLeftRail(),

                    // Right Products Pane (2-col grid)
                    Expanded(
                      child: _isLoading
                          ? _buildSkeletonGrid()
                          : productsAsync.when(
                              data: (products) => _buildProductsGrid(products),
                              loading: () => _buildSkeletonGrid(),
                              error: (_, __) => _buildSkeletonGrid(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Docked Floating "View cart" Pill Bar (When cart has >= 1 items)
          if (cartState.totalItems > 0)
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: _buildViewCartPill(cartState),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftRail() {
    return Container(
      width: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(right: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: ListView.builder(
        itemCount: _subcategories.length,
        itemBuilder: (context, index) {
          final sub = _subcategories[index];
          final isSelected = sub['id'] == _selectedSubcategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubcategory = sub['id']!;
              });
            },
            child: Container(
              color: isSelected ? Colors.white : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Stack(
                children: [
                  // Active left green bar
                  if (isSelected)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C831F),
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(3)),
                        ),
                      ),
                    ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0C831F)
                                : const Color(0xFFE2E2E6),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.shopping_basket_outlined,
                              size: 24, color: Color(0xFF0C831F)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sub['name']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0C831F)
                              : const Color(0xFF555555),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductModel> allProducts) {
    final products = allProducts
        .where((p) =>
            p.categoryId == widget.initialCategory.id ||
            p.name.toLowerCase().contains('milk') ||
            p.name.toLowerCase().contains('amul') ||
            allProducts.indexOf(p) < 8)
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: products.isNotEmpty ? products.length : allProducts.length,
      itemBuilder: (context, index) {
        final product = products.isNotEmpty ? products[index] : allProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final cartState = ref.watch(cartProvider);
    final qty = cartState.getQuantity(product.id);

    return GestureDetector(
      onTap: () => ProductVariantSheet.show(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with unit badge
            Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 90,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // 2 options badge
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8F2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD3EDD8)),
                    ),
                    child: Text(
                      '2 options',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C831F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Weight & ADD / Stepper Button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.unit.isNotEmpty ? product.unit : '500 ml',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // ADD Button / Stepper
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: qty == 0
                      ? InkWell(
                          key: const ValueKey('grid_add_btn'),
                          onTap: () =>
                              ref.read(cartProvider.notifier).addProduct(product),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF0C831F), width: 1.2),
                            ),
                            child: Text(
                              'ADD',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0C831F),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('grid_stepper_btn'),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C831F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .removeItem(product.id),
                                child: const Icon(Icons.remove,
                                    color: Colors.white, size: 14),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  '$qty',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .addProduct(product),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 14),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Selling Price
            Text(
              '₹${product.sellingPrice.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 3),

            // Name
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2B2B2B),
                height: 1.2,
              ),
            ),
            const Spacer(),

            // Rating + Delivery Time
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF7B928), size: 11),
                const SizedBox(width: 2),
                Text(
                  '9.2 lac',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: Color(0xFF777777), size: 11),
                const SizedBox(width: 3),
                Text(
                  '8 mins',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: const Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF1EE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '2 left',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      color: const Color(0xFFD64426),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: SkeletonShimmer(width: 90, height: 85, borderRadius: 8)),
            SizedBox(height: 10),
            SkeletonShimmer(width: 45, height: 12, borderRadius: 4),
            SizedBox(height: 8),
            SkeletonShimmer(width: 35, height: 16, borderRadius: 4),
            SizedBox(height: 6),
            SkeletonShimmer(width: 80, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildViewCartPill(CartState cartState) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Dismiss sheet
        context.push('/checkout');   // Push full-screen checkout
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C831F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C831F).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail container
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 20, color: Color(0xFF0C831F)),
            ),
            const SizedBox(width: 12),

            // Item count & View cart label
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View cart',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${cartState.totalItems} item${cartState.totalItems > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron >
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
