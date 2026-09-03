-- supabase/migrations/20260902040000_dev_payments.sql
-- High-Performance FamPay-via-FamGateway Payment Aggregator Workaround Table

-- 1. Create table if not exists
CREATE TABLE IF NOT EXISTS dev_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id TEXT UNIQUE NOT NULL,              -- FamGateway tracking order_id
  user_id UUID,                               -- Linked user if authenticated, null for anonymous test
  cart_order_id TEXT,                         -- Reference to local or DB order
  requested_amount NUMERIC(10,2) NOT NULL,    -- Fixed order amount e.g. 2.00
  payable_amount NUMERIC(10,2) NOT NULL,      -- Uniqueness amount e.g. 2.04
  upi_vpa TEXT NOT NULL,                      -- FamPay receiver @fam VPA
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'paid', 'failed', 'expired')),
  utr TEXT,                                   -- Bank reference number (e.g. FMPIB6517388097)
  sender_name TEXT,                           -- Payer name from email (e.g. Manisha)
  provider TEXT NOT NULL DEFAULT 'fampay_dev',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  paid_at TIMESTAMPTZ
);

-- 2. Index for hot-path webhook updates & real-time lookups (<1ms index scan)
CREATE UNIQUE INDEX IF NOT EXISTS dev_payments_order_id_idx ON dev_payments(order_id);

-- 3. Enable RLS
ALTER TABLE dev_payments ENABLE ROW LEVEL SECURITY;

-- 4. Idempotent RLS Policies: Allow select, insert, update for seamless client & webhook operations
DROP POLICY IF EXISTS "Allow public select on dev_payments for order status" ON dev_payments;
CREATE POLICY "Allow public select on dev_payments for order status"
  ON dev_payments FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Allow public insert on dev_payments" ON dev_payments;
CREATE POLICY "Allow public insert on dev_payments"
  ON dev_payments FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public update on dev_payments" ON dev_payments;
CREATE POLICY "Allow public update on dev_payments"
  ON dev_payments FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Allow service role full access on dev_payments" ON dev_payments;
CREATE POLICY "Allow service role full access on dev_payments"
  ON dev_payments FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- 5. Idempotent Realtime Publication (Prevents 42710 error if already added)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'dev_payments'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE dev_payments;
  END IF;
END $$;

-- 6. Set test product price to ₹2.00 for frictionless real-money testing
UPDATE products
SET selling_price = 2.00, mrp = 5.00
WHERE name ILIKE '%amul taaza%' OR name ILIKE '%coriander%';

-- Update Diet Coke to ₹2.00 for instant live testing
UPDATE products
SET selling_price = 2.00, mrp = 5.00
WHERE id = '0e0cf484-0c0d-5315-b257-efea78c73f23';
