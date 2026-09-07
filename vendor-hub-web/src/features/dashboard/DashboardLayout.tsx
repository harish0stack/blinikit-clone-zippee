// src/features/dashboard/DashboardLayout.tsx
import React, { useState } from "react";
import { Link, Outlet, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

export const DashboardLayout: React.FC = () => {
  const { user, vendor, vendorUser, signOut } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const navItems = [
    {
      label: "Overview",
      path: "/dashboard",
      exact: true,
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
      ),
    },
    {
      label: "Catalog & Products",
      path: "/dashboard/catalog",
      exact: false,
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
      ),
    },
    {
      label: "Business Profile",
      path: "/dashboard/settings",
      exact: false,
      icon: (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
      ),
    },
  ];

  const isActive = (itemPath: string, exact?: boolean) => {
    if (exact) return location.pathname === itemPath;
    return location.pathname.startsWith(itemPath);
  };

  return (
    <div className="min-h-screen flex bg-[#F8F9FA] font-['Lexend',sans-serif]">
      {/* Sidebar - Desktop */}
      <aside className="hidden lg:flex w-[282px] min-w-[282px] bg-[#324B39] text-white flex-col justify-between shrink-0 shadow-lg select-none">
        <div>
          {/* Header with Seller Hub Logo */}
          <div className="py-5 px-6 bg-[#304737] flex items-center justify-between">
            <Link to="/dashboard" className="block">
              <img
                src="/assets/onboarding/vendor-logo-white.svg"
                alt="Blinkit Seller Hub"
                className="w-36 h-auto object-contain"
              />
            </Link>
          </div>

          {/* Business Info Banner */}
          <div className="p-5 border-b border-white/10">
            <div className="text-xs font-semibold uppercase tracking-wider text-white/60 mb-1">
              Store Dashboard
            </div>
            <div className="text-base font-bold text-white truncate">
              {vendor?.business_name || "Blinkit Partner Store"}
            </div>
            <div className="flex items-center gap-1.5 mt-2">
              <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-[#EBFFEF] text-[#318616]">
                <span className="w-1.5 h-1.5 rounded-full bg-[#318616] mr-1.5 animate-pulse"></span>
                Active Partner
              </span>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="p-4 space-y-1.5">
            {navItems.map((item) => {
              const active = isActive(item.path, item.exact);
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                    active
                      ? "bg-[#3D5D46] text-white shadow-sm font-semibold"
                      : "text-white/80 hover:bg-white/10 hover:text-white"
                  }`}
                >
                  <span className={active ? "text-[#FFD455]" : "text-white/70"}>
                    {item.icon}
                  </span>
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>

        {/* User profile info & logout */}
        <div className="p-4 bg-[#304737] border-t border-white/10">
          <div className="flex items-center justify-between mb-3">
            <div className="flex flex-col min-w-0">
              <span className="text-xs font-bold text-white truncate">
                {vendor?.spoc_name || user?.email?.split("@")[0] || "Seller Account"}
              </span>
              <span className="text-[11px] text-white/60 truncate">
                {vendorUser?.phone_number || user?.email}
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={signOut}
            className="flex items-center justify-center gap-2 w-full py-2 px-3 rounded-lg border border-white/30 text-white hover:bg-white/10 text-xs font-medium transition-all cursor-pointer"
          >
            <span>Sign Out</span>
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Mobile / Responsive Top Nav */}
        <header className="bg-white border-b border-gray-200 px-4 py-3.5 flex items-center justify-between lg:hidden sticky top-0 z-30">
          <img
            src="/assets/landing/landing-asset-13.png"
            alt="Blinkit Seller Hub"
            className="h-8 object-contain cursor-pointer"
            onClick={() => navigate("/dashboard")}
          />
          <button
            type="button"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="p-2 rounded-lg text-gray-600 hover:bg-gray-100"
          >
            <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={isMobileMenuOpen ? "M6 18L18 6M6 6l12 12" : "M4 6h16M4 12h16M4 18h16"} />
            </svg>
          </button>
        </header>

        {/* Mobile dropdown menu */}
        {isMobileMenuOpen && (
          <div className="lg:hidden bg-[#324B39] text-white p-4 space-y-2 border-b border-white/10 animate-in slide-in-from-top-2">
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                onClick={() => setIsMobileMenuOpen(false)}
                className={`flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm ${
                  isActive(item.path, item.exact)
                    ? "bg-[#3D5D46] text-white font-semibold"
                    : "text-white/80"
                }`}
              >
                {item.label}
              </Link>
            ))}
            <button
              onClick={signOut}
              className="w-full text-left px-4 py-2.5 text-sm text-red-300 hover:bg-white/10 rounded-lg font-medium"
            >
              Sign Out
            </button>
          </div>
        )}

        {/* Content Body */}
        <main className="flex-1 overflow-y-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
