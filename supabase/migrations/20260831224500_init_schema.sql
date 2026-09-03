-- supabase/migrations/20260831224500_init_schema.sql
-- Blinkit Clone MVP: Full database schema for Phase 2

-- ============================================================
-- 1. EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- 2. TABLES
-- ============================================================

-- VENDORS
CREATE TABLE IF NOT EXISTS vendors (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  business_name TEXT NOT NULL,
  gstin         TEXT,
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'suspended')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- VENDOR_USERS
CREATE TABLE IF NOT EXISTS vendor_users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id    UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  auth_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role         TEXT NOT NULL DEFAULT 'owner'
                 CHECK (role IN ('owner', 'staff')),
  UNIQUE (vendor_id, auth_user_id)
);

-- CATEGORIES (self-referential hierarchy)
CREATE TABLE IF NOT EXISTS categories (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id  UUID REFERENCES categories(id) ON DELETE SET NULL,
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  image_url  TEXT,
  section_type TEXT NOT NULL DEFAULT 'grocery'
                 CHECK (section_type IN ('bestseller', 'grocery', 'snacks', 'more')),
  more_count INT NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS products (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vendor_id     UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  category_id   UUID NOT NULL REFERENCES categories(id),
  name          TEXT NOT NULL,
  unit          TEXT NOT NULL,
  mrp           NUMERIC(10,2) NOT NULL CHECK (mrp > 0),
  selling_price NUMERIC(10,2) NOT NULL CHECK (selling_price > 0),
  stock_qty     INT NOT NULL DEFAULT 100 CHECK (stock_qty >= 0),
  status        TEXT NOT NULL DEFAULT 'live'
                  CHECK (status IN ('draft', 'pending_review', 'live', 'rejected')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- PRODUCT_IMAGES
CREATE TABLE IF NOT EXISTS product_images (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  webp_url   TEXT NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE
);

-- PRODUCT_AUDIT_LOG
CREATE TABLE IF NOT EXISTS product_audit_log (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  action     TEXT NOT NULL CHECK (action IN ('created', 'updated', 'status_changed')),
  diff       JSONB,
  changed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- USERS (consumer profiles)
CREATE TABLE IF NOT EXISTS users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone        TEXT NOT NULL UNIQUE,
  name         TEXT,
  auth_user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ADDRESSES
CREATE TABLE IF NOT EXISTS addresses (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label      TEXT,
  line1      TEXT NOT NULL,
  line2      TEXT,
  city       TEXT NOT NULL,
  pincode    TEXT NOT NULL,
  geo_lat    NUMERIC(9,6),
  geo_lng    NUMERIC(9,6),
  is_default BOOLEAN NOT NULL DEFAULT FALSE
);

-- CARTS
CREATE TABLE IF NOT EXISTS carts (
  id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE
);

-- CART_ITEMS
CREATE TABLE IF NOT EXISTS cart_items (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cart_id    UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  qty        INT NOT NULL DEFAULT 1 CHECK (qty > 0),
  UNIQUE (cart_id, product_id)
);

-- ORDERS
CREATE TABLE IF NOT EXISTS orders (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES users(id),
  address_id   UUID NOT NULL REFERENCES addresses(id),
  status       TEXT NOT NULL DEFAULT 'placed'
                 CHECK (status IN ('placed','confirmed','packed','out_for_delivery','delivered','cancelled')),
  total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount > 0),
  placed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ORDER_ITEMS
CREATE TABLE IF NOT EXISTS order_items (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id          UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES products(id),
  qty               INT NOT NULL CHECK (qty > 0),
  price_at_purchase NUMERIC(10,2) NOT NULL
);

-- PAYMENTS
CREATE TABLE IF NOT EXISTS payments (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id            UUID NOT NULL UNIQUE REFERENCES orders(id),
  razorpay_order_id   TEXT,
  razorpay_payment_id TEXT,
  status              TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','paid','failed','refunded')),
  amount              NUMERIC(10,2) NOT NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- DEVICE_TOKENS
CREATE TABLE IF NOT EXISTS device_tokens (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      TEXT NOT NULL,
  platform   TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, token)
);

-- ============================================================
-- 3. INDEXES (Critical for 20K concurrent queries)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_products_category_status ON products(category_id, status);
CREATE INDEX IF NOT EXISTS idx_products_vendor ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_categories_section_active ON categories(section_type, is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images(product_id);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_users_auth ON vendor_users(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_audit_product ON product_audit_log(product_id);

-- ============================================================
-- 4. TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 5. ENABLE ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE vendors           ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_users      ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE products          ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images    ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE users             ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses         ENABLE ROW LEVEL SECURITY;
ALTER TABLE carts             ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items        ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders            ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens     ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 6. RLS POLICIES
-- ============================================================

-- CATEGORIES
DROP POLICY IF EXISTS "categories_public_read" ON categories;
CREATE POLICY "categories_public_read" ON categories
  FOR SELECT USING (is_active = TRUE);

-- PRODUCTS
DROP POLICY IF EXISTS "products_public_read" ON products;
CREATE POLICY "products_public_read" ON products
  FOR SELECT USING (status = 'live');

DROP POLICY IF EXISTS "products_vendor_own_read" ON products;
CREATE POLICY "products_vendor_own_read" ON products
  FOR SELECT USING (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "products_vendor_own_insert" ON products;
CREATE POLICY "products_vendor_own_insert" ON products
  FOR INSERT WITH CHECK (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "products_vendor_own_update" ON products;
CREATE POLICY "products_vendor_own_update" ON products
  FOR UPDATE USING (
    vendor_id IN (
      SELECT vendor_id FROM vendor_users
      WHERE auth_user_id = auth.uid()
    )
  );

-- PRODUCT_IMAGES
DROP POLICY IF EXISTS "product_images_public_read" ON product_images;
CREATE POLICY "product_images_public_read" ON product_images
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM products p
      WHERE p.id = product_images.product_id AND p.status = 'live'
    )
  );

DROP POLICY IF EXISTS "product_images_vendor_write" ON product_images;
CREATE POLICY "product_images_vendor_write" ON product_images
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM products p
      JOIN vendor_users vu ON vu.vendor_id = p.vendor_id
      WHERE p.id = product_images.product_id
        AND vu.auth_user_id = auth.uid()
    )
  );

-- VENDOR_USERS
DROP POLICY IF EXISTS "vendor_users_read_own" ON vendor_users;
CREATE POLICY "vendor_users_read_own" ON vendor_users
  FOR SELECT USING (auth_user_id = auth.uid());

-- VENDORS
DROP POLICY IF EXISTS "vendors_read_own" ON vendors;
CREATE POLICY "vendors_read_own" ON vendors
  FOR SELECT USING (
    id IN (
      SELECT vendor_id FROM vendor_users WHERE auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "vendors_insert_own" ON vendors;
CREATE POLICY "vendors_insert_own" ON vendors
  FOR INSERT WITH CHECK (TRUE);

-- USERS
DROP POLICY IF EXISTS "users_own" ON users;
CREATE POLICY "users_own" ON users
  FOR ALL USING (auth_user_id = auth.uid());

-- ADDRESSES
DROP POLICY IF EXISTS "addresses_owner" ON addresses;
CREATE POLICY "addresses_owner" ON addresses
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

-- CARTS & CART_ITEMS
DROP POLICY IF EXISTS "carts_owner" ON carts;
CREATE POLICY "carts_owner" ON carts
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

DROP POLICY IF EXISTS "cart_items_owner" ON cart_items;
CREATE POLICY "cart_items_owner" ON cart_items
  FOR ALL USING (
    cart_id IN (
      SELECT c.id FROM carts c
      JOIN users u ON u.id = c.user_id
      WHERE u.auth_user_id = auth.uid()
    )
  );

-- ORDERS & ORDER_ITEMS
DROP POLICY IF EXISTS "orders_owner_read" ON orders;
CREATE POLICY "orders_owner_read" ON orders
  FOR SELECT USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

DROP POLICY IF EXISTS "orders_owner_insert" ON orders;
CREATE POLICY "orders_owner_insert" ON orders
  FOR INSERT WITH CHECK (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

DROP POLICY IF EXISTS "order_items_owner_read" ON order_items;
CREATE POLICY "order_items_owner_read" ON order_items
  FOR SELECT USING (
    order_id IN (
      SELECT o.id FROM orders o
      JOIN users u ON u.id = o.user_id
      WHERE u.auth_user_id = auth.uid()
    )
  );

-- DEVICE_TOKENS
DROP POLICY IF EXISTS "device_tokens_owner" ON device_tokens;
CREATE POLICY "device_tokens_owner" ON device_tokens
  FOR ALL USING (
    user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

-- PRODUCT_AUDIT_LOG
DROP POLICY IF EXISTS "audit_log_vendor_read" ON product_audit_log;
CREATE POLICY "audit_log_vendor_read" ON product_audit_log
  FOR SELECT USING (
    product_id IN (
      SELECT p.id FROM products p
      JOIN vendor_users vu ON vu.vendor_id = p.vendor_id
      WHERE vu.auth_user_id = auth.uid()
    )
  );

-- ============================================================
-- 7. REALTIME PUBLICATION
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'products'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE products;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'categories'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE categories;
  END IF;
END $$;
