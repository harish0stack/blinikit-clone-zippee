# Phase 6 — Performance Layer

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-6-performance-layer.md
> Branch: phase-6-performance
> Phases 0, 1, 2, 3, 4, 5 are COMPLETE.
> ```

---

## Goal

Make the app perform well at the device level and at the infrastructure level. Four specific optimizations with clear guardrails to prevent battery/data drain.

---

## The Four Optimizations

| # | Technique | Where |
|---|---|---|
| 1 | Hive catalog cache (stale-while-revalidate) | Flutter app |
| 2 | WebP image compression validation | Vendor hub |
| 3 | Supavisor pooler (port 6543) audit | All connection strings |
| 4 | Checkout data prefetch (one screen ahead) | Flutter app |

---

## How We Will Implement It

---

### Optimization 1 — Hive Cache (Stale-While-Revalidate)

**Pattern:** Render from Hive immediately on app launch, then reconcile with live Realtime stream in background. Perceived load = instant.

File: `lib/core/cache/hive_service.dart` (extend from Phase 3 stub)

```dart
class HiveService {
  static const int _maxProductCount = 500;
  static const int _cacheExpiryHours = 24;

  static late Box<String> _productsBox;    // stores JSON strings
  static late Box<String> _categoriesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _productsBox = await Hive.openBox<String>('products_cache');
    _categoriesBox = await Hive.openBox<String>('categories_cache');
  }

  // --- PRODUCTS ---

  static Future<void> cacheProducts(String categoryId, List<Product> products) async {
    final payload = jsonEncode({
      'data': products.map((p) => p.toJson()).toList(),
      'ts': DateTime.now().toIso8601String(),
    });
    await _productsBox.put(categoryId, payload);
    await _evictIfOverLimit();
  }

  static List<Product>? getCachedProducts(String categoryId) {
    final raw = _productsBox.get(categoryId);
    if (raw == null) return null;

    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    final ts = DateTime.parse(parsed['ts'] as String);

    // Evict stale cache
    if (DateTime.now().difference(ts).inHours > _cacheExpiryHours) {
      _productsBox.delete(categoryId);
      return null;
    }

    return (parsed['data'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- CATEGORIES ---

  static Future<void> cacheCategories(List<Category> categories) async {
    final payload = jsonEncode({
      'data': categories.map((c) => c.toJson()).toList(),
      'ts': DateTime.now().toIso8601String(),
    });
    await _categoriesBox.put('all', payload);
  }

  static List<Category>? getCachedCategories() {
    final raw = _categoriesBox.get('all');
    if (raw == null) return null;
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    final ts = DateTime.parse(parsed['ts'] as String);
    if (DateTime.now().difference(ts).inHours > _cacheExpiryHours) {
      _categoriesBox.delete('all');
      return null;
    }
    return (parsed['data'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- LRU EVICTION --- cap at 500 products total

  static Future<void> _evictIfOverLimit() async {
    // Count all products across all category boxes
    int total = 0;
    for (final key in _productsBox.keys) {
      final raw = _productsBox.get(key as String);
      if (raw != null) {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        total += (parsed['data'] as List).length;
      }
    }

    if (total > _maxProductCount) {
      // Remove the oldest box (first key — Hive boxes are insertion-ordered)
      await _productsBox.deleteAt(0);
    }
  }
}
```

**Integration in catalog providers:**

File: `lib/features/home/presentation/providers/catalog_providers.dart`

```dart
@riverpod
Stream<List<Product>> productStream(ProductStreamRef ref, String categoryId) async* {
  // 1. Emit from cache immediately (if available)
  final cached = HiveService.getCachedProducts(categoryId);
  if (cached != null) yield cached;

  // 2. Subscribe to Realtime and emit each update, writing through to cache
  final repo = ref.watch(catalogRepositoryProvider) as SupabaseCatalogRepository;
  await for (final products in repo.watchProducts(categoryId: categoryId)) {
    await HiveService.cacheProducts(categoryId, products);
    yield products;
  }
}
```

**Rule:** Never use `CachedNetworkImage` with a custom cache key in Hive — it has its own LRU disk cache (`flutter_cache_manager` under the hood) that already handles image caching correctly. Only store URL strings in Hive, not image bytes.

---

### Optimization 2 — WebP Compression Validation

**In vendor hub** (extends Phase 5 implementation):

File: `vendor-hub-web/src/lib/imageCompression.ts`

```typescript
import imageCompression from "browser-image-compression";

export interface CompressionResult {
  file: File;
  originalSizeKB: number;
  compressedSizeKB: number;
  compressionRatio: number;
}

export async function compressToWebP(file: File): Promise<CompressionResult> {
  const originalSizeKB = file.size / 1024;

  const compressed = await imageCompression(file, {
    maxSizeMB: 0.3,           // 300KB hard cap
    maxWidthOrHeight: 1080,
    useWebWorker: true,
    fileType: "image/webp",
    quality: 0.78,
  });

  const compressedSizeKB = compressed.size / 1024;

  // Warn if compression wasn't effective (e.g. already small PNG)
  if (compressedSizeKB > 300) {
    console.warn(`[ImageCompression] Output still ${compressedSizeKB.toFixed(0)}KB after compression`);
  }

  return {
    file: new File([compressed], file.name.replace(/\.[^.]+$/, '.webp'), {
      type: 'image/webp',
    }),
    originalSizeKB,
    compressedSizeKB,
    compressionRatio: originalSizeKB / compressedSizeKB,
  };
}
```

Show compression stats in the image uploader UI:
```
Before: 2.4 MB → After: 187 KB (92% smaller)
```

---

### Optimization 3 — Pooler Port Audit

**This is a config check, not new code.** Audit every connection string in the project:

#### Checklist

| Location | Expected | Check |
|---|---|---|
| `vendor-hub-web/src/lib/supabaseClient.ts` | `VITE_SUPABASE_URL` points to Supabase project URL (port handled by SDK) | SDK uses REST API — pooler not applicable here, SDK uses REST over HTTPS |
| `supabase/functions/*/index.ts` | `SUPABASE_URL` env var — Supabase Edge Functions auto-connect via internal routing, not direct port | Verify Edge Functions use `createClient(SUPABASE_URL, SERVICE_ROLE_KEY)` not a direct DB connection string |
| `supabase/config.toml` local dev | `db.port = 54322` (local direct) — OK, this is only used by `supabase db push`, not app connections | Document this explicitly |
| Any external script or test | Must use `DB_POOLER_URL` (port 6543 transaction mode) not `DATABASE_URL` (port 5432) | Add a `.env.example` entry: `DB_POOLER_URL=postgresql://postgres.[ref]:[password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres` |

Create `docs/infra/pooler-config.md`:
```markdown
# Supabase Pooler Configuration

## Connection endpoints

| Type | Port | Use case |
|---|---|---|
| Direct | 5432 | Migrations only (`supabase db push`) |
| Supavisor Session mode | 5432 (via pooler URL) | Long-running connections (not needed for serverless) |
| Supavisor Transaction mode | 6543 | All app connections, Edge Functions, k6 load tests |

## Why transaction mode?

At 20K concurrent users, each Flutter/React client doesn't hold a persistent DB connection
(Supabase SDK uses REST over HTTPS, which is stateless). The pooler is critical for
Edge Functions and direct DB access scripts that might be invoked concurrently.

## Realtime connections

Realtime WebSocket connections bypass the pooler — they connect directly to the
Realtime engine. Plan tier limits apply (Pro plan: 500 concurrent Realtime connections
per project). For 20K users, scope Realtime subscriptions narrowly (per-category channels,
not one global channel).
```

---

### Optimization 4 — Checkout Prefetch (One Screen Ahead)

**Only while user is on Cart screen. Cancelled if user leaves Cart.**

File: `lib/features/cart/presentation/providers/checkout_prefetch_provider.dart`

```dart
@riverpod
class CheckoutPrefetchNotifier extends _$CheckoutPrefetchNotifier {
  @override
  Future<CheckoutPrefetchData?> build() async => null;

  Future<void> prefetch() async {
    // Only prefetch on good connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none ||
        connectivity == ConnectivityResult.mobile) {
      // Skip on poor/metered connections
      return;
    }

    state = const AsyncLoading();

    try {
      final userId = await _getUserId();
      // Fetch addresses (needed for checkout delivery address selection)
      final addresses = await SupabaseClientService.client
          .from('addresses')
          .select()
          .eq('user_id', userId);

      state = AsyncData(CheckoutPrefetchData(
        addresses: addresses.map((e) => Address.fromJson(e)).toList(),
      ));
    } catch (e, st) {
      // Prefetch failure is silent — checkout will fetch fresh data
      state = const AsyncData(null);
    }
  }

  void cancel() {
    // Dispose resets state — if the fetch is in progress, result is discarded
    state = const AsyncData(null);
  }
}

class CheckoutPrefetchData {
  final List<Address> addresses;
  const CheckoutPrefetchData({required this.addresses});
}
```

**In CartScreen:**

```dart
@override
void initState() {
  super.initState();
  // Start prefetch when Cart screen opens
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(checkoutPrefetchNotifierProvider.notifier).prefetch();
  });
}

@override
void dispose() {
  // Cancel if user leaves Cart
  ref.read(checkoutPrefetchNotifierProvider.notifier).cancel();
  super.dispose();
}
```

**In CheckoutScreen:**

```dart
// Use prefetched data if available; otherwise fetch fresh
final prefetched = ref.read(checkoutPrefetchNotifierProvider).valueOrNull;
final addresses = prefetched?.addresses ?? await fetchAddressesFresh();
```

---

## Files in Scope

```
blinkit_clone_app/lib/
├── core/cache/hive_service.dart                             [MODIFY — full impl]
├── features/
│   ├── home/presentation/providers/catalog_providers.dart  [MODIFY — stale-while-revalidate]
│   └── cart/
│       ├── presentation/screens/cart_screen.dart           [MODIFY — add prefetch trigger]
│       └── presentation/providers/checkout_prefetch_provider.dart [CREATE]

vendor-hub-web/src/lib/imageCompression.ts                 [MODIFY — add stats + validation]
vendor-hub-web/src/components/ImageUploader.tsx            [MODIFY — show compression stats]

docs/infra/pooler-config.md                                [CREATE]
```

---

## Acceptance Criteria

- [ ] **Hive cache**: Kill and relaunch app → product list renders from cache before network response arrives (verify by adding a 2-second artificial delay to the Supabase query and confirming UI still loads instantly)
- [ ] **Cache eviction**: Hive boxes are cleaned when total products exceed 500 (write a unit test)
- [ ] **Image compression**: Upload a 5MB JPEG → verify compressed file is WebP, ≤ 300KB, and compression ratio is displayed in the UI
- [ ] **Pooler config**: `docs/infra/pooler-config.md` documents all connection strings; no `DATABASE_URL` (port 5432) is used in any non-migration context
- [ ] **Checkout prefetch**: Navigate to Cart → open Network tab (or add debug logging) → address fetch starts immediately; navigate away → no dangling network request completes after leaving Cart
- [ ] **Connectivity guard**: Disable WiFi → open Cart → prefetch is skipped silently (no error shown to user)
- [ ] `flutter pub run build_runner build` still succeeds cleanly

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS | Re-verify: all new providers only access RLS-permitted data |
| 7 | Service-role key | Still absent from all client files |

---

## Next Phase

→ **Phase 7**: FCM notifications (`docs/specs/phase-7-fcm-notifications.md`)
