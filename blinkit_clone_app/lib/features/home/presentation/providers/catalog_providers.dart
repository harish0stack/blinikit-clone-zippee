// lib/features/home/presentation/providers/catalog_providers.dart
// Phase 1 — Riverpod providers for catalog data (manual, no code generation)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/catalog_repository.dart';
import '../../data/supabase_catalog_repository.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

// Single repository instance connected to live Supabase cloud
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return SupabaseCatalogRepository();
});

// Fetch categories by sectionType
final categoriesProvider = FutureProvider.family<List<CategoryModel>, String?>(
  (ref, sectionType) async {
    return ref.watch(catalogRepositoryProvider).fetchCategories(sectionType: sectionType);
  },
);

// Fetch products for a category
final productsProvider = FutureProvider.family<List<ProductModel>, String>(
  (ref, categoryId) async {
    return ref.watch(catalogRepositoryProvider).fetchProducts(categoryId: categoryId);
  },
);

// Fetch a single product by id
final productByIdProvider = FutureProvider.family<ProductModel, String>(
  (ref, productId) async {
    return ref.watch(catalogRepositoryProvider).fetchProductById(productId);
  },
);

// All products
final allProductsProvider = FutureProvider<List<ProductModel>>(
  (ref) async {
    return ref.watch(catalogRepositoryProvider).fetchAllProducts();
  },
);
