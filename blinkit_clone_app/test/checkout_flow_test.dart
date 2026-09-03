// test/checkout_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/core/services/upi_detector_service.dart';
import 'package:blinkit_clone_app/features/cart/presentation/providers/cart_provider.dart';

void main() {
  group('Checkout & Payment Flow Tests', () {
    test('UpiDetectorService returns known UPI apps gracefully', () async {
      final apps = await UpiDetectorService.getAvailableUpiApps();
      expect(apps, isNotEmpty);
      expect(apps.any((a) => a.name.contains('FamApp')), isTrue);
      expect(apps.any((a) => a.name.contains('Google Pay')), isTrue);
    });

    test('CartState totalItems and getQuantity updates accurately', () {
      const cart = CartState(items: {
        'prod_1': CartItem(
          productId: 'prod_1',
          productName: 'Amul Milk',
          imageUrl: 'https://xyz/milk.png',
          price: 30.0,
          qty: 2,
        ),
        'prod_2': CartItem(
          productId: 'prod_2',
          productName: 'Brown Bread',
          imageUrl: 'https://xyz/bread.png',
          price: 45.0,
          qty: 1,
        ),
      });

      expect(cart.totalItems, 3);
      expect(cart.totalAmount, 105.0);
      expect(cart.getQuantity('prod_1'), 2);
      expect(cart.getQuantity('prod_2'), 1);
      expect(cart.getQuantity('prod_non_existent'), 0);
    });
  });
}
