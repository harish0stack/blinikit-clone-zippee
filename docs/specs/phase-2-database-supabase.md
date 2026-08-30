# Phase 2 — Database Design & Supabase Configuration

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-2-database-supabase.md
> Branch: phase-2-database
> Phase 0 and Phase 1 are COMPLETE.
> ```

---

## Goal

Create the full Postgres schema on Supabase cloud with all tables, indexes, RLS policies, Realtime publication, and Storage bucket. No application code changes — this phase is 100% SQL migrations + Supabase dashboard configuration.

---

## Prerequisites (verify before starting)

- [ ] Supabase cloud project exists at https://supabase.com (free tier)
- [ ] Agent has MCP access: call `list_projects` to confirm the project appears
- [ ] Call `get_project_url` and `get_publishable_keys` — update `.env.example` files with real values
- [ ] **Never** use `supabase link`, `supabase db reset`, or `supabase start` — all schema ops go through MCP

---

## How We Will Implement It

### Step 1 — Create migration file

Create the file `supabase/migrations/<timestamp>_init_schema.sql` (use current UTC timestamp, format: `YYYYMMDDHHMMSS`). Write ALL the SQL below into this single file.

The agent will then call the MCP `apply_migration` tool with:
```
name: "init_schema"
query: <full SQL content below>
```

> The `.sql` file is kept in git for version control. The MCP call is what actually applies it to the cloud DB.

### Step 2 — Extensions

```sql
-- supabase/migrations/<timestamp>_init_schema.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- for text search on products.name
```

> **Schema Design for Future Growth**
> Every table is designed with evolution in mind:
> - `TEXT` fields with `CHECK` constraints (status enums) can be extended by adding new values in a later migration — no column type change needed.
> - `JSONB` columns (`diff` in audit log) allow schemaless extension without ALTER TABLE.
> - `vendor_users.role` TEXT enum can gain new roles (e.g., `'viewer'`, `'accountant'`) in a migration.
> - `products.stock_qty` will migrate to a separate `inventory` table (per dark store) in Tier B — the column stays but becomes a fallback default. No vendor schema breaks.
> - All tables use `UUID` PKs (not serial integers) — safe for future sharding/federation.
> - `addresses.geo_lat/geo_lng` are nullable now — a PostGIS `geometry(Point, 4326)` column can be added later for spatial queries without removing these columns.

### Step 3 — Tables (create in dependency order)

```sql
-- ============================================================
-- VENDORS
-- ============================================================
CREATE TABLE vendors (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_name TEXT NOT NULL,
  gstin         TEXT,
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'suspended')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- VENDOR_USERS
-- ============================================================
CREATE TABLE vendor_users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id    UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role         TEXT NOT NULL DEFAULT 'owner'
                 CHECK (role IN ('owner', 'staff')),
  UNIQUE (vendor_id, auth_user_id)
);

-- ============================================================
-- CATEGORIES (self-referential for parent/child)
-- ============================================================
CREATE TABLE categories (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id  UUID REFERENCES categories(id) ON DELETE SET NULL,
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  image_url  TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE TABLE products (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id     UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  category_id   UUID NOT NULL REFERENCES categories(id),
  name          TEXT NOT NULL,
  unit          TEXT NOT NULL,                    -- e.g. "500g", "1L", "Pack of 6"
  mrp           NUMERIC(10,2) NOT NULL CHECK (mrp > 0),
  selling_price NUMERIC(10,2) NOT NULL CHECK (selling_price > 0),
  stock_qty     INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  status        TEXT NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft', 'pending_review', 'live', 'rejected')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PRODUCT_IMAGES
-- ============================================================
CREATE TABLE product_images (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  webp_url   TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================================
-- PRODUCT_AUDIT_LOG
-- ============================================================
CREATE TABLE product_audit_log (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  action     TEXT NOT NULL CHECK (action IN ('created', 'updated', 'status_changed')),
  diff       JSONB,
  changed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- USERS (consumer profiles, linked to auth.users)
-- ============================================================
CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone        TEXT NOT NULL UNIQUE,
  name         TEXT,
  auth_user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ADDRESSES
-- ============================================================
CREATE TABLE addresses (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label     TEXT,                               -- "Home", "Work", etc.
  line1     TEXT NOT NULL,
  line2     TEXT,
  city      TEXT NOT NULL,
  pincode   TEXT NOT NULL,
  geo_lat   NUMERIC(9,6),
  geo_lng   NUMERIC(9,6),
  is_default BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================================
-- CARTS (one cart per user)
-- ============================================================
CREATE TABLE carts (
  id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- CART_ITEMS
-- ============================================================
CREATE TABLE cart_items (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id    UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  qty        INT NOT NULL DEFAULT 1 CHECK (qty > 0),
  UNIQUE (cart_id, product_id)
);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE TABLE orders (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES users(id),
  address_id   UUID NOT NULL REFERENCES addresses(id),
  status       TEXT NOT NULL DEFAULT 'placed'
                 CHECK (status IN ('placed','confirmed','packed','out_for_delivery','delivered','cancelled')),
  total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount > 0),
  placed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ORDER_ITEMS
-- ============================================================
CREATE TABLE order_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id          UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES products(id),
  qty               INT NOT NULL CHECK (qty > 0),
  price_at_purchase NUMERIC(10,2) NOT NULL
);

-- ============================================================
-- PAYMENTS
-- ============================================================
CREATE TABLE payments (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id            UUID NOT NULL UNIQUE REFERENCES orders(id),
  razorpay_order_id   TEXT,
  razorpay_payment_id TEXT,
  status              TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','paid','failed','refunded')),
  amount              NUMERIC(10,2) NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DEVICE_TOKENS (for FCM — Phase 7)
-- ============================================================
CREATE TABLE device_tokens (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT NOT NULL,
  platform   TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, token)
);
```

### Step 4 — Indexes (critical for performance at 20K users)

```sql
-- Product queries (most frequent)
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_products_vendor ON products(vendor_id);
CREATE INDEX idx_products_status ON products(status);

-- Full-text search on product name (pg_trgm)
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

-- Cart lookups
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);

-- Order history
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- Address lookups
CREATE INDEX idx_addresses_user ON addresses(user_id);

-- Vendor user lookups
CREATE INDEX idx_vendor_users_auth ON vendor_users(auth_user_id);

-- Audit log
CREATE INDEX idx_audit_product ON product_audit_log(product_id);
```

### Step 5 — Triggers

```sql
-- Auto-update products.updated_at on any row change
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

### Step 6 — Enable RLS on every table

```sql
ALTER TABLE vendors          ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_users     ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories       ENABLE ROW LEVEL SECURITY;
ALTER TABLE products         ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images   ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE users            ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses        ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts            ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders           ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items      ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments         ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens    ENABLE ROW LEVEL SECURITY;
```

### Step 7 — RLS Policies

```sql
-- ============================================================
-- CATEGORIES: public read (active only), admin write via service role
-- ============================================================
CREATE POLICY "categories_public_read" ON categories
  FOR SELECT USING (is_active = TRUE);

-- ============================================================
-- PRODUCTS: public read (live only)
-- ============================================================
CREATE POLICY "products_public_read" ON products
  FOR SELECT USING (status = 'live');

-- PRODUCTS: vendor can read/write their own
CREATE POLICY "products_vendor_own_read" ON products
  FOR SELECT USING (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

CREATE POLICY "products_vendor_own_insert" ON products
  FOR INSERT WITH CHECK (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

CREATE POLICY "products_vendor_own_update" ON products
  FOR UPDATE USING (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

-- ============================================================
-- PRODUCT_IMAGES: same vendor scoping as products
-- ============================================================
CREATE POLICY "product_images_public_read" ON product_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = product_images.product_id AND p.status = 'live'
    )
  );

CREATE POLICY "product_images_vendor_write" ON product_images
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM products p
      JOIN vendor_users vu ON vu.vendor_id = p.vendor_id
      WHERE p.id = product_images.product_id
        AND vu.auth_user_id = auth.uid()
    )
  );

-- ============================================================
-- VENDOR_USERS: read own only
-- ============================================================
CREATE POLICY "vendor_users_read_own" ON vendor_users
  FOR SELECT USING (auth_user_id = auth.uid());

-- ============================================================
-- VENDORS: read own only (via vendor_users join)
-- ============================================================
CREATE POLICY "vendors_read_own" ON vendors
  FOR SELECT USING (
    id IN (
      SELECT vendor_id FROM vendor_users WHERE auth_user_id = auth.uid()
    )
  );

CREATE POLICY "vendors_insert_own" ON vendors
  FOR INSERT WITH CHECK (TRUE);   -- any authenticated user can create a vendor (onboarding)

-- ============================================================
-- USERS: read/write own profile
-- ============================================================
CREATE POLICY "users_own" ON users
  FOR ALL USING (auth_user_id = auth.uid());

-- ============================================================
-- ADDRESSES: owner only
-- ============================================================
CREATE POLICY "addresses_owner" ON addresses
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

-- ============================================================
-- CARTS + CART_ITEMS: owner only
-- ============================================================
CREATE POLICY "carts_owner" ON carts
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "cart_items_owner" ON cart_items
  FOR ALL USING (
    cart_id IN (
      SELECT c.id FROM carts c
      JOIN users u ON u.id = c.user_id
      WHERE u.auth_user_id = auth.uid()
    )
  );

-- ============================================================
-- ORDERS + ORDER_ITEMS: owner read, insert only (no update from client)
-- ============================================================
CREATE POLICY "orders_owner_read" ON orders
  FOR SELECT USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "orders_owner_insert" ON orders
  FOR INSERT WITH CHECK (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "order_items_owner_read" ON order_items
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN users u ON u.id = o.user_id
      WHERE u.auth_user_id = auth.uid()
    )
  );

-- ============================================================
-- PAYMENTS: NO client access — Edge Function only (service role)
-- ============================================================
-- No policies created = deny all by default when RLS is enabled

-- ============================================================
-- DEVICE_TOKENS: owner only
-- ============================================================
CREATE POLICY "device_tokens_owner" ON device_tokens
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

-- ============================================================
-- PRODUCT_AUDIT_LOG: vendor read own, no client writes (Edge Function writes)
-- ============================================================
CREATE POLICY "audit_log_vendor_read" ON product_audit_log
  FOR SELECT USING (
    product_id IN (
      SELECT p.id FROM products p
      JOIN vendor_users vu ON vu.vendor_id = p.vendor_id
      WHERE vu.auth_user_id = auth.uid()
    )
  );
```

### Step 8 — Realtime publication

```sql
-- Enable Realtime on products and categories only
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
```

> Note: Realtime respects RLS — consumers only receive rows they can SELECT (i.e., `status = 'live'`).

### Step 9 — Storage bucket (Supabase Dashboard — manual step)

1. Go to Supabase Dashboard → Storage → New Bucket
2. Name: `product-images`
3. Public: **Yes** (public read for product images in consumer app)
4. Add Storage Policy:
   ```sql
   -- INSERT: vendor can only upload to their own vendor_id path
   CREATE POLICY "vendor_upload_own_path" ON storage.objects
   FOR INSERT WITH CHECK (
     bucket_id = 'product-images'
     AND (storage.foldername(name))[1] IN (
       SELECT vu.vendor_id::TEXT FROM vendor_users vu
       WHERE vu.auth_user_id = auth.uid()
     )
   );
   ```

### Step 10 — Apply migration via MCP

```
# Agent uses MCP apply_migration tool:
Tool: apply_migration
Args:
  name: "init_schema"
  query: <full SQL from steps 2–9 above>

# Then verify with MCP list_tables:
Tool: list_tables
-> Should show all 14 tables

# Verify RLS is enabled on all tables:
Tool: execute_sql
Args:
  query: "SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
-> All rows must show rowsecurity = true

# Verify indexes:
Tool: execute_sql
Args:
  query: "SELECT indexname, tablename FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename;"
```

**If the migration has an error:** Fix the SQL, then call `apply_migration` with just the corrected DDL (Supabase applies it as an additive migration). Do NOT re-apply the entire `init_schema` — create a new migration file `<timestamp>_fix_<description>.sql` for the correction.

### Step 11 — Generate TypeScript types for vendor hub

```
# Agent uses MCP generate_typescript_types tool:
Tool: generate_typescript_types
-> Returns TypeScript type definitions

# Agent writes the output to:
vendor-hub-web/src/types/database.types.ts
```

> Regenerate this file whenever the schema changes in a later phase.

---

## Files in Scope

```
supabase/
├── migrations/<timestamp>_init_schema.sql    [CREATE — all SQL above]
└── seed.sql                                  [MODIFY — add demo categories + 1 test vendor]

vendor-hub-web/
└── src/types/database.types.ts              [REGENERATE via supabase gen types]
```

**Out of scope:** No Flutter code, no React UI, no Edge Functions (those are Phase 3).

---

## Seed Data (cloud dev data)

Seed data is applied via **MCP `execute_sql`** (NOT `supabase db reset`). `supabase/seed.sql` contains the seed SQL for version control but is executed through MCP.

Seed content to apply:
- 1 test vendor (status `approved`)
- 1 vendor_user linked to a test auth user
- 6 root categories + 12 subcategories (slugs must match the Flutter `assets/demo/catalog.json` category IDs from Phase 1)
- 5 sample products with status `live` (to verify RLS and Realtime without creating a vendor account)

Apply seed:
```
Tool: execute_sql
Args:
  query: <contents of supabase/seed.sql>
```

> Seed is for development verification only. It is safe to re-run (use `INSERT ... ON CONFLICT DO NOTHING` for idempotency).

---

## Acceptance Criteria

- [ ] MCP `apply_migration` completes with zero errors for `init_schema`
- [ ] MCP `list_tables` returns all 14 expected tables
- [ ] MCP `execute_sql` RLS check: all 14 tables show `rowsecurity = true`
- [ ] All indexes are present (verified via `execute_sql` on `pg_indexes`)
- [ ] **RLS test** (critical): Log in as Vendor A → try to read Vendor B's products → must return 0 rows
- [ ] **RLS test** (critical): Log in as Consumer → can read `products` where `status = 'live'`, cannot read `payments`
- [ ] Realtime publication includes `products` and `categories` tables (verify via `execute_sql`: `SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';`)
- [ ] MCP `generate_typescript_types` produces valid output written to `database.types.ts`
- [ ] Storage bucket `product-images` exists and is publicly readable (set up via Supabase Dashboard)

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS on every table | Verified via SQL query above |
| 6 | Storage path-scoped to vendor_id | Policy written and verified |
| 7 | Service-role key not in any client file | Confirm |
| 9 | Audit log table exists | Verified by schema |

---

## Next Phase

→ **Phase 3**: Realtime catalog sync + Edge Functions + APIs (`docs/specs/phase-3-realtime-catalog-sync.md`)
