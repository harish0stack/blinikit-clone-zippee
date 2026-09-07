// src/features/profile/ProfileSettings.tsx
import React, { useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { supabase } from "../../lib/supabaseClient";

export const ProfileSettings: React.FC = () => {
  const { user, vendor, vendorUser, refreshProfile } = useAuth();

  const [businessName, setBusinessName] = useState(vendor?.business_name || "");
  const [spocName, setSpocName] = useState(vendor?.spoc_name || "");
  const [designation, setDesignation] = useState(vendor?.designation || "");
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<{ text: string; type: "success" | "error" } | null>(null);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!vendor?.id) return;

    setIsSaving(true);
    setMessage(null);

    try {
      const { error } = await supabase
        .from("vendors")
        .update({
          business_name: businessName.trim(),
          spoc_name: spocName.trim(),
          designation: designation.trim(),
        })
        .eq("id", vendor.id);

      if (error) throw error;

      await refreshProfile();
      setMessage({ text: "Profile details updated successfully!", type: "success" });
    } catch (err: any) {
      console.error("Error updating profile:", err);
      setMessage({ text: err.message || "Failed to update profile", type: "error" });
    } finally {
      setIsSaving(false);
    }
  };

  const categoriesList: string[] = Array.isArray(vendor?.categories)
    ? (vendor?.categories as string[])
    : [];

  return (
    <div className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Business & Account Settings</h1>
        <p className="text-sm text-gray-500 mt-1">
          Review your verified partner credentials and update your single point of contact (SPOC) details.
        </p>
      </div>

      {message && (
        <div
          className={`p-4 rounded-xl text-sm font-medium ${
            message.type === "success"
              ? "bg-[#EBFFEF] text-[#318616] border border-[#D5F5DC]"
              : "bg-red-50 text-red-700 border border-red-200"
          }`}
        >
          {message.text}
        </div>
      )}

      <form onSubmit={handleSave} className="bg-white rounded-2xl p-6 md:p-8 shadow-sm border border-gray-100 space-y-6">
        {/* Verification Badges */}
        <div className="p-4 bg-[#F8F9FA] rounded-xl border border-gray-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="text-xs font-semibold uppercase text-gray-500 tracking-wider">
              Verification Status
            </div>
            <div className="text-sm font-bold text-gray-800 flex items-center gap-2">
              <span>Google Account & Mobile Number Verified</span>
              <span className="w-2 h-2 rounded-full bg-[#318616]"></span>
            </div>
          </div>
          <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-[#EBFFEF] text-[#318616] self-start sm:self-auto">
            100% Compliant
          </span>
        </div>

        {/* Read-only Auth Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-xs font-bold text-gray-700 uppercase mb-1.5">
              Registered Email (Google)
            </label>
            <div className="flex items-center bg-[#F4F6FB] border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm text-gray-600">
              <span className="truncate">{user?.email || "N/A"}</span>
              <span className="ml-auto text-xs font-semibold text-[#318616]">Verified</span>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-gray-700 uppercase mb-1.5">
              Verified Phone Number
            </label>
            <div className="flex items-center bg-[#F4F6FB] border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm text-gray-600">
              <span className="truncate">{vendorUser?.phone_number || "N/A"}</span>
              <span className="ml-auto text-xs font-semibold text-[#318616]">Verified</span>
            </div>
          </div>
        </div>

        {/* Editable Fields */}
        <div className="space-y-4 pt-2">
          <div>
            <label className="block text-sm font-semibold text-gray-900 mb-1.5">
              Business / Brand Name *
            </label>
            <input
              type="text"
              required
              value={businessName}
              onChange={(e) => setBusinessName(e.target.value)}
              className="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#324B39] focus:border-transparent transition-all"
              placeholder="e.g. Fresh Dairy Farms LLP"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1.5">
                SPOC Name *
              </label>
              <input
                type="text"
                required
                value={spocName}
                onChange={(e) => setSpocName(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#324B39] focus:border-transparent transition-all"
                placeholder="e.g. Rahul Sharma"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-900 mb-1.5">
                Designation *
              </label>
              <input
                type="text"
                required
                value={designation}
                onChange={(e) => setDesignation(e.target.value)}
                className="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#324B39] focus:border-transparent transition-all"
                placeholder="e.g. Managing Partner / Director"
              />
            </div>
          </div>
        </div>

        {/* Categories preview */}
        <div>
          <label className="block text-sm font-semibold text-gray-900 mb-2">
            Active Store Categories
          </label>
          <div className="flex flex-wrap gap-2">
            {categoriesList.length > 0 ? (
              categoriesList.map((c: string, i: number) => (
                <span
                  key={i}
                  className="px-3 py-1 bg-gray-100 text-gray-700 text-xs font-medium rounded-full"
                >
                  {c}
                </span>
              ))
            ) : (
              <span className="text-xs text-gray-400">No categories selected</span>
            )}
          </div>
        </div>

        {/* Submit */}
        <div className="pt-4 flex justify-end">
          <button
            type="submit"
            disabled={isSaving}
            className="bg-[#324B39] hover:bg-[#283C2E] text-white font-semibold px-6 py-2.5 rounded-xl text-sm shadow-md transition-all active:scale-95 disabled:opacity-50 cursor-pointer"
          >
            {isSaving ? "Saving..." : "Save Changes"}
          </button>
        </div>
      </form>
    </div>
  );
};
