import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/features/home/models/category_model.dart';
import 'package:blinkit_clone_app/features/home/models/product_model.dart';

void main() {
  group('Supabase Models & Mapping Tests', () {
    test('CategoryModel deserializes json with cloud URLs correctly', () {
      final json = {
        'id': '5d625204-618f-5b86-8933-ab22149f4c08',
        'name': 'Drinks & Juices',
        'moreCount': 240,
        'sectionType': 'bestseller',
        'images': [
          'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/diet_coke.png',
          'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/coke.png',
        ],
      };

      final cat = CategoryModel.fromJson(json);
      expect(cat.id, '5d625204-618f-5b86-8933-ab22149f4c08');
      expect(cat.name, 'Drinks & Juices');
      expect(cat.moreCount, 240);
      expect(cat.images.length, 2);
      expect(cat.images.first, contains('https://bbupnuatcjtcwuzwgvrh.supabase.co'));
    });

    test('ProductModel calculates discountPercent and handles CDN URL', () {
      final json = {
        'id': '0e0cf484-0c0d-5315-b257-efea78c73f23',
        'name': 'Diet Coke Can',
        'unit': '300 ml',
        'imageUrl': 'https://bbupnuatcjtcwuzwgvrh.supabase.co/storage/v1/object/public/product-images/figma-products/diet_coke.png',
        'categoryId': '5d625204-618f-5b86-8933-ab22149f4c08',
        'mrp': 40.0,
        'sellingPrice': 38.0,
        'inStock': true,
      };

      final prod = ProductModel.fromJson(json);
      expect(prod.id, '0e0cf484-0c0d-5315-b257-efea78c73f23');
      expect(prod.discountPercent, 5);
      expect(prod.inStock, isTrue);
      expect(prod.imageUrl, startsWith('https://'));
    });
  });
}
