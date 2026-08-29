// lib/features/home/models/category.dart
// DATA CONTRACT — frozen for Phase 2 (becomes Postgres schema)
// Do NOT add or remove fields without updating the spec.
abstract class Category {
  String get id;
  String get name;
  String get imageUrl;
  String? get parentId;
}
