// lib/features/cart/presentation/providers/cart_provider.dart
// Phase 1 — In-memory cart state via Riverpod StateNotifier
// Phase 6: add Hive persistence layer here, zero screen changes
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/models/product_model.dart';

class CartItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int qty;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  CartItem copyWith({int? qty}) {
    return CartItem(
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      price: price,
      qty: qty ?? this.qty,
    );
  }
}

class CartState {
  final Map<String, CartItem> items;

  const CartState({this.items = const {}});

  int get totalItems => items.values.fold(0, (sum, item) => sum + item.qty);

  double get totalAmount =>
      items.values.fold(0.0, (sum, item) => sum + item.price * item.qty);

  List<CartItem> get itemList => items.values.toList();

  int getQuantity(String productId) => items[productId]?.qty ?? 0;

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(ProductModel product) {
    addItem(
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
      price: product.sellingPrice,
    );
  }

  void addItem({
    required String productId,
    required String productName,
    required String imageUrl,
    required double price,
  }) {
    final existing = state.items[productId];
    final updated = Map<String, CartItem>.from(state.items);
    if (existing != null) {
      updated[productId] = existing.copyWith(qty: existing.qty + 1);
    } else {
      updated[productId] = CartItem(
        productId: productId,
        productName: productName,
        imageUrl: imageUrl,
        price: price,
        qty: 1,
      );
    }
    state = state.copyWith(items: updated);
  }

  void removeItem(String productId) {
    final existing = state.items[productId];
    if (existing == null) return;
    final updated = Map<String, CartItem>.from(state.items);
    if (existing.qty > 1) {
      updated[productId] = existing.copyWith(qty: existing.qty - 1);
    } else {
      updated.remove(productId);
    }
    state = state.copyWith(items: updated);
  }

  void updateQty(String productId, int qty) {
    final updated = Map<String, CartItem>.from(state.items);
    if (qty <= 0) {
      updated.remove(productId);
    } else {
      final existing = state.items[productId];
      if (existing != null) {
        updated[productId] = existing.copyWith(qty: qty);
      }
    }
    state = state.copyWith(items: updated);
  }

  void clearCart() {
    state = const CartState();
  }

  int qtyForProduct(String productId) {
    return state.items[productId]?.qty ?? 0;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

// Convenience selector for a single product's qty
final productQtyProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(cartProvider).items[productId]?.qty ?? 0;
});
