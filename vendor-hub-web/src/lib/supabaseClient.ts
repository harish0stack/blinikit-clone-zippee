// src/lib/supabaseClient.ts
// STUB: initialized in Phase 3
// Uses Supavisor pooler-compatible REST API (port 6543 for DB connections — handled server-side)
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    "Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY in environment variables. " +
      "Copy vendor-hub-web/.env.example to .env.local and fill in the values."
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
