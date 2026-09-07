-- supabase/migrations/20260906000000_vendor_hub_auth_onboarding.sql
-- Blinkit Vendor Hub: Auth, 2-Step Onboarding, and Catalog Sync Migration

-- 1. Extend vendor_users table for phone 2FA verification
ALTER TABLE vendor_users
  ADD COLUMN IF NOT EXISTS phone_number TEXT,
  ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Extend vendors table for basic onboarding details
ALTER TABLE vendors
  ADD COLUMN IF NOT EXISTS contact_name TEXT,
  ADD COLUMN IF NOT EXISTS spoc_name TEXT,
  ADD COLUMN IF NOT EXISTS designation TEXT,
  ADD COLUMN IF NOT EXISTS categories JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS onboarding_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (onboarding_status IN ('pending', 'basic_details_complete', 'complete'));

-- 3. High-concurrency performance indexes
CREATE INDEX IF NOT EXISTS idx_vendor_users_auth_user ON vendor_users(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_users_phone ON vendor_users(phone_number);
CREATE INDEX IF NOT EXISTS idx_vendors_onboarding_status ON vendors(onboarding_status);
CREATE INDEX IF NOT EXISTS idx_products_vendor_cat_status ON products(vendor_id, category_id, status);

-- 4. RLS Policy updates for seamless vendor self-onboarding
-- Allow vendor_users insert during Google OAuth first-time login
DROP POLICY IF EXISTS "vendor_users_insert_own" ON vendor_users;
CREATE POLICY "vendor_users_insert_own" ON vendor_users
  FOR INSERT WITH CHECK (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "vendor_users_read_own" ON vendor_users;
CREATE POLICY "vendor_users_read_own" ON vendor_users
  FOR SELECT USING (auth_user_id = auth.uid());

DROP POLICY IF EXISTS "vendor_users_update_own" ON vendor_users;
CREATE POLICY "vendor_users_update_own" ON vendor_users
  FOR UPDATE USING (auth_user_id = auth.uid());

-- Allow vendors update for onboarding status transitions
DROP POLICY IF EXISTS "vendors_insert_own" ON vendors;
CREATE POLICY "vendors_insert_own" ON vendors
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "vendors_read_own" ON vendors;
CREATE POLICY "vendors_read_own" ON vendors
  FOR SELECT USING (
    id IN (
      SELECT vendor_id FROM vendor_users WHERE auth_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "vendors_update_own" ON vendors;
CREATE POLICY "vendors_update_own" ON vendors
  FOR UPDATE USING (
    id IN (
      SELECT vendor_id FROM vendor_users WHERE auth_user_id = auth.uid()
    )
  );

-- 5. High-Concurrency Transactional RPC Functions (Zero RLS Race Conditions)
CREATE OR REPLACE FUNCTION register_vendor_phone_verified(
  p_phone_number TEXT,
  p_business_name TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user_id UUID;
  v_user_email TEXT;
  v_user_name TEXT;
  v_vendor_id UUID;
  v_result JSONB;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT email, raw_user_meta_data->>'full_name'
  INTO v_user_email, v_user_name
  FROM auth.users
  WHERE id = v_user_id;

  SELECT vendor_id INTO v_vendor_id
  FROM vendor_users
  WHERE auth_user_id = v_user_id
  LIMIT 1;

  IF v_vendor_id IS NOT NULL THEN
    UPDATE vendor_users
    SET phone_number = p_phone_number,
        phone_verified = TRUE
    WHERE auth_user_id = v_user_id;

    IF p_business_name IS NOT NULL AND p_business_name <> '' THEN
      UPDATE vendors
      SET business_name = p_business_name,
          spoc_name = COALESCE(spoc_name, v_user_name),
          contact_name = COALESCE(contact_name, v_user_name)
      WHERE id = v_vendor_id;
    END IF;
  ELSE
    INSERT INTO vendors (
      business_name,
      contact_name,
      spoc_name,
      onboarding_status
    )
    VALUES (
      COALESCE(NULLIF(p_business_name, ''), NULLIF(v_user_name, ''), 'My Blinkit Store'),
      v_user_name,
      v_user_name,
      'pending'
    )
    RETURNING id INTO v_vendor_id;

    INSERT INTO vendor_users (
      vendor_id,
      auth_user_id,
      role,
      phone_number,
      phone_verified
    )
    VALUES (
      v_vendor_id,
      v_user_id,
      'owner',
      p_phone_number,
      TRUE
    )
    ON CONFLICT (vendor_id, auth_user_id)
    DO UPDATE SET
      phone_number = EXCLUDED.phone_number,
      phone_verified = TRUE;
  END IF;

  SELECT jsonb_build_object(
    'vendor_id', v_vendor_id,
    'phone_number', p_phone_number,
    'phone_verified', true
  ) INTO v_result;

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION register_vendor_phone_verified(TEXT, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION save_vendor_basic_details(
  p_business_name TEXT,
  p_spoc_name TEXT,
  p_designation TEXT,
  p_categories JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user_id UUID;
  v_vendor_id UUID;
  v_result JSONB;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT vendor_id INTO v_vendor_id
  FROM vendor_users
  WHERE auth_user_id = v_user_id
  LIMIT 1;

  IF v_vendor_id IS NULL THEN
    INSERT INTO vendors (
      business_name,
      contact_name,
      spoc_name,
      designation,
      categories,
      onboarding_status
    )
    VALUES (
      COALESCE(NULLIF(p_business_name, ''), 'My Blinkit Store'),
      p_spoc_name,
      p_spoc_name,
      p_designation,
      COALESCE(p_categories, '[]'::jsonb),
      'basic_details_complete'
    )
    RETURNING id INTO v_vendor_id;

    INSERT INTO vendor_users (
      vendor_id,
      auth_user_id,
      role,
      phone_verified
    )
    VALUES (
      v_vendor_id,
      v_user_id,
      'owner',
      TRUE
    )
    ON CONFLICT (vendor_id, auth_user_id) DO NOTHING;
  ELSE
    UPDATE vendors
    SET business_name = COALESCE(NULLIF(p_business_name, ''), business_name),
        spoc_name = p_spoc_name,
        contact_name = p_spoc_name,
        designation = p_designation,
        categories = COALESCE(p_categories, categories),
        onboarding_status = 'basic_details_complete'
    WHERE id = v_vendor_id;
  END IF;

  RETURN jsonb_build_object(
    'vendor_id', v_vendor_id,
    'status', 'basic_details_complete'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION save_vendor_basic_details(TEXT, TEXT, TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION complete_vendor_onboarding()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user_id UUID;
  v_vendor_id UUID;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT vendor_id INTO v_vendor_id
  FROM vendor_users
  WHERE auth_user_id = v_user_id
  LIMIT 1;

  IF v_vendor_id IS NOT NULL THEN
    UPDATE vendors
    SET onboarding_status = 'complete'
    WHERE id = v_vendor_id;
  END IF;

  RETURN jsonb_build_object('success', true, 'vendor_id', v_vendor_id);
END;
$$;

GRANT EXECUTE ON FUNCTION complete_vendor_onboarding() TO authenticated;

