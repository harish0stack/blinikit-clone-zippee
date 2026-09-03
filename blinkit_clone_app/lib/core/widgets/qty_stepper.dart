// lib/core/widgets/qty_stepper.dart
// Shared qty stepper widget — used in product cards, product detail, cart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../theme/app_theme.dart';

class QtyStepper extends ConsumerWidget {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final double? width;
  final double? height;

  const QtyStepper({
    super.key,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = ref.watch(productQtyProvider(productId));
    final h = height ?? 34.0;

    if (qty == 0) {
      return GestureDetector(
        onTap: () {
          ref.read(cartProvider.notifier).addItem(
                productId: productId,
                productName: productName,
                imageUrl: imageUrl,
                price: price,
              );
        },
        child: Container(
          width: width ?? 80,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.blinkitYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'ADD',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width ?? 80,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.blinkitYellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).removeItem(productId),
            child: Container(
              width: h,
              height: h,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 16, color: Colors.black),
            ),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).addItem(
                  productId: productId,
                  productName: productName,
                  imageUrl: imageUrl,
                  price: price,
                ),
            child: Container(
              width: h,
              height: h,
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
