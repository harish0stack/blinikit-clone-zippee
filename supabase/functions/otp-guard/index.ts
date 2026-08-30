// supabase/functions/otp-guard/index.ts
// STUB: full implementation in Phase 4
// Deployed to Supabase Cloud — do NOT run locally
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (_req: Request) => {
  return new Response(JSON.stringify({ ok: true, phase: 0 }), {
    headers: { "Content-Type": "application/json" },
  });
});
