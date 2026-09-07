import React, { useState } from "react";

interface NavbarProps {
  onOpenLogin: () => void;
  onOpenSignup: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onOpenLogin, onOpenSignup }) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const navLinks = [
    { label: "Home", href: "#" },
    { label: "About", href: "#" },
    { label: "Careers", href: "#" },
    { label: "Partner", href: "#" },
    { label: "Blog", href: "#" },
  ];

  return (
    
<header className="sticky top-0 z-50 w-full bg-[#FFD455] shadow-xs border-b border-[#E6BE40]/50 transition-shadow">

      <div className="w-full max-w-[1410px] mx-auto h-[51px] px-4 md:px-10 flex items-center justify-between">
        {/* Brand Logo */}
        <div className="flex items-center">
          <a href="/" className="inline-block transition-transform hover:scale-105 active:scale-95">
            <img
              src="/assets/landing/logo.webp"
              alt="seller hub by blinkit"
              className="w-[100px] h-[39.73px] object-contain shrink-0"
            />
          </a>
        </div>

        {/* Desktop Navigation Links */}
        <nav className="hidden md:flex items-center">
          {navLinks.map((link) => (
            <a
              key={link.label}
              href={link.href}
              className="text-[15px] leading-[150%] tracking-[-0.1px] font-medium text-[#1F1F1F] mx-4 hover:opacity-75 transition-opacity"
            >
              {link.label}
            </a>
          ))}
        </nav>

        {/* Desktop Action Buttons */}
        <div className="hidden md:flex items-center gap-3">
          <button
            type="button"
            onClick={onOpenLogin}
            className="text-[14px] leading-[150%] font-medium text-[#0D121C] px-3 py-1.5 rounded-md hover:bg-black/5 active:scale-95 transition-all cursor-pointer"
          >
            Login
          </button>
          <button
            type="button"
            onClick={onOpenSignup}
            className="text-[14px] leading-[150%] font-medium text-white bg-[#318616] hover:bg-[#286f12] active:scale-95 py-2 px-5 rounded-lg shadow-sm hover:shadow transition-all cursor-pointer"
          >
            Sign up
          </button>
        </div>

        {/* Mobile Hamburger Button */}
        <button
          type="button"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="md:hidden p-1.5 text-[#1F1F1F] rounded-lg hover:bg-black/5"
          aria-label="Toggle navigation menu"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            {isMobileMenuOpen ? (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            ) : (
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            )}
          </svg>
        </button>
      </div>

      {/* Mobile Drawer Menu */}
      {isMobileMenuOpen && (
        <div className="md:hidden bg-[#FFD455] border-t border-[#E6BE40]/60 px-6 py-4 space-y-3 shadow-lg">
          {navLinks.map((link) => (
            <a
              key={link.label}
              href={link.href}
              onClick={() => setIsMobileMenuOpen(false)}
              className="block text-[15px] font-medium text-[#1F1F1F] py-1.5"
            >
              {link.label}
            </a>
          ))}
          <div className="pt-3 border-t border-black/10 flex flex-col gap-2.5">
            <button
              type="button"
              onClick={() => {
                setIsMobileMenuOpen(false);
                onOpenLogin();
              }}
              className="w-full text-center text-[14px] font-medium text-[#0D121C] py-2 rounded-md bg-black/5"
            >
              Login
            </button>
            <button
              type="button"
              onClick={() => {
                setIsMobileMenuOpen(false);
                onOpenSignup();
              }}
              className="w-full text-center text-[14px] font-medium text-white bg-[#318616] py-2 rounded-lg shadow-sm"
            >
              Sign up
            </button>
          </div>
        </div>
      )}
    </header>
  );
};
