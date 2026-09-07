// src/lib/supabaseClient.ts
import { createClient } from "@supabase/supabase-js";
import type { Database } from "../types/database.types";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn(
    "Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY in environment variables. " +
      "Make sure .env is configured with your Supabase credentials."
  );
}

export const supabase = createClient<Database>(
  supabaseUrl || "",
  supabaseAnonKey || ""
);
