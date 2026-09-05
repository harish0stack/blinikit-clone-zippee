// lib/features/home/presentation/screens/home_screen.dart
// Blinkit Home Screen — Redesigned with exact Figma Design Tokens & References
//
// Sections:
//  1. Sticky Header with exact Figma layout:
//     - ETA Row: "Blinkit in", "14 minutes", "Sindhu Nagar, Sewri ▾"
//     - Top Right: Wallet (white pill + "₹0" black tag) & Profile (dark circle + user_cog.svg)
//     - Search bar: Search SVG icon, "Search 'healthy snacks'", vertical divider, Mic SVG icon
//     - Category Rail: All (all_bag.svg), Janmashtami (honey_pot.svg + New badge),
//       Electronics (headphone.svg), Beauty (lipstick.svg), Gifts (gift.svg)
//  2. Hero Section:
//     - Full-bleed hero banner (hero_bg.png) with welcome text and 3D bags
//     - Seamlessly connected "✦ OFFERS FOR YOU ✦" tab in Figma gold (#E8B52A)
//  3. Offers Section (#E8B52A):
//     - Horizontally scrollable offer cards (#F6DD8F):
//       Card 1: "Enjoy FLAT ₹50 OFF" / "On your first order above ₹249" (offer_flat50.png)
//       Card 2: "Enjoy FREE delivery" / "On all your orders" (offer_free_delivery.png)
//  4. Bestsellers Section:
//     - Title: "Bestsellers" (Nunito Sans Bold, 22sp, #1C1C1C)
//     - 3-column grid of 2x2 product thumbnail cards (#F3F5F7 container, white item boxes)
//     - Categories: Drinks & Juices, Chips & Namkeen, Vegetables & Fruits,
//       Dairy, Bread & ..., Ice Creams ..., Bakery & Biscuits
//  5. Grocery & Kitchen Section (from reference screenshot):
//     - Title: "Grocery & Kitchen" (22sp ExtraBold, #1C1C1C)
//     - 4-column x 2-row category grid (soft ice-blue card #EAF4F4, 11sp Bold label)
//  6. Snacks & Drinks Section (from reference screenshot):
//     - Title: "Snacks & Drinks" (22sp ExtraBold, #1C1C1C)
//     - 4-column x 2-row category grid (soft ice-blue card #EAF4F4, 11sp Bold label)
//  7. Floating Free Delivery Banner (above bottom bar, as in reference)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../providers/catalog_providers.dart';
import '../providers/location_provider.dart';
import '../../models/category_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../catalog/presentation/widgets/category_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  bool _showFloatingBanner = true;

  static const _railTabs = [
    _RailTab('All', 'assets/figma-assests/icons/all_bag.svg', false),
    _RailTab('Janmashtami', 'assets/figma-assests/icons/janmashtami.svg', true),
    _RailTab('Electronics', 'assets/figma-assests/icons/electronics.svg', false),
    _RailTab('Beauty', 'assets/figma-assests/icons/beauty.svg', false),
    _RailTab('Gifts', 'assets/figma-assests/icons/gifts.svg', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── STICKY FIGMA HEADER ──
              _FigmaHeader(
                selectedTab: _selectedTab,
                tabs: _railTabs,
                onTabTap: (i) => setState(() => _selectedTab = i),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.blinkitGold,
                  onRefresh: () async {
                    ref.invalidate(categoriesProvider);
                    ref.invalidate(allProductsProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero banner + Offers for you tab
                        _buildHeroSection(),

                        // 2. Offers for you horizontal list
                        _buildOffersSection(),

                        const SizedBox(height: 12),

                        // 3. Bestsellers (Figma 3-col 2x2 grid)
                        _buildBestsellersSection(),

                        const SizedBox(height: 20),

                        // 4. Grocery & Kitchen (Reference 4-col grid)
                        _buildGrocerySection(),

                        const SizedBox(height: 20),

                        // 5. Snacks & Drinks (Reference 4-col grid)
                        _buildSnacksSection(),

                        // Bottom clearance for floating banner & nav bar
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── FLOATING VIEW CART PILL BAR (WHEN CART HAS >= 1 ITEM) ──
          if (ref.watch(cartProvider).totalItems > 0)
            Positioned(
              left: 14,
              right: 14,
              bottom: 8,
              child: _buildHomeViewCartPill(ref.watch(cartProvider)),
            )
          else if (_showFloatingBanner)
            Positioned(
              left: 14,
              right: 14,
              bottom: 8,
              child: _buildFloatingDeliveryBanner(),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. OFFERS FOR YOU TAB (Stacked directly under the top hero header)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Container(
      color: const Color(0xFFE8B52A),
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
          decoration: const BoxDecoration(
            color: Color(0xFFE8B52A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Text(
            '✦ OFFERS FOR YOU ✦',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: const Color(0xFF4A3300),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. OFFERS SECTION (Horizontal cards matching Figma token #F6DD8F)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOffersSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8B52A),
      padding: const EdgeInsets.only(bottom: 18),
      child: SizedBox(
        height: 76,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: const [
            _FigmaOfferCard(
              iconAsset: 'assets/figma-assests/icons/offer_flat50.png',
              title: 'Enjoy FLAT ₹50 OFF',
              subtitle: 'On your first order above ₹249',
            ),
            SizedBox(width: 12),
            _FigmaOfferCard(
              iconAsset: 'assets/figma-assests/icons/offer_free_delivery.png',
              title: 'Enjoy FREE delivery',
              subtitle: 'On all your orders',
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. BESTSELLERS SECTION (3-col cards with 2x2 thumbnails in #F3F5F7 box)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBestsellersSection() {
    final async = ref.watch(categoriesProvider('bestseller'));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(),
      data: (cats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Text(
              'Bestsellers',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1C1C),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _bestsellersGrid(cats),
          ),
        ],
      ),
    );
  }

  Widget _bestsellersGrid(List<CategoryModel> cats) {
    final rows = <Widget>[];
    for (int i = 0; i < cats.length; i += 3) {
      final slice = cats.sublist(i, (i + 3).clamp(0, cats.length));
      final padded = List<CategoryModel?>.from(slice);
      while (padded.length < 3) {
        padded.add(null);
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: padded.map((cat) {
          if (cat == null) return const Expanded(child: SizedBox());
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _bestsellerCard(cat),
            ),
          );
        }).toList(),
      ));
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _bestsellerCard(CategoryModel cat) {
    return GestureDetector(
      onTap: () => CategorySheet.show(context, cat),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 2x2 Grid of Product Thumbnails
            _thumbnail2x2Grid(cat),
            const SizedBox(height: 6),
            // Category Name Label
            Text(
              cat.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.nunitoSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1C1C),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail2x2Grid(CategoryModel cat) {
    final imgs = List<String>.from(cat.images);
    while (imgs.length < 4) {
      imgs.add(imgs.isNotEmpty ? imgs.first : '');
    }

    Widget thumbCell(String path, {bool withBadge = false}) {
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: path.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: path,
                        fit: BoxFit.contain,
                      )
                    : const SizedBox(),
              ),
              if (withBadge && cat.moreCount > 0)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${cat.moreCount} more',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              thumbCell(imgs[0]),
              const SizedBox(width: 4),
              thumbCell(imgs[1]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        IntrinsicHeight(
          child: Row(
            children: [
              thumbCell(imgs[2]),
              const SizedBox(width: 4),
              thumbCell(imgs[3], withBadge: true),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. GROCERY & KITCHEN SECTION (4-col grid from reference screenshot)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGrocerySection() {
    final async = ref.watch(categoriesProvider('grocery'));
    return async.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (cats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Grocery & Kitchen',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1C1C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _grid4col(cats),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. SNACKS & DRINKS SECTION (4-col grid from reference screenshot)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSnacksSection() {
    final async = ref.watch(categoriesProvider('snacks'));
    return async.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (cats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Snacks & Drinks',
              style: GoogleFonts.nunitoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1C1C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _grid4col(cats),
          ),
        ],
      ),
    );
  }

  Widget _grid4col(List<CategoryModel> cats) {
    final rows = <Widget>[];
    for (int i = 0; i < cats.length; i += 4) {
      final slice = cats.sublist(i, (i + 4).clamp(0, cats.length));
      final padded = List<CategoryModel?>.from(slice);
      while (padded.length < 4) {
        padded.add(null);
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: padded.map((cat) {
          if (cat == null) return const Expanded(child: SizedBox());
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _categoryTile(cat),
            ),
          );
        }).toList(),
      ));
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _categoryTile(CategoryModel cat) {
    return GestureDetector(
      onTap: () => CategorySheet.show(context, cat),
      child: Column(
        children: [
          Container(
            height: 78,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4F4),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(6),
            child: cat.images.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: cat.images.first,
                    fit: BoxFit.contain,
                  )
                : const Icon(
                    Icons.shopping_basket_outlined,
                    size: 28,
                    color: AppColors.textSecondary,
                  ),
          ),
          const SizedBox(height: 5),
          Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1C),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeViewCartPill(CartState cartState) {
    return GestureDetector(
      onTap: () => context.push('/checkout'),
      child: Container(
        height: 55.6,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C831F),
          borderRadius: BorderRadius.circular(36),
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
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 20, color: Color(0xFF0C831F)),
            ),
            const SizedBox(width: 12),
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
                    cartState.totalItems > 1
                        ? '${cartState.totalItems} items'
                        : '${cartState.totalItems} item',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. FLOATING FREE DELIVERY BANNER (Reference UI component)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFloatingDeliveryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.electric_moped_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Get FREE delivery',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF1D4ED8),
                    ),
                  ],
                ),
                Text(
                  'on your order above ₹99',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showFloatingBanner = false),
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIGMA STICKY HEADER COMPONENT
// ─────────────────────────────────────────────────────────────────────────────
class _RailTab {
  final String label;
  final String iconSvg;
  final bool hasNew;
  const _RailTab(this.label, this.iconSvg, this.hasNew);
}

class _FigmaHeader extends ConsumerWidget {
  final int selectedTab;
  final List<_RailTab> tabs;
  final ValueChanged<int> onTabTap;

  const _FigmaHeader({
    required this.selectedTab,
    required this.tabs,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic client location detection with default fallback
    final locationAsync = ref.watch(locationProvider);
    final addressText = locationAsync.when(
      data: (addr) => addr,
      loading: () => 'Detecting location...',
      error: (_, __) => kDefaultAddress,
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/figma-assests/icons/hero_bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: ETA text & Action Chips (Wallet & Profile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ETA text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Blinkit in',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '14 minutes',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Colors.white,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () =>
                                  _showLocationBottomSheet(context, ref),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$addressText ▾',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Wallet & Profile Chips (Figma exact node-id 1:97)
                      Row(
                        children: [
                          _buildWalletChip(),
                          const SizedBox(width: 8),
                          _buildProfileChip(),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Row 2: Search Bar (Figma exact node-id 1:79)
                  _buildSearchBar(context),
                ],
              ),
            ),
          ),

          // Row 3: Category Rail (Figma exact node-id 1:107)
          _buildCategoryRail(),
        ],
      ),
    );
  }

  Widget _buildWalletChip() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/figma-assests/icons/wallet.svg',
            width: 30,
            height: 27,
          ),
          Positioned(
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₹0',
                style: GoogleFonts.nunitoSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChip() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xCC141414),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/figma-assests/icons/user_cog.svg',
          width: 22,
          height: 22,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Hero(
      tag: 'search_bar_hero',
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/figma-assests/icons/search.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search "healthy snacks"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 22,
                color: const Color(0xFFD5D5D5),
              ),
              GestureDetector(
                onTap: () => context.push('/search?voice=true'),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: SvgPicture.asset(
                    'assets/figma-assests/icons/mic.svg',
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRail() {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final tab = tabs[i];
          final active = selectedTab == i;
          return GestureDetector(
            onTap: () => onTabTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SvgPicture.asset(
                          tab.iconSvg,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      if (tab.hasNew)
                        Positioned(
                          top: -3,
                          right: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE23744),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'New',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: Colors.white.withValues(alpha: active ? 1.0 : 0.82),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Active Underline Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2.5,
                    width: active ? 24 : 0,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose delivery location',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                // "Use current location" button
                InkWell(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final success = await ref
                        .read(locationProvider.notifier)
                        .fetchCurrentAddress(openSettingsIfDenied: true);
                    if (!context.mounted) return;
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enable location services to detect your address.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8B52A)),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFFFBEB),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFFB45309),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use current location',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              Text(
                                'Enable GPS for accurate delivery estimate',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 12,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFB45309),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Popular Delivery Areas',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  'Sindhu Nagar, Sewri',
                  'Powai, Mumbai',
                  'Indiranagar, Bengaluru',
                  'Cyber City, Gurugram',
                  'Connaught Place, New Delhi',
                ].map((area) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      title: Text(
                        area,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      onTap: () {
                        ref
                            .read(locationProvider.notifier)
                            .setManualAddress(area);
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FIGMA OFFER CARD COMPONENT (#F6DD8F with icon + title + subtitle)
// ─────────────────────────────────────────────────────────────────────────────
class _FigmaOfferCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;

  const _FigmaOfferCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6DD8F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_offer,
                  color: Color(0xFF3A2A00),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3A2A00),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5C4A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
