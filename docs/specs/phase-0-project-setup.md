# Phase 0 — Project Setup & Folder Structure

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-0-project-setup.md
> Branch: phase-0-setup
> ```

---

## Goal

Lock the monorepo skeleton. Every future session has a predictable file tree to write into. No business logic in this phase — only scaffolding, config files, and CI/CD plumbing.

---

## What We Are Building

A three-part monorepo under `/Users/harishkumavat/blinkit-clone/`:

| App | Tool | Purpose |
|---|---|---|
| `blinkit_clone_app/` | Flutter 3.x | Consumer iOS/Android app |
| `vendor-hub-web/` | Vite + React 18 + TypeScript | Vendor/seller hub web app |
| `supabase/` | Version-controlled SQL + Edge Function stubs | Migrations are applied to **Supabase Cloud** via MCP — no local Postgres |

> **Cloud-first**: The Supabase project already exists (or will be created) on https://supabase.com (free tier). The agent has access to it via the **Supabase MCP server**. No `supabase start`, no local Docker.

---

## How We Will Implement It (Step by Step)

### Step 1 — Git initialization
```bash
cd /Users/harishkumavat/blinkit-clone
git init
git checkout -b phase-0-setup
```

### Step 2 — Flutter consumer app scaffold
```bash
flutter create blinkit_clone_app \
  --org com.blinkitclone \
  --project-name blinkit_clone_app \
  --platforms android,ios
```

Then immediately create the full folder tree under `lib/` with empty placeholder files (comments only — no logic yet):
```
lib/main.dart
lib/app.dart
lib/core/config/env.dart
lib/core/network/supabase_client.dart
lib/core/cache/hive_service.dart
lib/core/cache/cache_keys.dart
lib/core/theme/app_theme.dart
lib/core/constants/app_constants.dart
lib/core/utils/logger.dart
lib/core/widgets/  (empty dir with .gitkeep)
lib/features/home/data/catalog_repository.dart        ← abstract interface only
lib/features/home/data/demo_catalog_repository.dart   ← stub impl
lib/features/home/models/category.dart
lib/features/home/models/product.dart
lib/features/home/presentation/screens/.gitkeep
lib/features/home/presentation/widgets/.gitkeep
lib/features/home/presentation/providers/.gitkeep
lib/features/catalog/  (same sub-structure, all empty)
lib/features/product_detail/  (same)
lib/features/cart/  (same)
lib/features/checkout/  (same)
lib/features/auth/  (same)
lib/features/orders/  (same)
lib/features/profile/  (same)
lib/routing/app_router.dart   ← stub go_router with one placeholder route
assets/demo/catalog.json      ← empty JSON array []
```

### Step 3 — pubspec.yaml dependencies (lock exact versions)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  supabase_flutter: ^2.5.0
  hive_flutter: ^1.1.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10+1
  connectivity_plus: ^6.0.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

### Step 4 — Vendor hub scaffold
```bash
cd /Users/harishkumavat/blinkit-clone
npm create vite@latest vendor-hub-web -- --template react-ts
cd vendor-hub-web
npm install
```

Add dependencies:
```bash
npm install @supabase/supabase-js react-router-dom @tanstack/react-query \
  browser-image-compression lucide-react
npm install -D @types/node tailwindcss postcss autoprefixer
npx shadcn-ui@latest init
```

Create folder tree under `src/`:
```
src/main.tsx
src/App.tsx
src/app/router.tsx
src/lib/supabaseClient.ts
src/lib/imageCompression.ts
src/features/auth/
src/features/catalog/
src/features/categories/
src/features/dashboard/
src/components/
src/hooks/
src/types/database.types.ts   ← placeholder, regenerated via `supabase gen types`
```

### Step 5 — Supabase folder structure (cloud-only, no supabase init)

> The Supabase **cloud** project is accessed via the Supabase MCP server. There is no `supabase init` or `supabase start` in this workflow.

Create the following folder/file structure manually:
```
supabase/
|- migrations/          <- empty dir (all .sql files here, applied via MCP in Phase 2)
|- functions/
|   |- publish-product/index.ts    <- stub: responds with {ok: true}
|   |- otp-guard/index.ts          <- stub: responds with {ok: true}
|   `- razorpay-webhook/index.ts   <- stub: responds with {ok: true}
`- seed.sql                        <- empty file with comment header only
```

Stub Edge Function content (same pattern for all three):
```typescript
// supabase/functions/publish-product/index.ts
// STUB: full implementation in Phase 3
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
serve(async (_req: Request) => {
  return new Response(JSON.stringify({ ok: true, phase: 0 }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

`supabase/seed.sql` content:
```sql
-- Seed data for development
-- Applied via MCP execute_sql tool in Phase 2
-- DO NOT run on production
```

> **How MCP will use these files in Phase 2**: The agent reads `supabase/migrations/xxx.sql` and calls `apply_migration` with the SQL content to apply it to the cloud project.

### Step 6 — Environment variable templates

**`blinkit_clone_app/.env.example`:**
```
# Copy to .env.local — never commit .env.local
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**`vendor-hub-web/.env.example`:**
```
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 7 — Root .gitignore
```
# Flutter
blinkit_clone_app/.dart_tool/
blinkit_clone_app/build/
blinkit_clone_app/.env.local
blinkit_clone_app/android/local.properties
blinkit_clone_app/ios/Pods/

# React
vendor-hub-web/node_modules/
vendor-hub-web/dist/
vendor-hub-web/.env.local

# Supabase
supabase/.branches/
supabase/.temp/

# General
.DS_Store
*.log
```

### Step 8 — Verify everything runs
```bash
# Flutter
cd blinkit_clone_app && flutter pub get && flutter run   # should show blank scaffold

# Vendor hub
cd ../vendor-hub-web && npm run dev                      # should show Vite placeholder

# Verify Supabase cloud connection via MCP
# (agent runs: MCP list_projects -> confirms cloud project is accessible)
# (agent runs: MCP get_project_url -> logs the project URL for .env.example update)
```

> There is NO `supabase start`. Supabase connectivity is verified in Phase 2 when the first migration is applied via `apply_migration`.

---

## Files in Scope (ONLY these may be touched this phase)

```
/Users/harishkumavat/blinkit-clone/
├── .gitignore
├── blinkit_clone_app/          ← scaffold + pubspec only
├── vendor-hub-web/             ← scaffold + package.json only
└── supabase/                   ← supabase init output + stub functions
```

**Out of scope:** no business logic, no UI widgets, no migrations, no Supabase cloud project creation.

---

## Data Contract (establish now, freeze for Phase 1)

```dart
// lib/features/home/models/category.dart
abstract class Category {
  String get id;
  String get name;
  String get imageUrl;
  String? get parentId;
}

// lib/features/home/models/product.dart
abstract class Product {
  String get id;
  String get name;
  String get unit;
  String get imageUrl;
  String get categoryId;
  double get mrp;
  double get sellingPrice;
  bool get inStock;
}
```

These become the Postgres schema in Phase 2. Do not add or remove fields.

---

## Acceptance Criteria (all must be true before moving to Phase 1)

- [ ] `flutter run` on `blinkit_clone_app` shows a blank scaffold (no red screen)
- [ ] `npm run dev` on `vendor-hub-web` shows the Vite placeholder (no build error)
- [ ] MCP `list_projects` returns the Supabase cloud project (confirms MCP connectivity)
- [ ] `blinkit_clone_app/lib/` folder tree matches the structure above exactly
- [ ] `vendor-hub-web/src/` folder tree matches above exactly
- [ ] All stub Edge Function files exist under `supabase/functions/`
- [ ] `supabase/migrations/` directory exists (empty — first migration is Phase 2)
- [ ] `.env.example` files exist in both app roots (actual secrets NOT committed)
- [ ] `.gitignore` is in place and `flutter pub get` works cleanly
- [ ] No Supabase API calls in any file yet (only stubs/comments)
- [ ] Security checklist item #7 verified: service-role key not present in any file

---

## Security Checklist (Phase 0 applicable items)

| # | Control | Status |
|---|---|---|
| 4 | Cloudflare DNS/WAF: document the plan (actual Cloudflare setup is manual, not automated) | Note in README |
| 7 | Service-role key: confirm it is not present in any committed file | Verify before commit |

---

## Next Phase

→ **Phase 1**: Flutter Home UI screens with demo data (`docs/specs/phase-1-flutter-home-ui.md`)
