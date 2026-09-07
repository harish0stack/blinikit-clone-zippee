// src/features/onboarding/Step1BasicDetails.tsx
import React, { useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { supabase } from "../../lib/supabaseClient";

interface Step1BasicDetailsProps {
  onComplete: () => void;
}

const CATEGORIES_LIST = [
  { id: "dairy-bread-eggs", name: "Dairy, Bread & Eggs" },
  { id: "chips-and-namkeen", name: "Chips & Namkeen" },
  { id: "fresh-vegetables-fruits", name: "Fresh Vegetables & Fruits" },
  { id: "pet-food-supplies", name: "Pet Food & Supplies" },
  { id: "energy-drinks-juices", name: "Energy Drinks & Juices" },
  { id: "biscuits-cookies", name: "Biscuits & Cookies" },
];

export const Step1BasicDetails: React.FC<Step1BasicDetailsProps> = ({ onComplete }) => {
  const { user, vendor, vendorUser, refreshProfile } = useAuth();

  const [shopName, setShopName] = useState(vendor?.business_name || "");
  const [spocName, setSpocName] = useState(
    vendor?.spoc_name || vendor?.contact_name || user?.user_metadata?.full_name || ""
  );
  const [designation, setDesignation] = useState(vendor?.designation || "Owner");
  const [selectedCategories, setSelectedCategories] = useState<string[]>(
    Array.isArray(vendor?.categories) ? (vendor?.categories as string[]) : ["dairy-bread-eggs"]
  );
  const [searchTerm, setSearchTerm] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const toggleCategory = (catId: string) => {
    if (selectedCategories.includes(catId)) {
      if (selectedCategories.length === 1) return;
      setSelectedCategories(selectedCategories.filter((c) => c !== catId));
    } else {
      if (selectedCategories.length >= 10) return;
      setSelectedCategories([...selectedCategories, catId]);
    }
  };

  const filteredCategories = CATEGORIES_LIST.filter((cat) =>
    cat.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!spocName.trim()) {
      setError("Please enter the SPOC Name.");
      return;
    }
    if (selectedCategories.length === 0) {
      setError("Please select at least one product category.");
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      if (!user) throw new Error("No authenticated user session.");

      // Use transactional SECURITY DEFINER RPC to save details
      // Ensures zero RLS failures, zero concurrency race conditions, and atomic updates
      const { error: rpcError } = await (supabase.rpc as any)(
        "save_vendor_basic_details",
        {
          p_business_name: shopName.trim() || "My Blinkit Store",
          p_spoc_name: spocName.trim(),
          p_designation: designation,
          p_categories: selectedCategories,
        }
      );

      if (rpcError) throw rpcError;

      await refreshProfile();
      onComplete();
    } catch (err: any) {
      console.error("Save Basic Details Error:", err);
      setError(err?.message || "Failed to save details. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex-1 flex flex-col md:flex-row min-h-screen bg-white font-['Lexend',sans-serif]">
      {/* Step Indicator Left Sub-panel */}
      <div className="w-full md:w-[280px] lg:w-[320px] bg-[#F9FAFB] border-r border-[#E8E8E8] shrink-0">
        <div className="p-6 md:p-7 border-b border-[#E8E8E8]/50">
          <h3 className="text-xl font-bold text-black tracking-tight leading-snug">
            Complete these steps for easy onboarding
          </h3>
        </div>

        <div className="flex flex-col">
          {/* Step 1: Basic details (Active) */}
          <div className="h-20 flex items-center px-6 gap-3 relative bg-white [box-shadow:#1C1C1C0D_-15px_7px_18px] border-l-4 border-l-[#324B39]">
            <img
              src="/assets/onboarding/step-basic-active.svg"
              alt="Step 1 active"
              className="w-5 h-5 object-contain shrink-0"
            />
            <span className="text-[15px] leading-[150%] font-semibold text-[#1F1F1F]">
              Basic details
            </span>
          </div>

          {/* Step 2: Verify and submit (Pending) */}
          <div className="h-20 flex items-center px-6 gap-3 bg-[#F9FAFB] opacity-80">
            <img
              src="/assets/onboarding/step-verify-inactive.svg"
              alt="Step 2 inactive"
              className="w-5 h-5 object-contain shrink-0"
            />
            <span className="text-[15px] leading-[150%] font-semibold text-[#9C9C9C]">
              Verify and submit
            </span>
          </div>
        </div>
      </div>

      {/* Main Form Content Area */}
      <div className="flex-1 flex flex-col justify-between relative bg-white">
        <div className="px-6 md:px-14 py-6 md:py-8">
          {/* Business Details Header */}
          <div className="mb-4">
            <h2 className="text-xl md:text-2xl font-bold text-black">
              Business details
            </h2>
            <p className="text-sm md:text-base text-[#6C737F] mt-0.5">
              Enter the details about your products and sales
            </p>
          </div>

          <div className="h-px w-full bg-[#F1F1F1] mb-6" />

          {error && (
            <div className="mb-6 p-3.5 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6 max-w-2xl">
            {/* Shop Name */}
            <div>
              <label className="block text-[14px] font-semibold text-[#1F1F1F] mb-1.5">
                Store / Shop Name *
              </label>
              <input
                type="text"
                value={shopName}
                onChange={(e) => setShopName(e.target.value)}
                placeholder="e.g. Fresh Daily Store"
                className="w-full h-11 px-3.5 rounded-lg border border-[#828282] text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-1 focus:ring-[#318616]"
              />
            </div>

            {/* Category & sales details */}
            <div>
              <h3 className="text-[19px] leading-[150%] font-semibold text-[#1F1F1F] mb-1">
                Category & sales details
              </h3>
              <p className="text-[14px] leading-[150%] font-semibold text-[#1F1F1F] mb-3">
                Add top categories in which you sell your products (Upto 10) *
              </p>

              {/* Search & Category Chips */}
              <div className="p-3.5 rounded-lg border border-[#828282] bg-white space-y-3">
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Search your product & category"
                  className="w-full h-9 px-2 text-sm text-[#1F1F1F] placeholder:text-[#00000040] focus:outline-none border-b border-gray-100"
                />

                <div className="flex flex-wrap gap-2 pt-1">
                  {filteredCategories.map((cat) => {
                    const isSelected = selectedCategories.includes(cat.id);
                    return (
                      <button
                        key={cat.id}
                        type="button"
                        onClick={() => toggleCategory(cat.id)}
                        className={`px-3.5 py-1.5 rounded-md text-xs sm:text-sm font-medium transition-all flex items-center gap-1.5 cursor-pointer ${
                          isSelected
                            ? "bg-[#324B39] text-white shadow-xs"
                            : "bg-gray-100 hover:bg-gray-200 text-[#1F1F1F]"
                        }`}
                      >
                        <span>{cat.name}</span>
                        {isSelected ? <span>✓</span> : <span>+</span>}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>

            {/* Login & Contact details */}
            <div className="pt-2">
              <h3 className="text-[19px] leading-[150%] font-semibold text-[#1F1F1F] mb-4">
                Login & Contact details
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* SPOC Name */}
                <div>
                  <label className="block text-[13px] font-semibold text-[#5E6368] mb-1">
                    SPOC Name *
                  </label>
                  <input
                    type="text"
                    value={spocName}
                    onChange={(e) => setSpocName(e.target.value)}
                    placeholder="Full Name"
                    required
                    className="w-full h-12 px-3.5 rounded-lg border border-[#828282] text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] font-medium"
                  />
                </div>

                {/* Login e-mail ID */}
                <div>
                  <label className="block text-[12px] font-semibold text-[#5E6368] mb-1">
                    Login e-mail ID *
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type="text"
                      value={user?.email || "seller@blinkit.com"}
                      disabled
                      className="w-full h-12 px-3.5 pr-10 rounded-lg bg-[#0000000A] border border-[#828282] text-sm text-black font-medium cursor-not-allowed"
                    />
                    <img
                      src="/assets/onboarding/verified-lock.svg"
                      alt="Verified"
                      className="absolute right-3 w-5 h-5 object-contain"
                    />
                  </div>
                </div>

                {/* Designation */}
                <div>
                  <label className="block text-[13px] font-semibold text-[#5E6368] mb-1">
                    Designation*
                  </label>
                  <div className="relative flex items-center">
                    <select
                      value={designation}
                      onChange={(e) => setDesignation(e.target.value)}
                      className="w-full h-12 px-3.5 pr-10 rounded-lg border border-[#828282] text-sm text-[#1F1F1F] font-medium appearance-none focus:outline-none focus:border-[#318616] bg-white cursor-pointer"
                    >
                      <option value="Owner">Owner</option>
                      <option value="Founder / Director">Founder / Director</option>
                      <option value="Store Manager">Store Manager</option>
                      <option value="Operations Lead">Operations Lead</option>
                      <option value="Sales Executive">Sales Executive</option>
                    </select>
                    <img
                      src="/assets/onboarding/dropdown-chevron.svg"
                      alt="Chevron"
                      className="absolute right-3.5 w-3 h-3 object-contain pointer-events-none"
                    />
                  </div>
                </div>

                {/* Login Number */}
                <div>
                  <label className="block text-[12px] font-semibold text-[#5E6368] mb-1">
                    Login Number *
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type="text"
                      value={vendorUser?.phone_number || ""}
                      disabled
                      className="w-full h-12 px-3.5 pr-10 rounded-lg bg-[#0000000A] border border-[#828282] text-sm text-black font-medium cursor-not-allowed"
                    />
                    <img
                      src="/assets/onboarding/verified-lock.svg"
                      alt="Verified"
                      className="absolute right-3 w-5 h-5 object-contain"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Bottom Bar: Save & continue */}
            <div className="pt-8 pb-4">
              <button
                type="submit"
                disabled={isLoading}
                className="h-10 px-8 rounded-md bg-[#0D121C] hover:bg-black active:scale-95 text-white text-sm font-medium shadow-md transition-all cursor-pointer flex items-center justify-center"
              >
                {isLoading ? "Saving..." : "Save & continue"}
              </button>
            </div>
          </form>
        </div>

        {/* Bottom Fixed Shadow Line */}
        <div className="w-full border-t border-[#1C1C1C0F] [box-shadow:#1C1C1C0F_0px_-4px_6px] bg-white h-2 shrink-0" />
      </div>
    </div>
  );
};
