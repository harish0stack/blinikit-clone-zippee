// lib/features/search/presentation/screens/search_screen.dart
// Pixel-perfect Blinkit Search Screen with instant local + debounced backend search,
// real-time voice speech injection, and exact reference browse UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../catalog/presentation/widgets/product_card.dart';
import '../../../../core/widgets/qty_stepper.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/models/product_model.dart';
import '../../models/search_browse_models.dart';
import '../controllers/search_controller.dart';
import '../widgets/voice_listening_dialog.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool autoStartVoice;
  final bool autofocus;

  const SearchScreen({
    super.key,
    this.autoStartVoice = false,
    this.autofocus = true,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoStartVoice) {
        _triggerVoiceSearch();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerVoiceSearch() {
    final searchNotifier = ref.read(searchNotifierProvider.notifier);
    bool isSheetOpen = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(searchNotifierProvider);
            return VoiceListeningDialog(
              initialText: state.query,
              soundLevel: state.soundLevel,
              onCancel: () {
                isSheetOpen = false;
                searchNotifier.stopVoiceSearch();
                Navigator.pop(context);
              },
            );
          },
        );
      },
    ).then((_) {
      isSheetOpen = false;
      searchNotifier.stopVoiceSearch();
    });

    searchNotifier.startVoiceSearch(
      onTextRecognized: (liveText) {
        // Immediate text injection into search bar & real-time search trigger
        _textController.text = liveText;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: liveText.length),
        );
      },
      onCompleted: () {
        // Automatically dismiss bottom sheet smoothly after user finishes speaking
        Future.delayed(const Duration(milliseconds: 450), () {
          if (isSheetOpen && mounted) {
            isSheetOpen = false;
            Navigator.of(context, rootNavigator: false).pop();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final cartState = ref.watch(cartProvider);
    final hasQuery = searchState.query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7), // Warm off-white reference background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── 1. TOP PINNED APP BAR (HERO TRANSITION READY) ──
                _buildTopSearchBar(searchState),

                // ── 2. DYNAMIC CONTENT: BROWSE STATE OR RESULTS STATE ──
                Expanded(
                  child: hasQuery
                      ? _buildResultsState(searchState)
                      : _buildBrowseState(searchState),
                ),
              ],
            ),

            // ── 3. DYNAMIC FLOATING VIEW CART PILL BAR (ONLY IF CART > 0) ──
            if (cartState.totalItems > 0)
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: _buildFloatingCartPill(cartState),
              ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TOP PINNED SEARCH APP BAR
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTopSearchBar(SearchState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1EFE8), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Arrow
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E), size: 24),
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          // Search Field Container with Hero transition
          Expanded(
            child: Hero(
              tag: 'search_bar_hero',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      // Search Icon
                       SvgPicture.asset(
                       'assets/figma-assests/icons/search.svg',
                        width: 20,
                        height: 20,
                      ),

                    const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: widget.autofocus && !widget.autoStartVoice,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1E1E),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search for atta, dal, co...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (val) {
                            ref
                                .read(searchNotifierProvider.notifier)
                                .onQueryChanged(val);
                          },
                        ),
                      ),

                      // Clear Button when text exists
                      if (_textController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _textController.clear();
                            ref
                                .read(searchNotifierProvider.notifier)
                                .onQueryChanged('');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.close, color: Color(0xFF6B7280), size: 18),
                          ),
                        ),

                      // Vertical Divider
                      Container(
                        width: 1.2,
                        height: 22,
                        color: const Color(0xFFD1D5DB),
                      ),

                      // Microphone Icon
                      GestureDetector(
                        onTap: _triggerVoiceSearch,
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STATE 1: BROWSE STATE (WHEN SEARCH QUERY IS EMPTY)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBrowseState(SearchState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SECTION 1: RECENT SEARCHES ──
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent searches',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(searchNotifierProvider.notifier).clearAllRecentSearches();
                  },
                  child: Text(
                    'clear',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0C831F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.recentSearches.map((term) {
                final isIceCream = term.toLowerCase().contains('ice');
                return GestureDetector(
                  onTap: () {
                    _textController.text = term;
                    _textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: term.length),
                    );
                    ref.read(searchNotifierProvider.notifier).onQueryChanged(term);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E2E6),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isIceCream)
                          const Text('🍦', style: TextStyle(fontSize: 13))
                        else
                          const Icon(
                            Icons.search,
                            size: 15,
                            color: Color(0xFF6B7280),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          term,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
          ],

          // ── SECTION 2: CONTINUE BROWSING FOR ──
          if (state.continueBrowsingItems.isNotEmpty) ...[
            Text(
              'Continue browsing for',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 188,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.continueBrowsingItems.length,
                itemBuilder: (context, index) {
                  final item = state.continueBrowsingItems[index];
                  return _buildContinueBrowsingCard(item);
                },
              ),
            ),
            const SizedBox(height: 26),
          ],

          // ── SECTION 3: TRENDING IN YOUR CITY ──
          if (state.trendingItems.isNotEmpty) ...[
            Text(
              'Trending in your city',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 124,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.trendingItems.length,
                itemBuilder: (context, index) {
                  final item = state.trendingItems[index];
                  return _buildTrendingItem(item);
                },
              ),
            ),
            const SizedBox(height: 26),
          ],

          // ── SECTION 4: YOUR WISHLIST ──
          Text(
            'Your wishlist',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          _buildWishlistSection(state.wishlistProducts),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CARD BUILDER: CONTINUE BROWSING
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildContinueBrowsingCard(BrowseHistoryItem item) {
    return Container(
      width: 136,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF), // Soft lavender-blue tint matching Image 1
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE7FC), width: 1.2),
      ),
      child: Column(
        children: [
          // Top Eyebrow Badge + Dismiss
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_outlined, size: 10, color: Color(0xFF4B5563)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            item.daysAgo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(searchNotifierProvider.notifier)
                        .removeContinueBrowsingItem(item.id);
                  },
                  child: const Icon(Icons.close, size: 15, color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),

          // Center Image
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFF0C831F),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          // Bottom White Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7E7E7E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILDER: TRENDING ITEM
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTrendingItem(TrendingItem item) {
    return GestureDetector(
      onTap: () {
        _textController.text = item.title;
        ref.read(searchNotifierProvider.notifier).onQueryChanged(item.title);
      },
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFF59E0B),
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E1E1E),
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILDER: WISHLIST CAROUSEL (EXACT MATCHING IMAGE 2)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWishlistSection(List<ProductModel> products) {
    // If no dynamic products yet, show reference curated items
    final displayItems = products.isNotEmpty
        ? products
        : [
            const ProductModel(
              id: 'wish_1',
              name: 'Swiss Beauty Kiss Kandy Tinted Lip Balm (Pom...',
              unit: '10 ml',
              imageUrl: 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/amul_tub.png',
              categoryId: 'beauty',
              mrp: 119,
              sellingPrice: 113,
              inStock: true,
            ),
            const ProductModel(
              id: 'wish_2',
              name: 'Dot & Key Gloss Boss Tinted Lip Balm (Cocoa Mi...',
              unit: '12 g',
              imageUrl: 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/icecream_cup.png',
              categoryId: 'beauty',
              mrp: 249,
              sellingPrice: 199,
              inStock: true,
            ),
            const ProductModel(
              id: 'wish_3',
              name: 'MuscleBlaze High Protein Oats (Dark Chocolate Flavour)',
              unit: '400 g',
              imageUrl: 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/hide_and_seek.png',
              categoryId: 'snacks',
              mrp: 349,
              sellingPrice: 299,
              inStock: true,
            ),
          ];

    return SizedBox(
      height: 335,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final p = displayItems[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image + Heart Icon + Top Rated Chip
                Stack(
                  children: [
                    Container(
                      height: 125,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: AppNetworkImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // Red Heart Wishlist Indicator
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite, color: Color(0xFFE11D48), size: 18),
                    ),
                    // Top Rated Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Top Rated',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Unit & ADD Button Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.unit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      QtyStepper(
                        productId: p.id,
                        productName: p.name,
                        imageUrl: p.imageUrl,
                        price: p.sellingPrice,
                        width: 60,
                        height: 28,
                      ),
                    ],
                  ),
                ),

                // Price & MRP
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  child: Row(
                    children: [
                      Text(
                        '₹${p.sellingPrice.toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      if (p.mrp > p.sellingPrice) ...[
                        const SizedBox(width: 4),
                        Text(
                          '₹${p.mrp.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.lineThrough,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Discount Banner
                if (p.discountPercent > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                    child: Text(
                      '${p.discountPercent}% OFF on MRP',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),

                // Product Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  child: Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                      height: 1.2,
                    ),
                  ),
                ),

                const Spacer(),

                // ETA Chip & Low Stock Chip
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 3),
                          Text(
                            '9 mins',
                            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '1 left',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STATE 2: RESULTS STATE (WHEN SEARCH QUERY IS ACTIVE)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildResultsState(SearchState state) {
    if (state.results.isEmpty && !state.isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                'No results found for "${state.query}"',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching for milk, ice cream, chips, or vegetables',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.64,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final product = state.results[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DYNAMIC FLOATING VIEW CART PILL
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFloatingCartPill(CartState cartState) {
    return GestureDetector(
      onTap: () => context.push('/cart'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0C831F), // Exact Blinkit Brand Green
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C831F).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Thumbnail Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const ClipOval(
                child: Icon(Icons.shopping_bag, size: 20, color: Color(0xFF0C831F)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
            const Icon(Icons.chevron_right, color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}
