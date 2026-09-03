// lib/features/home/models/category_model.dart
// Phase 1 — Category data model (no Freezed in Phase 1; plain Dart class)
class CategoryModel {
  final String id;
  final String name;
  final int moreCount;
  final String sectionType; // 'bestseller' | 'grocery' | 'snacks'
  final List<String> images; // local asset paths (up to 4 for 2x2 grid)

  const CategoryModel({
    required this.id,
    required this.name,
    this.moreCount = 0,
    required this.sectionType,
    required this.images,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      moreCount: (json['moreCount'] as int?) ?? 0,
      sectionType: json['sectionType'] as String,
      images: List<String>.from(json['images'] as List),
    );
  }
}
