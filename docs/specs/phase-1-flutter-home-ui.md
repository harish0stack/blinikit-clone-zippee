# Phase 1 — Flutter Home UI Screens (Demo Data Only)

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-1-flutter-home-ui.md

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

## Typography — Inter (via `google_fonts` package), weights/sizes/colors as observed
| Element | Size | Weight | Color | Notes |
|---|---|---|---|---|
| "Blinkit in" | 14sp | 500 (Medium) | `#FFFFFF` at ~85% opacity | over gold gradient |
| "14 minut..." (ETA, truncated) | 28sp | 800 (ExtraBold) | `#FFFFFF` | single line, ellipsis |
| "Sindhu Nagar, Sewri ▾" | 15sp | 600 (SemiBold) | `#FFFFFF` | includes small down-chevron icon |
| Search placeholder `Search "healthy snacks"` | 15sp | 400 (Regular) | `#6B7280` | inside white/98%-opacity pill, height ~48dp, radius 24 |
| Tab labels (All / Janmashtami / Electronics / Beau...) | 13sp | 600 (SemiBold) | `#FFFFFF` (active "All" has bold white + underline; others slightly lower opacity ~90%) | icon above label, ~56dp tap target |
| "New" pill on Janmashtami | 10sp | 700 (Bold) | white text on `#E23744` red pill | |
| "WELCOME" banner headline | 26sp | 800 (ExtraBold) | `#3D2B00` (dark brown, embossed look) | decorative, can approximate with plain bold text over the banner image |
| "Order now and enjoy great offers" | 14sp | 500 | `#5A4419` | |
| "OFFERS FOR YOU" small caps label | 11sp | 700, letter-spacing 1.2 | `#8A6A1E` | |
| Offer tile headline ("Enjoy FLAT ₹50 OFF") | 14sp | 700 | `#1C1C1C` | |
| Offer tile subtext | 12sp | 400 | `#6B7280` | |
| Section header "Bestsellers" | 22sp | 800 (ExtraBold) | `#1C1C1C` | |
| "+240 more" pill on product stack | 11sp | 600 | `#1C1C1C` on `#F1F1F1` chip | |
| Category label under product stack ("Drinks & Juices") | 15sp | 700 | `#1C1C1C` | 2-line max, center-aligned |
| Bottom nav labels | 11sp | 600 (active), 500 (inactive) | `#1C1C1C` active / `#8E9AAB` inactive | |
 
## Colors
| Token | Hex (verify with eyedropper) | Usage |
|---|---|---|
| `headerGradientTop` | `#7A5A17` | top of header gradient |
| `headerGradientBottom` | `#C9A227` | bottom of header gradient, blends into white content |
| `pageBackground` | `#FFFFFF` | below header |
| `categoryTileBg` | `#EAF4F4` | mint/pale-teal product-stack background squares |
| `chipGray` | `#F1F1F1` | "+N more" chip |
| `textPrimary` | `#1C1C1C` | headings/body |
| `textSecondary` | `#6B7280` | subtext, placeholders |
| `navInactive` | `#8E9AAB` | inactive nav icon/label |
| `redAccent` | `#E23744` | "New" pill, Zomato pill |
 
## Layout (top → bottom, exact spacing to replicate)
1. **Header** (gold gradient, ~230dp tall, rounded-bottom none, extends full width): row 1 = "Blinkit in / 14 minut..." (left, stacked) + wallet chip + profile circle (right, 40dp circle each, 8dp gap). Row 2 = address pill with down-chevron. Row 3 = search bar (white, 48dp height, 16dp horizontal margin, 24dp radius, mic icon right-aligned inside).
2. **Tab rail**: horizontal scroll, 4+ visible tabs, icon (28dp) above label, "All" active with white underline indicator (2dp, 24dp wide, centered).
3. **Welcome banner**: full-bleed image, ~180dp tall, headline overlay centered.
4. **Offers row**: 2 tiles side by side, 12dp gap, 12dp radius, icon + 2-line text each.
5. **"Bestsellers" section header**: 24dp top margin, 16dp horizontal padding.
6. **Product stack grid**: 3 columns, each column = 2×2 mini-grid of product thumbnails inside one rounded `categoryTileBg` card (aspect ~1:1), "+N more" chip bottom-right overlapping the card corner, category label centered below card.
7. **Bottom nav**: fixed, 64dp height, white background, top hairline border `#EDEDED` 1dp, 4 icon+label items evenly spaced + Zomato red pill anchored right edge.
**Do not render the 3 Android system nav buttons** — build only from the status bar down to the app's own bottom nav.

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
