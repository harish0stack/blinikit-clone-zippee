// src/features/auth/AuthCallback.tsx
import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "../../lib/supabaseClient";

export const AuthCallback: React.FC = () => {
  const navigate = useNavigate();

  useEffect(() => {
    let isMounted = true;

    async function handleAuth() {
      try {
        const { data: { session }, error } = await supabase.auth.getSession();

        if (error) {
          console.error("Auth Callback Error:", error);
          navigate("/");
          return;
        }

        if (session?.user) {
          const userId = session.user.id;

          // Check if vendor_users record exists
          const { data: vUser } = await supabase
            .from("vendor_users")
            .select("*, vendors(*)")
            .eq("auth_user_id", userId)
            .maybeSingle();

          if (!isMounted) return;

          if (!vUser || !vUser.phone_verified) {
            navigate("/onboarding/verify-phone");
          } else {
            const vendor = vUser.vendors as { onboarding_status?: string } | null;
            if (vendor?.onboarding_status === "complete") {
              navigate("/dashboard");
            } else {
              navigate("/onboarding");
            }
          }
        } else {
          // If no session yet, listen to state change
          const { data: { subscription } } = supabase.auth.onAuthStateChange(
            async (_event, session) => {
              if (session?.user && isMounted) {
                navigate("/onboarding/verify-phone");
              }
            }
          );
          return () => subscription.unsubscribe();
        }
      } catch (err) {
        console.error("Error in AuthCallback:", err);
        navigate("/");
      }
    }

    handleAuth();

    return () => {
      isMounted = false;
    };
  }, [navigate]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-[#F9FAFB] font-['Lexend',sans-serif]">
      <div className="flex flex-col items-center p-8 bg-white rounded-2xl shadow-sm border border-gray-100 max-w-sm w-full mx-4 text-center">
        <div className="w-12 h-12 border-4 border-[#318616] border-t-transparent rounded-full animate-spin mb-4" />
        <h2 className="text-xl font-bold text-[#1F1F1F]">Signing you in...</h2>
        <p className="text-sm text-gray-500 mt-1">Connecting your Blinkit Seller Hub account</p>
      </div>
    </div>
  );
};
