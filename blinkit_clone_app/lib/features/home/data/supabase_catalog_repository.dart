// lib/features/home/data/supabase_catalog_repository.dart
// Phase 2 — Supabase cloud catalog repository with local caching for 20K concurrency
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/cache/hive_service.dart';
import '../../../../core/cache/cache_keys.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'catalog_repository.dart';

class SupabaseCatalogRepository implements CatalogRepository {
  final SupabaseClient _client;

  // In-memory cache for ultra-fast UI rendering (< 1ms)
  List<CategoryModel>? _cachedCategories;
  final Map<String, List<ProductModel>> _cachedCategoryProducts = {};
  List<ProductModel>? _cachedAllProducts;

  SupabaseCatalogRepository({SupabaseClient? client})
      : _client = client ?? supabase;

  @override
  Future<List<CategoryModel>> fetchCategories({String? sectionType}) async {
    // Return in-memory cache if available
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      if (sectionType == null) return _cachedCategories!;
      return _cachedCategories!
          .where((c) => c.sectionType == sectionType)
          .toList();
    }

    // Try reading from Hive local cache (sub-10ms startup)
    try {
      final box = await HiveService.openBox<String>(CacheKeys.categories);
      final cachedJson = box.get('cached_categories_v2');
      if (cachedJson != null) {
        final List list = jsonDecode(cachedJson);
        _cachedCategories = list.map((e) => _mapCategory(e)).toList();
      }
    } catch (e) {
      debugPrint('[SupabaseCatalog] Hive category read error: $e');
    }

    // If we had valid Hive cache, trigger background network refresh
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      _refreshCategoriesInBackground();
      if (sectionType == null) return _cachedCategories!;
      return _cachedCategories!
          .where((c) => c.sectionType == sectionType)
          .toList();
    }

    // Synchronous network fetch if no cache exists
    return await _fetchCategoriesFromNetwork(sectionType: sectionType);
  }

  Future<List<CategoryModel>> _fetchCategoriesFromNetwork({
    String? sectionType,
  }) async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name, slug, image_url, section_type, more_count, sort_order')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final list = response as List;
      _cachedCategories = list.map((e) => _mapCategory(e)).toList();

      // Persist to Hive cache v2
      try {
        final box = await HiveService.openBox<String>(CacheKeys.categories);
        await box.put(
          'cached_categories_v2',
          jsonEncode(list),
        );
      } catch (e) {
        debugPrint('[SupabaseCatalog] Hive category write error: $e');
      }

      if (sectionType == null) return _cachedCategories!;
      return _cachedCategories!
          .where((c) => c.sectionType == sectionType)
          .toList();
    } catch (e) {
      debugPrint('[SupabaseCatalog] Error fetching categories from network: $e');
      return _cachedCategories ?? [];
    }
  }

  void _refreshCategoriesInBackground() async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name, slug, image_url, section_type, more_count, sort_order')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final list = response as List;
      _cachedCategories = list.map((e) => _mapCategory(e)).toList();
      final box = await HiveService.openBox<String>(CacheKeys.categories);
      await box.put('cached_categories_v2', jsonEncode(list));
    } catch (e) {
      debugPrint('[SupabaseCatalog] Background category refresh error: $e');
    }
  }

  CategoryModel _mapCategory(dynamic json) {
    final map = json as Map<String, dynamic>;
    final rawImages = map['image_url'];
    List<String> images = [];

    if (rawImages != null) {
      if (rawImages is List) {
        images = rawImages
            .map((e) => e
                .toString()
                .replaceAll('/product-images/categories/', '/product-images/product-images/'))
            .toList();
      } else if (rawImages is String) {
        try {
          final decoded = jsonDecode(rawImages);
          if (decoded is List) {
            images = decoded
                .map((e) => e
                    .toString()
                    .replaceAll('/product-images/categories/', '/product-images/product-images/'))
                .toList();
          } else {
            images = [
              rawImages.replaceAll(
                  '/product-images/categories/', '/product-images/product-images/')
            ];
          }
        } catch (_) {
          images = [
            rawImages.replaceAll(
                '/product-images/categories/', '/product-images/product-images/')
          ];
        }
      }
    }

    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      moreCount: (map['more_count'] as num?)?.toInt() ?? 0,
      sectionType: map['section_type']?.toString() ?? 'bestseller',
      images: images,
    );
  }

  @override
  Future<List<ProductModel>> fetchProducts({required String categoryId}) async {
    // In-memory cache hit
    if (_cachedCategoryProducts.containsKey(categoryId)) {
      return _cachedCategoryProducts[categoryId]!;
    }

    try {
      final response = await _client
          .from('products')
          .select('''
            id, name, unit, category_id, mrp, selling_price, stock_qty, status,
            product_images ( webp_url, sort_order, is_primary )
          ''')
          .eq('status', 'live')
          .eq('category_id', categoryId);

      final list = response as List;
      final products = list.map((e) => _mapProduct(e)).toList();
      _cachedCategoryProducts[categoryId] = products;
      return products;
    } catch (e) {
      debugPrint('[SupabaseCatalog] Error fetching products for $categoryId: $e');
      return [];
    }
  }

  @override
  Future<ProductModel> fetchProductById(String productId) async {
    // Check in-memory all products or category caches first
    if (_cachedAllProducts != null) {
      final found = _cachedAllProducts!.where((p) => p.id == productId);
      if (found.isNotEmpty) return found.first;
    }

    for (final prods in _cachedCategoryProducts.values) {
      final found = prods.where((p) => p.id == productId);
      if (found.isNotEmpty) return found.first;
    }

    try {
      final response = await _client
          .from('products')
          .select('''
            id, name, unit, category_id, mrp, selling_price, stock_qty, status,
            product_images ( webp_url, sort_order, is_primary )
          ''')
          .eq('id', productId)
          .single();

      return _mapProduct(response);
    } catch (e) {
      debugPrint('[SupabaseCatalog] Error fetching product $productId: $e');
      throw Exception('Product $productId not found');
    }
  }

  @override
  Future<List<ProductModel>> fetchAllProducts() async {
    if (_cachedAllProducts != null && _cachedAllProducts!.isNotEmpty) {
      return _cachedAllProducts!;
    }

    try {
      final response = await _client
          .from('products')
          .select('''
            id, name, unit, category_id, mrp, selling_price, stock_qty, status,
            product_images ( webp_url, sort_order, is_primary )
          ''')
          .eq('status', 'live');

      final list = response as List;
      _cachedAllProducts = list.map((e) => _mapProduct(e)).toList();
      return _cachedAllProducts!;
    } catch (e) {
      debugPrint('[SupabaseCatalog] Error fetching all products: $e');
      return _cachedAllProducts ?? [];
    }
  }

  ProductModel _mapProduct(dynamic json) {
    final map = json as Map<String, dynamic>;
    final imagesList = (map['product_images'] as List?) ?? [];
    String imageUrl = '';

    if (imagesList.isNotEmpty) {
      // Find primary or lowest sort_order image
      final primary = imagesList.firstWhere(
        (img) => (img as Map<String, dynamic>)['is_primary'] == true,
        orElse: () => imagesList.first,
      );
      imageUrl = ((primary as Map<String, dynamic>)['webp_url']?.toString() ?? '')
          .replaceAll('/product-images/categories/', '/product-images/product-images/');
    }

    final stockQty = (map['stock_qty'] as num?)?.toInt() ?? 0;

    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      unit: map['unit']?.toString() ?? '1 pack',
      imageUrl: imageUrl,
      categoryId: map['category_id']?.toString() ?? '',
      mrp: (map['mrp'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      inStock: stockQty > 0,
    );
  }
}
