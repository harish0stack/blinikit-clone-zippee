import React from "react";

interface HeroSectionProps {
  onSellClick: () => void;
}

export const HeroSection: React.FC<HeroSectionProps> = ({ onSellClick }) => {
  return (
    <section className="relative w-full bg-[#FFD455] overflow-hidden">
      <div
        className="w-full min-h-[600px] lg:min-h-[700px] bg-cover bg-center md:bg-[center_right] bg-no-repeat flex items-center"
        style={{
          backgroundImage: "url('/assets/landing/hero-scooter.webp')",
        }}
      >
        <div className="w-full max-w-[1410px] mx-auto px-6 md:px-12 lg:px-24 py-12 md:py-20">
          <div className="max-w-[520px] flex flex-col justify-center">
            <h1 className="text-4xl sm:text-5xl lg:text-[52px] font-extrabold text-[#1F1F1F] tracking-[-2px] leading-[1.15]">
              Your Products<span className="text-[#318616]">.</span>
              <br />
              Delivered<span className="text-[#318616]">.</span>
            </h1>

            <p className="mt-6 text-lg sm:text-xl lg:text-[24px] text-[#1F1F1F] leading-[1.35] tracking-[-0.2px] font-normal">
              Offer customers the delight of your products and the convenience of doorstep
              deliveries. Sign up and start selling!
            </p>

            <div className="mt-8">
              <button
                type="button"
                onClick={onSellClick}
                className="inline-flex items-center justify-center bg-[#318616] hover:bg-[#286f12] active:scale-[0.98] text-white text-[21px] sm:text-[20px] font-semibold py-3.5 px-5 rounded-lg shadow-md hover:shadow-lg transition-all cursor-pointer"
              >
                Sell on Blinkit
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
