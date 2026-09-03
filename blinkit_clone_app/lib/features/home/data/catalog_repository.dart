// lib/features/home/data/catalog_repository.dart
// Phase 1 — Abstract interface for catalog data access
// Screens ONLY depend on this interface — never on the concrete implementation
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class CatalogRepository {
  Future<List<CategoryModel>> fetchCategories({String? sectionType});
  Future<List<ProductModel>> fetchProducts({required String categoryId});
  Future<ProductModel> fetchProductById(String productId);
  Future<List<ProductModel>> fetchAllProducts();
}
