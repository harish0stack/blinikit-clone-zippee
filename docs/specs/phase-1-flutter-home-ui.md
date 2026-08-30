# Phase 1 — Flutter Home UI Screens (Demo Data Only)

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-1-flutter-home-ui.md
> Branch: phase-1-flutter-ui
> Phase 0 is COMPLETE. Do not re-scaffold anything from Phase 0.
> ```

---

## Goal

Build all 7 consumer-facing screens pixel-close to Blinkit's real app, wired to a `DemoCatalogRepository` that reads from `assets/demo/catalog.json`. **Zero Supabase calls.** This is pure UI/UX so that Phase 3 is purely a data-layer swap with no screen rewrites.

---

## Screens to Build (in this order)

| # | Screen | Key UI Elements |
|---|---|---|
| 1 | Splash | Logo + app name, 1.5s delay, navigates to Home |
| 2 | Home | Delivery address pill (top bar) + search bar, horizontal category rail (8+ icons), full-width banner carousel (auto-scroll), multiple horizontal product section grids |
| 3 | Category Listing | Grid of subcategory cards (image + name), tapping opens Product Listing |
| 4 | Product Listing | Filter chip row (sort: relevance/price), product cards with name/unit/price/discount badge + qty stepper |
| 5 | Product Detail | Hero image, name, unit, price, MRP strikethrough, description, add-to-cart CTA |
| 6 | Cart | Persistent bottom cart bar (shows item count + total), full Cart screen (item list, qty stepper, subtotal, delivery fee, total) |
| 7 | Bottom Nav Shell | Home / Categories / Cart (badge) / Account tabs |

---

## How We Will Implement It

### Step 1 — Demo catalog data

Create `blinkit_clone_app/assets/demo/catalog.json` with:
- 6 categories (Grocery & Kitchen, Snacks, Dairy, Beverages, Personal Care, Household)
- Each category has 2–3 subcategories
- ~40 total products spread across categories
- Each product has: `id`, `name`, `unit`, `imageUrl` (picsum.photos URL), `categoryId`, `mrp`, `sellingPrice`, `inStock`

Register in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/demo/catalog.json
    - assets/images/
```

### Step 2 — Models with Freezed

File: `lib/features/home/models/category.dart`
```dart
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String imageUrl,
    String? parentId,
  }) = _Category;
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
```

File: `lib/features/home/models/product.dart`
```dart
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String unit,
    required String imageUrl,
    required String categoryId,
    required double mrp,
    required double sellingPrice,
    required bool inStock,
  }) = _Product;
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### Step 3 — Repository layer

**`lib/features/home/data/catalog_repository.dart`** (abstract interface):
```dart
abstract class CatalogRepository {
  Future<List<Category>> fetchCategories({String? parentId});
  Future<List<Product>> fetchProducts({required String categoryId});
  Future<Product> fetchProductById(String productId);
}
```

**`lib/features/home/data/demo_catalog_repository.dart`** (reads from JSON asset):
```dart
class DemoCatalogRepository implements CatalogRepository {
  // loads catalog.json once, caches in memory, filters by parentId/categoryId
}
```

**Riverpod provider** in `lib/features/home/presentation/providers/catalog_providers.dart`:
```dart
@riverpod
CatalogRepository catalogRepository(CatalogRepositoryRef ref) {
  return DemoCatalogRepository();
}

@riverpod
Future<List<Category>> categories(CategoriesRef ref, {String? parentId}) async {
  return ref.watch(catalogRepositoryProvider).fetchCategories(parentId: parentId);
}

@riverpod
Future<List<Product>> products(ProductsRef ref, {required String categoryId}) async {
  return ref.watch(catalogRepositoryProvider).fetchProducts(categoryId: categoryId);
}
```

### Step 4 — Cart state (in-memory, Riverpod StateNotifier)

File: `lib/features/cart/presentation/providers/cart_provider.dart`
```dart
@riverpod
class CartNotifier extends _$CartNotifier {
  // Map<String productId, int qty>
  void addItem(String productId);
  void removeItem(String productId);
  void updateQty(String productId, int qty);
  void clearCart();
  int get totalItems;
  double get totalAmount;   // requires product list to compute
}
```

Cart state is NOT persisted to disk in this phase (that's Phase 6 Hive).

### Step 5 — Routing (go_router)

File: `lib/routing/app_router.dart`:
```dart
// Routes:
// /            → SplashScreen
// /home        → HomeScreen (shell route with bottom nav)
// /categories  → CategoryListingScreen
// /products    → ProductListingScreen (query param: categoryId)
// /product/:id → ProductDetailScreen
// /cart        → CartScreen
// /account     → AccountScreen (stub)
```

### Step 6 — Theme

File: `lib/core/theme/app_theme.dart`:
- Primary color: Blinkit yellow `#F9E005`
- Background: white `#FFFFFF`
- Surface: `#F4F6F8`
- Error: `#FF3B3B`
- Font: Inter (Google Fonts)
- Consistent border radius: 8dp cards, 20dp buttons

### Step 7 — Screens implementation order

Build in this exact order (each is reviewable before the next):
1. `SplashScreen` → navigates to HomeScreen after delay
2. `HomeScreen` (shell with bottom nav)
3. `CategoryListingScreen`
4. `ProductListingScreen`
5. `ProductDetailScreen`
6. `CartScreen` + persistent `CartBottomBar` widget
7. `AccountScreen` (stub — just a centered "Coming Soon" placeholder)

---

## Files in Scope (ONLY these may be touched)

```
blinkit_clone_app/
├── assets/demo/catalog.json                  [CREATE]
├── assets/images/                            [CREATE — placeholder dir]
├── pubspec.yaml                              [MODIFY — add assets, google_fonts dep]
├── lib/
│   ├── main.dart                             [MODIFY]
│   ├── app.dart                              [MODIFY]
│   ├── core/
│   │   ├── theme/app_theme.dart             [MODIFY]
│   │   └── widgets/                         [ADD shared widgets: LoadingWidget, ErrorWidget, EmptyWidget]
│   ├── features/
│   │   ├── home/
│   │   │   ├── data/catalog_repository.dart [MODIFY — abstract interface]
│   │   │   ├── data/demo_catalog_repository.dart [MODIFY — full impl]
│   │   │   ├── models/category.dart         [MODIFY — freezed]
│   │   │   ├── models/product.dart          [MODIFY — freezed]
│   │   │   └── presentation/
│   │   │       ├── screens/home_screen.dart [CREATE]
│   │   │       ├── screens/splash_screen.dart [CREATE]
│   │   │       ├── widgets/category_rail.dart [CREATE]
│   │   │       ├── widgets/banner_carousel.dart [CREATE]
│   │   │       ├── widgets/product_section.dart [CREATE]
│   │   │       └── providers/catalog_providers.dart [MODIFY]
│   │   ├── catalog/
│   │   │   └── presentation/
│   │   │       ├── screens/category_listing_screen.dart [CREATE]
│   │   │       └── screens/product_listing_screen.dart [CREATE]
│   │   │       └── widgets/product_card.dart [CREATE]
│   │   ├── product_detail/
│   │   │   └── presentation/screens/product_detail_screen.dart [CREATE]
│   │   ├── cart/
│   │   │   └── presentation/
│   │   │       ├── screens/cart_screen.dart [CREATE]
│   │   │       ├── widgets/cart_bottom_bar.dart [CREATE]
│   │   │       ├── widgets/cart_item_tile.dart [CREATE]
│   │   │       └── providers/cart_provider.dart [CREATE]
│   │   └── profile/
│   │       └── presentation/screens/account_screen.dart [CREATE — stub]
│   └── routing/app_router.dart              [MODIFY — full routes]
```

**Out of scope:** Supabase SDK usage, OTP/auth screens, order/checkout screens, Hive persistence, any network call.

---

## Acceptance Criteria

- [ ] All 7 screens are navigable via go_router; no dead-end buttons
- [ ] Cart add/remove/qty works across all screens via shared Riverpod state
- [ ] No widget directly references `DemoCatalogRepository` — only `CatalogRepository`
- [ ] `flutter run` succeeds on Android emulator AND iOS simulator with no red screens
- [ ] No layout overflow errors in any screen
- [ ] `assets/demo/catalog.json` has 6 categories and ~40 products
- [ ] `flutter pub run build_runner build` completes cleanly
- [ ] Bottom nav badge shows correct cart item count

---

## Security Checklist (Phase 1 applicable)

| # | Control | Action |
|---|---|---|
| 7 | Service-role key | Confirm still absent from all files |
| All | RLS | N/A — no Supabase calls this phase |

---

## Next Phase

→ **Phase 2**: Database design & Supabase schema + RLS (`docs/specs/phase-2-database-supabase.md`)
