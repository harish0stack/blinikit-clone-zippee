// lib/features/home/presentation/screens/main_shell.dart
// Blinkit Main Shell Navigation Bar
// Exact Figma design tokens:
// - Height: ~64dp
// - Background: #FFFFFF with subtle top border
// - 4 Main items: Home, Order Again, Categories, Cart
// - Typography: Nunito Sans Bold, 11sp
// - Icons: SVG assets from assets/figma-assests/icons/
// - Active state: yellow tint (#F9E005) inside icon bounds, active text #111111
// - Inactive state: #726F6F / #7A7777

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(
      label: 'Home',
      iconSvg: 'assets/figma-assests/icons/nav_home.svg',
      path: '/home',
    ),
    _NavItem(
      label: 'Order Again',
      iconSvg: 'assets/figma-assests/icons/nav_order_again.svg',
      path: '/orders',
    ),
    _NavItem(
      label: 'Categories',
      iconSvg: 'assets/figma-assests/icons/nav_categories.svg',
      path: '/categories',
    ),
    _NavItem(
      label: 'Cart',
      iconSvg: 'assets/figma-assests/icons/cart.svg',
      path: '/cart',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5E5), width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 4 Navigation Items evenly distributed
                ..._navItems.map((item) {
                  final isActive = location.startsWith(item.path);
                  return Expanded(
                    child: _BottomNavItem(item: item, isActive: isActive),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String iconSvg;
  final String path;
  const _NavItem({
    required this.label,
    required this.iconSvg,
    required this.path,
  });
}

class _BottomNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _BottomNavItem({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.path),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 26,
            width: 26,
            child: SvgPicture.asset(
              item.iconSvg,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.blinkitYellow : const Color(0xFF726F6F),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFF111111) : const Color(0xFF726F6F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
