// src/features/auth/AuthContext.tsx
import React, { createContext, useContext, useEffect, useState, useCallback } from "react";
import type { User, Session } from "@supabase/supabase-js";
import { supabase } from "../../lib/supabaseClient";
import type { Database } from "../../types/database.types";

type Vendor = Database["public"]["Tables"]["vendors"]["Row"];
type VendorUser = Database["public"]["Tables"]["vendor_users"]["Row"];

interface AuthContextType {
  user: User | null;
  session: Session | null;
  vendor: Vendor | null;
  vendorUser: VendorUser | null;
  isLoading: boolean;
  isPhoneVerified: boolean;
  isOnboardingComplete: boolean;
  refreshProfile: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [vendor, setVendor] = useState<Vendor | null>(null);
  const [vendorUser, setVendorUser] = useState<VendorUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const fetchVendorData = useCallback(async (userId: string) => {
    try {
      // 1. Fetch vendor_user
      const { data: vUserData, error: vuError } = await supabase
        .from("vendor_users")
        .select("*")
        .eq("auth_user_id", userId)
        .maybeSingle();

      if (vuError) {
        console.error("Error fetching vendor user:", vuError);
        return;
      }

      if (vUserData) {
        setVendorUser(vUserData);

        // 2. Fetch vendor details
        const { data: vData, error: vError } = await supabase
          .from("vendors")
          .select("*")
          .eq("id", vUserData.vendor_id)
          .maybeSingle();

        if (vError) {
          console.error("Error fetching vendor:", vError);
        } else {
          setVendor(vData);
        }
      } else {
        setVendorUser(null);
        setVendor(null);
      }
    } catch (err) {
      console.error("Error in fetchVendorData:", err);
    }
  }, []);

  const refreshProfile = useCallback(async () => {
    if (user) {
      await fetchVendorData(user.id);
    }
  }, [user, fetchVendorData]);

  useEffect(() => {
    // Initial session check
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        fetchVendorData(session.user.id).finally(() => setIsLoading(false));
      } else {
        setIsLoading(false);
      }
    });

    // Listen to Auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        if (session?.user) {
          await fetchVendorData(session.user.id);
        } else {
          setVendor(null);
          setVendorUser(null);
        }
        setIsLoading(false);
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, [fetchVendorData]);

  const signOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setSession(null);
    setVendor(null);
    setVendorUser(null);
  };

  const isPhoneVerified = Boolean(vendorUser?.phone_verified && vendorUser?.phone_number);
  const isOnboardingComplete = vendor?.onboarding_status === "complete";

  return (
    <AuthContext.Provider
      value={{
        user,
        session,
        vendor,
        vendorUser,
        isLoading,
        isPhoneVerified,
        isOnboardingComplete,
        refreshProfile,
        signOut,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
