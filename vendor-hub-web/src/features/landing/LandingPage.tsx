import React, { useState } from "react";
import { Navbar } from "./components/Navbar";
import { HeroSection } from "./components/HeroSection";
import { FeaturesSection } from "./components/FeaturesSection";
import { FooterSection } from "./components/FooterSection";
import { AuthModal, type AuthMode } from "./components/AuthModal";

export const LandingPage: React.FC = () => {
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalMode, setAuthModalMode] = useState<AuthMode>("signup");

  const openLoginModal = () => {
    setAuthModalMode("login");
    setIsAuthModalOpen(true);
  };

  const openSignupModal = () => {
    setAuthModalMode("signup");
    setIsAuthModalOpen(true);
  };

  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
  };

  return (
    <div className="min-h-screen flex flex-col bg-white font-['Lexend',sans-serif] selection:bg-[#FFD455] selection:text-[#1F1F1F]">
      {/* Navbar with Yellow Blinkit Theme */}
      <Navbar onOpenLogin={openLoginModal} onOpenSignup={openSignupModal} />

      {/* Main Content */}
      <main className="flex-1 w-full">
        {/* Hero Section */}
        <HeroSection onSellClick={openSignupModal} />

        {/* Why Blinkit is every seller's top choice Section */}
        <FeaturesSection />
      </main>

      {/* Comprehensive Footer Section */}
      <FooterSection />

      {/* Signup & Login Auth Modal */}
      <AuthModal
        isOpen={isAuthModalOpen}
        initialMode={authModalMode}
        onClose={closeAuthModal}
      />
    </div>
  );
};

export default LandingPage;
