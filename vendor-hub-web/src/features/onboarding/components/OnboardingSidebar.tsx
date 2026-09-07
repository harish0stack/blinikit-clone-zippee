// src/features/onboarding/components/OnboardingSidebar.tsx
import React from "react";
import { useAuth } from "../../auth/AuthContext";

export const OnboardingSidebar: React.FC = () => {
  const { user, vendorUser, signOut } = useAuth();

  return (
    <div className="w-full lg:w-[282px] max-w-full lg:max-w-[282px] min-w-full lg:min-w-[282px] shrink-0 bg-[#324B39] font-['Lexend',sans-serif] flex flex-col justify-between min-h-screen select-none">
      <div>
        {/* Header with White Seller Hub Logo */}
        <div className="py-5 px-6 bg-[#304737]">
          <img
            src="/assets/onboarding/vendor-logo-white.svg"
            alt="Blinkit Seller Hub"
            className="w-42 max-w-full h-[67px] object-contain aspect-[231/92]"
          />
        </div>

        {/* Info & Frauds Pill */}
        <div className="pt-4.5 pb-3 px-6 my-2">
          <div className="text-[21px] leading-[150%] font-bold text-white">
            Grow your business with Blinkit
          </div>
          <div className="text-[15px] mt-2 leading-[150%] text-white">
            Offer customers the delight of your products and the convenience of doorstep deliveries.
          </div>

          <div className="items-center flex pr-2 pl-3 rounded-full gap-2 py-2 bg-[#3D5D46] my-5">
            <img
              src="/assets/onboarding/shield-alert.svg"
              alt="Shield alert"
              className="w-4 h-4 object-contain shrink-0"
            />
            <div className="text-[11px] leading-[150%] font-medium text-[#FFF5F6]">
              Cautious of frauds claiming to assist!
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Illustration & Login Details */}
      <div className="w-full">
        <div className="flex px-6 justify-center">
          <img
            src="/assets/onboarding/onboarding-scooter.svg"
            alt="Delivery Illustration"
            className="w-56 max-w-full h-[147px] object-contain aspect-[154/101]"
          />
        </div>

        <div className="flex flex-col p-5 gap-3 bg-[#304737] border-t border-[#FFFFFF1A]">
          <div className="flex flex-col w-full gap-4">
            <div className="flex flex-col gap-2">
              <div className="items-center flex justify-between">
                <div className="inline-block font-bold text-white text-sm">
                  Login details
                </div>
              </div>
              <div className="flex flex-col overflow-hidden gap-1">
                <div className="font-medium text-[#FFFFFF80] text-xs truncate">
                  {user?.email || "seller@blinkit.com"}
                </div>
                <div className="font-medium text-[#FFFFFF80] text-xs truncate">
                  {vendorUser?.phone_number || ""}
                </div>
              </div>
            </div>

            {/* Log out button */}
            <div className="items-center flex justify-center min-h-10">
              <button
                type="button"
                onClick={signOut}
                className="items-center flex w-full justify-center py-[6.4px] px-[12.8px] rounded-lg gap-2 border border-white hover:bg-white/10 active:scale-[0.98] transition-all cursor-pointer"
              >
                <span className="text-[14px] text-center leading-[150%] font-medium text-white">
                  Log out
                </span>
                <svg
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.75"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="text-[#D6D5D4]"
                >
                  <path d="M19.875 6.27a2.225 2.225 0 0 1 1.125 1.948v7.284c0 .809 -.443 1.555 -1.158 1.948l-6.75 4.27a2.269 2.269 0 0 1 -2.184 0l-6.75 -4.27a2.225 2.225 0 0 1 -1.158 -1.948v-7.285c0 -.809 .443 -1.554 1.158 -1.947l6.75 -3.98a2.33 2.33 0 0 1 2.25 0l6.75 3.98h-.033z M12 12m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
