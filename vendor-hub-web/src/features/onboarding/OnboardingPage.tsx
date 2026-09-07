// src/features/onboarding/OnboardingPage.tsx
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { OnboardingSidebar } from "./components/OnboardingSidebar";
import { Step1BasicDetails } from "./Step1BasicDetails";
import { Step2CautionModal } from "./Step2CautionModal";
import { supabase } from "../../lib/supabaseClient";

export const OnboardingPage: React.FC = () => {
  const navigate = useNavigate();
  const { refreshProfile } = useAuth();

  const [isCautionModalOpen, setIsCautionModalOpen] = useState(false);
  const [isCompleting, setIsCompleting] = useState(false);

  const handleStep1Complete = () => {
    setIsCautionModalOpen(true);
  };

  const handleCautionConfirm = async () => {
    setIsCompleting(true);
    try {
      await (supabase.rpc as any)("complete_vendor_onboarding");
      await refreshProfile();
      navigate("/dashboard");
    } catch (err) {
      console.error("Complete Onboarding Error:", err);
      navigate("/dashboard");
    } finally {
      setIsCompleting(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col lg:flex-row bg-white font-['Lexend',sans-serif]">
      {/* Left Dark Green Onboarding Sidebar */}
      <OnboardingSidebar />

      {/* Right Onboarding Content */}
      <Step1BasicDetails onComplete={handleStep1Complete} />

      {/* Step 2 Caution Modal (Paper 40U-0) */}
      <Step2CautionModal
        isOpen={isCautionModalOpen}
        onConfirm={handleCautionConfirm}
        isLoading={isCompleting}
      />
    </div>
  );
};

export default OnboardingPage;
