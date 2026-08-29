// lib/features/home/data/catalog_repository.dart
// Abstract repository interface — screens depend only on this contract.
// Implementations: DemoCatalogRepository (Phase 1), SupabaseCatalogRepository (Phase 3)
// ARCHITECTURAL RULE: screens and providers NEVER import a concrete impl directly.
import '../models/category.dart';
import '../models/product.dart';

abstract class CatalogRepository {
  /// Fetch top-level categories (parentId == null)
  Future<List<Category>> getCategories();

  /// Fetch products for a given [categoryId]
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Search products by [query] string
  Future<List<Product>> searchProducts(String query);
}
