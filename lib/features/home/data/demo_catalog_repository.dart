// lib/features/home/data/demo_catalog_repository.dart
// STUB demo implementation — loads from assets/demo/catalog.json
// Replaced by SupabaseCatalogRepository in Phase 3 (same interface, zero screen changes)
import '../models/category.dart';
import '../models/product.dart';
import 'catalog_repository.dart';

class DemoCatalogRepository implements CatalogRepository {
  // TODO Phase 1: load from assets/demo/catalog.json via rootBundle

  @override
  Future<List<Category>> getCategories() async {
    // Returns empty list until Phase 1 populates catalog.json
    return [];
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return [];
  }
}
