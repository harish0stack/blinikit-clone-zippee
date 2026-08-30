# Phase 3 — Realtime Catalog Sync + Edge Functions + APIs

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-3-realtime-catalog-sync.md
> Branch: phase-3-realtime
> Phases 0, 1, 2 are COMPLETE.
> ```

---

## Goal

Wire Flutter app to real Supabase data by replacing `DemoCatalogRepository` with `SupabaseCatalogRepository`. Implement the three Edge Functions (`publish-product`, `otp-guard`). Configure Database Webhook to trigger `publish-product` on product insert/update. Validate the end-to-end realtime flow.

---

## The Sync Flow (implement exactly this, no shortcuts)

```
Vendor (React) → insert product (status=pending_review)
  → DB Webhook fires → publish-product Edge Function
    → validates product → sets status=live (or rejected)
      → Supabase Realtime picks up status change
        → Flutter StreamProvider receives update
          → UI updates in ~1-2 seconds
            → Hive cache updated (background write-through)
```

---

## How We Will Implement It

### Part A — Flutter: SupabaseCatalogRepository

#### Step 1 — Initialize Supabase client

File: `lib/core/network/supabase_client.dart`
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseClientService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      // NOTE: realtimeClientOptions can tune channel counts
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

File: `lib/core/config/env.dart`
```dart
class Env {
  // Injected via --dart-define at build time
  // flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

#### Step 2 — SupabaseCatalogRepository

File: `lib/features/home/data/supabase_catalog_repository.dart`
```dart
class SupabaseCatalogRepository implements CatalogRepository {
  final SupabaseClient _client;

  SupabaseCatalogRepository(this._client);

  @override
  Future<List<Category>> fetchCategories({String? parentId}) async {
    var query = _client
        .from('categories')
        .select()
        .eq('is_active', true);
    if (parentId != null) {
      query = query.eq('parent_id', parentId);
    } else {
      query = query.isFilter('parent_id', null);
    }
    final data = await query.order('sort_order');
    return data.map((e) => Category.fromJson(e)).toList();
  }

  @override
  Future<List<Product>> fetchProducts({required String categoryId}) async {
    final data = await _client
        .from('products')
        .select('*, product_images(*)')
        .eq('category_id', categoryId)
        .eq('status', 'live')
        .order('created_at', ascending: false);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  @override
  Future<Product> fetchProductById(String productId) async {
    final data = await _client
        .from('products')
        .select('*, product_images(*)')
        .eq('id', productId)
        .eq('status', 'live')
        .single();
    return Product.fromJson(data);
  }

  // Realtime: subscribe to live product changes for a category
  Stream<List<Product>> watchProducts({required String categoryId}) {
    return _client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .map((rows) => rows
            .where((r) => r['status'] == 'live')
            .map((e) => Product.fromJson(e))
            .toList());
  }
}
```

#### Step 3 — Switch provider from Demo to Supabase

File: `lib/features/home/presentation/providers/catalog_providers.dart`
```dart
@riverpod
CatalogRepository catalogRepository(CatalogRepositoryRef ref) {
  // PHASE 3: swap from Demo to Supabase
  return SupabaseCatalogRepository(SupabaseClientService.client);
  // DemoCatalogRepository() ← was Phase 1
}

// StreamProvider for realtime products
@riverpod
Stream<List<Product>> productStream(
  ProductStreamRef ref,
  String categoryId,
) {
  final repo = ref.watch(catalogRepositoryProvider) as SupabaseCatalogRepository;
  return repo.watchProducts(categoryId: categoryId);
}
```

#### Step 4 — Hive write-through cache

File: `lib/core/cache/hive_service.dart`
```dart
class HiveService {
  static late Box<Map> _productsBox;
  static late Box<Map> _categoriesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _productsBox = await Hive.openBox<Map>('products');
    _categoriesBox = await Hive.openBox<Map>('categories');
  }

  // Write-through: call after every Realtime update
  static Future<void> cacheProducts(String categoryId, List<Map> products) async {
    await _productsBox.put(categoryId, {'data': products, 'ts': DateTime.now().toIso8601String()});
  }

  static List<Map>? getCachedProducts(String categoryId) {
    final entry = _productsBox.get(categoryId);
    if (entry == null) return null;
    // Evict cache older than 24h
    final ts = DateTime.parse(entry['ts'] as String);
    if (DateTime.now().difference(ts).inHours > 24) {
      _productsBox.delete(categoryId);
      return null;
    }
    return List<Map>.from(entry['data'] as List);
  }

  // Cap total products to avoid unbounded growth
  static Future<void> evictIfOverLimit({int limit = 500}) async {
    // Implementation: count all cached products, drop LRU boxes if over limit
  }
}
```

Update `productStream` provider: on each stream event, call `HiveService.cacheProducts()`.

---

### Part B — Edge Functions

#### `publish-product` Edge Function

File: `supabase/functions/publish-product/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  // Only accept DB Webhook POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Webhook payload from Supabase DB Webhook
  const payload = await req.json();
  const record = payload.record;          // the inserted/updated product row
  const productId: string = record.id;

  // Use SERVICE ROLE key — never exposed to clients
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Only process products in pending_review
  if (record.status !== "pending_review") {
    return new Response("Skipped", { status: 200 });
  }

  // Validation rules
  const errors: string[] = [];
  if (!record.name || record.name.trim() === "") errors.push("name required");
  if (!record.unit || record.unit.trim() === "") errors.push("unit required");
  if (!record.mrp || record.mrp <= 0) errors.push("mrp must be > 0");
  if (!record.selling_price || record.selling_price <= 0) errors.push("selling_price must be > 0");
  if (record.selling_price > record.mrp) errors.push("selling_price cannot exceed mrp");

  // Check at least one image exists
  const { count } = await supabase
    .from("product_images")
    .select("id", { count: "exact", head: true })
    .eq("product_id", productId);

  if (!count || count === 0) errors.push("at least one product image required");

  const newStatus = errors.length === 0 ? "live" : "rejected";

  // Update product status
  await supabase
    .from("products")
    .update({ status: newStatus })
    .eq("id", productId);

  // Write audit log
  await supabase.from("product_audit_log").insert({
    product_id: productId,
    action: "status_changed",
    diff: { status: { from: "pending_review", to: newStatus }, errors },
  });

  return new Response(
    JSON.stringify({ status: newStatus, errors }),
    { headers: { "Content-Type": "application/json" } }
  );
});
```

Deploy via MCP:
```
Tool: deploy_edge_function
Args:
  name: "publish-product"
  # (entrypoint_path points to supabase/functions/publish-product/index.ts)
```

Alternatively via CLI: `supabase functions deploy publish-product --no-verify-jwt`

#### `otp-guard` Edge Function

File: `supabase/functions/otp-guard/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Rate limit: max 5 OTP requests per phone per 10 minutes
const RATE_LIMIT = 5;
const WINDOW_MINUTES = 10;

serve(async (req: Request) => {
  const { phone } = await req.json();

  if (!phone || !/^\+[1-9]\d{7,14}$/.test(phone)) {
    return new Response(
      JSON.stringify({ error: "Invalid phone number format" }),
      { status: 400 }
    );
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Count recent OTP attempts
  const windowStart = new Date(Date.now() - WINDOW_MINUTES * 60 * 1000).toISOString();
  const { count } = await supabase
    .from("otp_attempts")
    .select("id", { count: "exact", head: true })
    .eq("phone", phone)
    .gte("created_at", windowStart);

  if ((count ?? 0) >= RATE_LIMIT) {
    return new Response(
      JSON.stringify({ error: "Too many OTP requests. Try again in 10 minutes." }),
      { status: 429 }
    );
  }

  // Log this attempt
  await supabase.from("otp_attempts").insert({ phone });

  // Trigger actual Supabase Auth OTP
  const { error } = await supabase.auth.admin.generateLink({
    type: "magiclink",   // or phone OTP — adjust to Supabase phone auth call
    phone,
  });

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  return new Response(JSON.stringify({ success: true }), { status: 200 });
});
```

Add `otp_attempts` table migration:
```sql
-- supabase/migrations/<timestamp>_otp_attempts.sql
CREATE TABLE otp_attempts (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone      TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_otp_attempts_phone_time ON otp_attempts(phone, created_at);
ALTER TABLE otp_attempts ENABLE ROW LEVEL SECURITY;
-- No client policies — only Edge Function with service role writes to this
```

Add `otp_attempts` table via MCP:
```
Tool: apply_migration
Args:
  name: "otp_attempts"
  query: <SQL above>
```

Deploy function via MCP:
```
Tool: deploy_edge_function
Args:
  name: "otp-guard"
```

Alternatively via CLI: `supabase functions deploy otp-guard --no-verify-jwt`

---

### Part C — Database Webhook Configuration (Supabase Dashboard)

1. Go to Supabase Dashboard → Database → Webhooks → Create
2. Name: `on_product_pending_review`
3. Table: `products`
4. Events: `INSERT`, `UPDATE`
5. Webhook URL: `https://<your-project-ref>.supabase.co/functions/v1/publish-product`
6. HTTP Method: POST
7. Add header: `Authorization: Bearer <SUPABASE_ANON_KEY>`

---

### Part D — React Vendor Hub: Supabase client setup

File: `vendor-hub-web/src/lib/supabaseClient.ts`
```typescript
import { createClient } from "@supabase/supabase-js";
import type { Database } from "../types/database.types";

// Uses pooler URL (port 6543) via Supabase SDK automatically
export const supabase = createClient<Database>(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
);
```

File: `vendor-hub-web/src/lib/imageCompression.ts`
```typescript
import imageCompression from "browser-image-compression";

export async function compressToWebP(file: File): Promise<File> {
  const options = {
    maxSizeMB: 0.3,           // ~300KB max
    maxWidthOrHeight: 1080,
    useWebWorker: true,
    fileType: "image/webp",
    quality: 0.78,
  };
  return imageCompression(file, options);
}
```

---

## Files in Scope

```
blinkit_clone_app/lib/
├── main.dart                                          [MODIFY — call Supabase.initialize()]
├── core/
│   ├── config/env.dart                               [MODIFY — --dart-define keys]
│   ├── network/supabase_client.dart                  [MODIFY — initialize()]
│   └── cache/hive_service.dart                       [MODIFY — full impl]
└── features/home/
    ├── data/supabase_catalog_repository.dart          [CREATE]
    └── presentation/providers/catalog_providers.dart  [MODIFY — swap to Supabase impl]

supabase/
├── functions/publish-product/index.ts                [MODIFY — full impl]
├── functions/otp-guard/index.ts                      [MODIFY — full impl]
└── migrations/<timestamp>_otp_attempts.sql           [CREATE]

vendor-hub-web/src/lib/
├── supabaseClient.ts                                  [MODIFY — full impl]
└── imageCompression.ts                               [MODIFY — full impl]
```

---

## Acceptance Criteria

- [ ] **End-to-end realtime test**: product inserted in Supabase dashboard → appears in Flutter app within 1–2 seconds (no manual refresh)
- [ ] **Publish-product function**: a product with missing name returns `rejected` status; a valid product returns `live`
- [ ] `product_audit_log` has an entry for every status change
- [ ] OTP-guard: 6th OTP request for same phone in 10 minutes returns HTTP 429
- [ ] Flutter app loads categories from Supabase on first launch
- [ ] Hive cache: kill + relaunch app → product list loads from cache before network response
- [ ] `flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy` works
- [ ] No `SUPABASE_SERVICE_ROLE_KEY` present in any client-side file

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS | Run cross-vendor test: Vendor A's JWT cannot read Vendor B's products |
| 2 | Razorpay webhook | N/A this phase — placeholder function only |
| 3 | OTP rate limiting | Test: 6th request in 10 min returns 429 |
| 7 | Service-role key | Confirm: present only in Edge Function env vars, not in any `.env.local` or dart file |
| 9 | Audit log | Verify: every status change has a log row |

---

## Next Phase

→ **Phase 4**: Auth screens + onboarding (`docs/specs/phase-4-auth-onboarding.md`)
