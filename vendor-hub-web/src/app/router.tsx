// src/app/router.tsx
import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "../features/auth/AuthContext";
import { LandingPage } from "../features/landing/LandingPage";
import { AuthCallback } from "../features/auth/AuthCallback";
import { OnboardingPage } from "../features/onboarding/OnboardingPage";
import { DashboardLayout } from "../features/dashboard/DashboardLayout";
import { DashboardOverview } from "../features/dashboard/DashboardOverview";
import { ProductListView } from "../features/catalog/ProductListView";
import { ProfileSettings } from "../features/profile/ProfileSettings";

// Route guard for Onboarding
const OnboardingRoute: React.FC = () => {
  const { user, isOnboardingComplete, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-white">
        <div className="w-10 h-10 border-4 border-[#318616] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  // Not logged in -> go to landing
  if (!user) {
    return <Navigate to="/" replace />;
  }

  // Already completed onboarding -> go to dashboard
  if (isOnboardingComplete) {
    return <Navigate to="/dashboard" replace />;
  }

  return <OnboardingPage />;
};

// Route guard for Dashboard & Catalog
const DashboardRoute: React.FC = () => {
  const { user, isOnboardingComplete, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-white">
        <div className="w-10 h-10 border-4 border-[#318616] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  // Not logged in -> landing
  if (!user) {
    return <Navigate to="/" replace />;
  }

  // Phone not verified or Onboarding not complete -> go to onboarding
  if (!isOnboardingComplete) {
    return <Navigate to="/onboarding" replace />;
  }

  return <DashboardLayout />;
};

export function AppRouter() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Public Landing Page */}
          <Route path="/" element={<LandingPage />} />

          {/* OAuth Callback */}
          <Route path="/auth/callback" element={<AuthCallback />} />

          {/* 2-Step Paper Onboarding */}
          <Route path="/onboarding" element={<OnboardingRoute />} />

          {/* Vendor Portal Dashboard */}
          <Route path="/dashboard" element={<DashboardRoute />}>
            <Route index element={<DashboardOverview />} />
            <Route path="catalog" element={<ProductListView />} />
            <Route path="settings" element={<ProfileSettings />} />
          </Route>

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}

export default AppRouter;
