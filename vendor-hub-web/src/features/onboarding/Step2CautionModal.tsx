// src/features/onboarding/Step2CautionModal.tsx
import React from "react";

interface Step2CautionModalProps {
  isOpen: boolean;
  onConfirm: () => void;
  isLoading?: boolean;
}

export const Step2CautionModal: React.FC<Step2CautionModalProps> = ({
  isOpen,
  onConfirm,
  isLoading = false,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="relative w-full max-w-[735px] bg-white rounded-[24px] shadow-2xl p-8 md:p-10 flex flex-col items-center justify-center animate-in zoom-in-95 duration-200">
        {/* Warning Icon */}
        <div className="flex justify-center mb-3">
          <img
            src="/assets/onboarding/caution-triangle.svg"
            alt="Caution Warning"
            className="w-20 h-20 object-contain"
          />
        </div>

        {/* Title */}
        <h2 className="text-xl sm:text-2xl font-semibold text-black text-center tracking-tight mb-2">
          Be cautious of third parties claiming to assist!
        </h2>

        {/* Subtext */}
        <p className="text-center text-[15px] sm:text-[17px] leading-relaxed text-[#4F4F4F] max-w-[580px] mb-6">
          Some agencies and individuals are falsely claiming to assist with Seller Hub onboarding.
          Please note that the only official channels to contact Blinkit are:
        </p>

        {/* Channels Row */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 w-full max-w-[540px] mb-6">
          {/* Channel 1 Card */}
          <div className="bg-[#F4F6FB] rounded-[20px] p-5 flex flex-col items-center justify-center text-center">
            <span className="text-[13px] sm:text-[15px] font-semibold text-[#6A6F81] mb-2 uppercase tracking-wide">
              CHANNEL 1
            </span>
            <div className="my-2 h-[89px] flex items-center justify-center">
              <img
                src="/assets/onboarding/channel-seller-sessions.svg"
                alt="Seller sessions"
                className="w-[117px] h-[89px] object-contain"
              />
            </div>
            <h4 className="text-[15px] font-semibold text-[#1F1F1F] mt-2 mb-1">
              Seller sessions
            </h4>
            <p className="text-xs font-medium text-[#6A6F81] leading-tight">
              This can be booked through the Seller Hub dashboard
            </p>
          </div>

          {/* Channel 2 Card */}
          <div className="bg-[#F4F6FB] rounded-[20px] p-5 flex flex-col items-center justify-center text-center">
            <span className="text-[13px] sm:text-[15px] font-semibold text-[#6A6F81] mb-2 uppercase tracking-wide">
              CHANNEL 2
            </span>
            <div className="my-2 h-[89px] flex items-center justify-center">
              <img
                src="/assets/onboarding/channel-ticket-support.svg"
                alt="Ticket Support"
                className="w-[117px] h-[89px] object-contain"
              />
            </div>
            <h4 className="text-[15px] font-semibold text-[#1F1F1F] mt-2 mb-1">
              Ticket Support
            </h4>
            <p className="text-xs font-medium text-[#6A6F81] leading-tight">
              Available only via Help & Support
            </p>
          </div>
        </div>

        {/* Advisory footer */}
        <p className="text-center text-[14px] sm:text-[16px] text-[#4F4F4F] max-w-[520px] mb-6">
          For a secure and seamless onboarding experience, we strongly advise using these official channels only.
        </p>

        {/* Action Button */}
        <button
          type="button"
          onClick={onConfirm}
          disabled={isLoading}
          className="bg-[#0D121C] hover:bg-black text-white text-[15px] font-medium py-2.5 px-10 rounded-md shadow-md active:scale-95 transition-all cursor-pointer"
        >
          {isLoading ? "Completing..." : "Got it"}
        </button>
      </div>
    </div>
  );
};
