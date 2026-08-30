# 🟡 Blinkit Clone — Session Context File
### Paste this file at the start of **every new agent session** to give the AI full project context.

---

## Project Identity

| Key | Value |
|---|---|
| **Project Name** | Blinkit Clone MVP |
| **Goal** | Production-grade quick-commerce app: Flutter consumer app + React vendor hub + Supabase cloud backend |
| **Concurrency Target** | 20,000 concurrent users (Tier A) |
| **Monorepo Root** | `/Users/harishkumavat/blinkit-clone/` |
| **Full Spec** | `agent-plan.md` at repo root |
| **Phase Specs** | `docs/specs/phase-N-<name>.md` |

---

## Technology Decisions (LOCKED — do not change without a spec update)

| Layer | Choice | Reason |
|---|---|---|
| Consumer app | **Flutter** (Dart) | Cross-platform iOS + Android |
| State management | **Riverpod** (compile-safe) | No mixing with Provider/Bloc/GetX ever |
| Navigation | **go_router** | Declarative, deep-link ready |
| Local cache | **Hive** | Fast, no-native-code, works offline |
| Backend | **Supabase Cloud (free tier)** | Single cloud project: Auth + PostgREST + Realtime + Storage + Edge Functions. Accessed via **Supabase MCP server** for schema/migrations/functions. NO local Docker setup. |
| DB connection (app) | **Supavisor pooler port 6543** | Cloud pooler URL — survives 20K concurrent. NEVER use port 5432 from app code |
| Edge Functions | **Deno** (Supabase-native, deployed to cloud) | publish-product, otp-guard, razorpay-webhook |
| Vendor hub | **React + Vite + shadcn/ui** | TypeScript, fast iteration |
| Image upload | **browser-image-compression** (npm) | WebP, 150–300KB, before upload |
| Auth — consumers | **Supabase Phone OTP** via `otp-guard` Edge Function | Rate-limited, no direct client call |
| Auth — vendors | **Google OAuth** via Supabase Auth | No password storage |
| Payments | **Razorpay** hosted checkout | PCI-DSS SAQ-A compliant |
| Push notifications | **Firebase Cloud Messaging (FCM)** | Order status updates |
| WAF/DNS | **Cloudflare free tier** | Basic bot/SQLi protection |
| Load testing | **k6** (distributed) | 20–30K VU simulation |

---

## Folder Structure (LOCKED)

```
blinkit-clone/                      <- monorepo root
|- agent-plan.md                    <- master spec (source of truth)
|- docs/
|   |- context/
|   |   `- SESSION_CONTEXT.md      <- THIS FILE — paste to every session
|   `- specs/
|       |- phase-0-project-setup.md
|       |- phase-1-flutter-home-ui.md
|       |- phase-2-database-supabase.md
|       |- phase-3-realtime-catalog-sync.md
|       |- phase-4-auth-onboarding.md
|       |- phase-5-vendor-catalog-upload.md
|       |- phase-6-performance-layer.md
|       |- phase-7-fcm-notifications.md
|       `- phase-8-load-testing.md
|- blinkit_clone_app/               <- Flutter consumer app (created in Phase 0)
|   |- lib/
|   |   |- main.dart
|   |   |- app.dart
|   |   |- core/
|   |   |   |- config/env.dart
|   |   |   |- network/supabase_client.dart
|   |   |   |- cache/hive_service.dart
|   |   |   |- theme/
|   |   |   |- constants/
|   |   |   |- utils/
|   |   |   `- widgets/
|   |   |- features/
|   |   |   |- home/
|   |   |   |- catalog/
|   |   |   |- product_detail/
|   |   |   |- cart/
|   |   |   |- checkout/
|   |   |   |- auth/
|   |   |   |- orders/
|   |   |   `- profile/
|   |   `- routing/app_router.dart
|   `- pubspec.yaml
|- vendor-hub-web/                  <- React vendor/seller hub (created in Phase 0)
|   |- src/
|   |   |- main.tsx
|   |   |- app/
|   |   |- lib/
|   |   |   |- supabaseClient.ts
|   |   |   `- imageCompression.ts
|   |   |- features/
|   |   |   |- auth/
|   |   |   |- catalog/
|   |   |   |- categories/
|   |   |   `- dashboard/
|   |   |- components/
|   |   |- hooks/
|   |   `- types/database.types.ts
|   `- package.json
`- supabase/                        <- Supabase project config (created in Phase 0)
    |- migrations/
    |- functions/
    |   |- publish-product/
    |   |- otp-guard/
    |   `- razorpay-webhook/
    |- seed.sql
    `- config.toml
```

---

## Supabase MCP Tools (how agent talks to cloud Supabase)

> **There is NO local Supabase.** The agent uses the Supabase MCP server to operate the cloud project directly.

| MCP Tool | When to use |
|---|---|
| `apply_migration` | Apply DDL SQL (CREATE TABLE, ALTER, indexes, RLS policies) |
| `execute_sql` | Run any SQL query (seed data, checks, SELECT verifications) |
| `list_tables` | Verify tables exist after migration |
| `list_migrations` | See what migrations have already been applied |
| `deploy_edge_function` | Deploy Deno Edge Functions to cloud |
| `generate_typescript_types` | Generate `database.types.ts` for the vendor hub |
| `get_project_url` | Retrieve the project's REST/Realtime URL |
| `get_publishable_keys` | Retrieve the anon key (safe to expose to client) |
| `get_advisors` | Check for security/performance advisories |

**All migration SQL is also saved as `.sql` files in `supabase/migrations/`** for version control and reproducibility — even though they are applied via MCP, not CLI.

---

## Architectural Rules (NEVER BREAK THESE)

1. **Feature isolation**: a feature folder (`features/home/`) NEVER imports another feature's `data/` or `providers/` — only shared models from `core/`.
2. **Repository pattern**: All data access goes through an interface (e.g., `CatalogRepository`). Demo impl (`DemoCatalogRepository`) -> Supabase impl (`SupabaseCatalogRepository`). Screens never know which impl is active.
3. **No hardcoded data in widgets**: All demo data lives in `assets/demo/catalog.json`, loaded through the repository layer.
4. **Service-role key stays server-side**: NEVER in `--dart-define`, `.env` bundled in a client build, or React env vars committed to git. Only inside Edge Function environment variables.
5. **RLS on every table**: No table may exist without RLS enabled. This is checked after every phase.
6. **Supavisor pooler (port 6543)**: App, vendor hub, and Edge Functions always connect on port 6543. Direct port 5432 only for `supabase db push` / migrations.

---

## Database Schema (ER Summary)

Tables: `vendors`, `vendor_users`, `categories`, `products`, `product_images`, `product_audit_log`, `users`, `addresses`, `carts`, `cart_items`, `orders`, `order_items`, `payments`, `device_tokens`

Key design decisions:
- `products.stock_qty` is a single global column in MVP (no per-dark-store inventory yet)
- `products.status` flow: `draft -> pending_review -> live / rejected`
- `vendor_users` supports multiple staff per vendor from day one
- `PRODUCT_AUDIT_LOG` records every product state change (jsonb diff)
- `payments` table has NO client RLS access — only Edge Function with service role

---

## Phase Status Tracker

| Phase | Name | Status | Branch |
|---|---|---|---|
| 0 | Project Setup & Folder Structure | Not Started | `phase-0-setup` |
| 1 | Flutter Home UI (demo data) | Not Started | `phase-1-flutter-ui` |
| 2 | Database Design & Supabase Config | Not Started | `phase-2-database` |
| 3 | Realtime Catalog Sync + APIs | Not Started | `phase-3-realtime` |
| 4 | Auth Screens + Onboarding | Not Started | `phase-4-auth` |
| 5 | Vendor Catalog Upload Flow | Not Started | `phase-5-vendor-upload` |
| 6 | Performance Layer | Not Started | `phase-6-performance` |
| 7 | FCM Notifications | Not Started | `phase-7-fcm` |
| 8 | Load Testing 20K-30K concurrent | Not Started | `phase-8-load-test` |

---

## How to Start a New Session (COPY-PASTE THIS)

```
Read the file at: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
Then read the phase spec: /Users/harishkumavat/blinkit-clone/docs/specs/phase-N-<name>.md

We are implementing Phase N — <name>.
Current git branch: phase-N-<name>
Do NOT touch files outside the "Files in scope" list in the phase spec.
Do NOT skip steps or add features not listed in the phase spec.
Begin implementation. Ask before making any decision not covered by the spec.
```

---

## Key Reference Documents

| Document | Path |
|---|---|
| Master spec (full detail) | `agent-plan.md` |
| This context file | `docs/context/SESSION_CONTEXT.md` |
| Flutter testing guide | `docs/flutter-testing-guide.md` |
| Pooler config reference | `docs/infra/pooler-config.md` (created in Phase 6) |
| Load test results | `docs/load-test-results.md` (created in Phase 8) |

---

## ⚠️ Critical Reminders for Every Session

1. **NO `supabase start`** — Supabase is cloud-only. Use MCP `apply_migration` and `execute_sql`.
2. **NO service-role key in client code** — Edge Functions only, via Supabase secrets.
3. **Port 6543, not 5432** — all app connections use the Supavisor pooler.
4. **RLS test after every phase** — cross-user/vendor data must be zero-row.
5. **One phase at a time** — do not write code for a future phase.
