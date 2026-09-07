// src/features/dashboard/DashboardOverview.tsx
import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { supabase } from "../../lib/supabaseClient";

interface StatItem {
  title: string;
  count: number;
  label: string;
  change?: string;
  color: string;
}

export const DashboardOverview: React.FC = () => {
  const { vendor } = useAuth();
  const [stats, setStats] = useState({
    totalProducts: 0,
    activeProducts: 0,
    lowStock: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!vendor?.id) return;

    const fetchStats = async () => {
      try {
        setLoading(true);
        const { data: products, error } = await supabase
          .from("products")
          .select("id, status, stock_qty")
          .eq("vendor_id", vendor.id);

        if (error) throw error;

        const total = products?.length || 0;
        const active = products?.filter((p) => p.status === "live").length || 0;
        const low = products?.filter((p) => (p.stock_qty ?? 0) <= 5).length || 0;

        setStats({
          totalProducts: total,
          activeProducts: active,
          lowStock: low,
        });
      } catch (err) {
        console.error("Error fetching overview stats:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, [vendor?.id]);

  const categoriesList: string[] = Array.isArray(vendor?.categories)
    ? (vendor?.categories as string[])
    : [];

  const statCards: StatItem[] = [
    {
      title: "Total Listed Products",
      count: stats.totalProducts,
      label: "items registered in your store",
      color: "border-l-4 border-l-[#318616]",
    },
    {
      title: "Active on App",
      count: stats.activeProducts,
      label: "live for 10-minute delivery",
      color: "border-l-4 border-l-[#FFD455]",
    },
    {
      title: "Low / Out of Stock",
      count: stats.lowStock,
      label: "items needing stock replenishment",
      color: "border-l-4 border-l-red-400",
    },
  ];

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto space-y-8">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-[#324B39] to-[#25382B] rounded-2xl p-6 md:p-8 text-white shadow-sm flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-[#FFD455] text-black tracking-wide">
              PARTNER PORTAL
            </span>
          </div>
          <h1 className="text-2xl md:text-3xl font-bold">
            Welcome back, {vendor?.business_name || "Seller"}!
          </h1>
          <p className="text-white/80 text-sm md:text-base mt-1 max-w-xl">
            Manage your store catalog, check real-time stock levels, and prepare your items for ultra-fast customer delivery.
          </p>
        </div>

        <Link
          to="/dashboard/catalog"
          className="bg-[#FFD455] hover:bg-[#F3C846] text-black font-semibold px-5 py-3 rounded-xl shadow-md flex items-center gap-2 transition-all active:scale-95 shrink-0"
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          <span>Manage Catalog</span>
        </Link>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-5">
        {statCards.map((card, i) => (
          <div
            key={i}
            className={`bg-white rounded-2xl p-6 shadow-sm border border-gray-100 ${card.color} flex flex-col justify-between`}
          >
            <div>
              <div className="text-sm font-medium text-gray-500">{card.title}</div>
              <div className="text-3xl font-bold text-gray-900 mt-2">
                {loading ? "..." : card.count}
              </div>
            </div>
            <div className="text-xs text-gray-400 mt-4">{card.label}</div>
          </div>
        ))}
      </div>

      {/* Quick Launch & Category Summary */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Categories Section */}
        <div className="lg:col-span-2 bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <h3 className="text-lg font-bold text-gray-900 mb-2">
            Selected Seller Categories
          </h3>
          <p className="text-sm text-gray-500 mb-4">
            Categories your store is verified to supply to Blinkit Dark Stores.
          </p>

          <div className="flex flex-wrap gap-2">
            {categoriesList.length > 0 ? (
              categoriesList.map((cat: string, idx: number) => (
                <span
                  key={idx}
                  className="px-3.5 py-1.5 bg-[#EBFFEF] text-[#318616] text-sm font-medium rounded-full border border-[#D5F5DC]"
                >
                  {cat}
                </span>
              ))
            ) : (
              <span className="text-sm text-gray-400 italic">
                No categories configured yet. Visit Business Profile to add categories.
              </span>
            )}
          </div>
        </div>

        {/* Support & Training Box */}
        <div className="bg-[#F4F6FB] rounded-2xl p-6 border border-[#E2E6F0] flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <img
                src="/assets/onboarding/shield-alert.svg"
                alt="Support"
                className="w-5 h-5 object-contain"
              />
              <span className="text-xs font-bold uppercase text-[#4F4F4F]">
                Partner Support
              </span>
            </div>
            <h4 className="text-base font-bold text-gray-900">
              Need help with packaging or dispatch?
            </h4>
            <p className="text-xs text-gray-600 mt-1 leading-relaxed">
              Book a 1-on-1 Seller session or reach out to ticket support anytime through official channels.
            </p>
          </div>

          <div className="mt-4 pt-3 border-t border-gray-200">
            <span className="text-xs font-semibold text-[#318616]">
              Official SLA: Response within 2 hours
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
