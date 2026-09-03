// lib/features/home/data/demo_catalog_repository.dart
// Phase 1 — Reads from assets/demo/catalog.json; zero Supabase calls
// Phase 3: swap this class with SupabaseCatalogRepository, no screen changes needed
import 'dart:convert';
import 'package:flutter/services.dart';
import 'catalog_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class DemoCatalogRepository implements CatalogRepository {
  // In-memory cache — loaded once on first call
  List<CategoryModel>? _categories;
  List<ProductModel>? _products;

  Future<void> _ensureLoaded() async {
    if (_categories != null) return;
    final raw = await rootBundle.loadString('assets/demo/catalog.json');
    final Map<String, dynamic> json = jsonDecode(raw);
    _categories = (json['categories'] as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    _products = (json['products'] as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories({String? sectionType}) async {
    await _ensureLoaded();
    if (sectionType == null) return List.unmodifiable(_categories!);
    return _categories!
        .where((c) => c.sectionType == sectionType)
        .toList();
  }

  @override
  Future<List<ProductModel>> fetchProducts({required String categoryId}) async {
    await _ensureLoaded();
    return _products!.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<ProductModel> fetchProductById(String productId) async {
    await _ensureLoaded();
    return _products!.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product $productId not found'),
    );
  }

  @override
  Future<List<ProductModel>> fetchAllProducts() async {
    await _ensureLoaded();
    return List.unmodifiable(_products!);
  }
}
