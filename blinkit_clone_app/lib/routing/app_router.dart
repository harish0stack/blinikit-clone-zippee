// lib/routing/app_router.dart
// Phase 1 — Full go_router with shell + all routes
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/main_shell.dart';
import '../features/catalog/presentation/screens/category_listing_screen.dart';
import '../features/catalog/presentation/screens/product_listing_screen.dart';
import '../features/product_detail/presentation/screens/product_detail_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/payment_screen.dart';
import '../features/profile/presentation/screens/account_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash — full screen, no shell
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Shell with bottom nav
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoryListingScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/print',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
      ],
    ),

    // Product listing — outside shell (full screen)
    GoRoute(
      path: '/products',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'] ?? '';
        return ProductListingScreen(categoryId: categoryId);
      },
    ),

    // Product detail — outside shell (full screen)
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: productId);
      },
    ),

    // Checkout — full screen
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // Payment — full screen with dynamic bill total
    GoRoute(
      path: '/checkout/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
  ],
);
