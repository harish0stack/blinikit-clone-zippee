// src/features/auth/googleSignIn.ts
import { supabase } from "../../lib/supabaseClient";

export async function signInWithGoogle() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: "google",
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
      queryParams: {
        access_type: "offline",
        prompt: "consent",
      },
    },
  });

  if (error) {
    console.error("Google Sign-In Error:", error);
    throw error;
  }

  return data;
}

export async function signOutVendor() {
  const { error } = await supabase.auth.signOut();
  if (error) {
    console.error("Sign Out Error:", error);
    throw error;
  }
}
