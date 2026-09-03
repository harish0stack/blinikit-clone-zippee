// lib/features/home/models/product_model.dart
// Phase 1 — Product data model (plain Dart class, no Freezed in Phase 1)
class ProductModel {
  final String id;
  final String name;
  final String unit;
  final String imageUrl; // local asset path
  final String categoryId;
  final double mrp;
  final double sellingPrice;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.imageUrl,
    required this.categoryId,
    required this.mrp,
    required this.sellingPrice,
    required this.inStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String,
      mrp: (json['mrp'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      inStock: json['inStock'] as bool,
    );
  }

  int get discountPercent {
    if (mrp <= 0) return 0;
    return (((mrp - sellingPrice) / mrp) * 100).round();
  }
}
