// lib/features/home/models/product.dart
// DATA CONTRACT — frozen for Phase 2 (becomes Postgres schema)
// Do NOT add or remove fields without updating the spec.
abstract class Product {
  String get id;
  String get name;
  String get unit;       // e.g. "500g", "1 kg", "6 pack"
  String get imageUrl;
  String get categoryId;
  double get mrp;
  double get sellingPrice;
  bool get inStock;
}
