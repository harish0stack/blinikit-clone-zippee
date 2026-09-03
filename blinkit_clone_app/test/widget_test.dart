import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/app.dart';
import 'package:blinkit_clone_app/features/home/presentation/providers/catalog_providers.dart';
import 'package:blinkit_clone_app/features/home/data/catalog_repository.dart';
import 'package:blinkit_clone_app/features/home/models/category_model.dart';
import 'package:blinkit_clone_app/features/home/models/product_model.dart';

class _MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<CategoryModel>> fetchCategories({String? sectionType}) async => [];

  @override
  Future<List<ProductModel>> fetchProducts({required String categoryId}) async => [];

  @override
  Future<ProductModel> fetchProductById(String productId) async =>
      throw UnimplementedError();

  @override
  Future<List<ProductModel>> fetchAllProducts() async => [];
}

void main() {
  testWidgets('Phase 0 smoke test — BlinkitApp renders without red screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      BlinkitApp(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(_MockCatalogRepository()),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
