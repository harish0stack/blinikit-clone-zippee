// src/features/landing/components/AuthModal.tsx
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";
import { signInWithGoogle } from "../../auth/googleSignIn";
import { initRecaptcha, sendOtp, confirmOtp } from "../../auth/phoneVerification";

export type AuthMode = "login" | "signup";

interface AuthModalProps {
  isOpen: boolean;
  initialMode?: AuthMode;
  onClose: () => void;
  onSuccess?: () => void;
}

interface AuthModalDialogProps {
  initialMode: AuthMode;
  onClose: () => void;
  onSuccess?: () => void;
}

const AuthModalDialog: React.FC<AuthModalDialogProps> = ({
  initialMode,
  onClose,
  onSuccess,
}) => {
  const navigate = useNavigate();
  const { user, isPhoneVerified, refreshProfile } = useAuth();

  const [mode, setMode] = useState<AuthMode>(initialMode);
  const [mobileNumber, setMobileNumber] = useState("+91 ");
  const [initialIdentifier, setInitialIdentifier] = useState("");
  const [otpSent, setOtpSent] = useState(false);
  const [otpValue, setOtpValue] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  // If user is already Google authenticated but needs phone verification
  const isGoogleAuthenticated = Boolean(user?.email);

  useEffect(() => {
    // Initialize reCAPTCHA
    try {
      initRecaptcha("modal-recaptcha-container");
    } catch (err) {
      console.warn("reCAPTCHA init:", err);
    }
  }, []);

  // Handle ESC key press to close modal
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [onClose]);

  const handleGoogleSignInClick = async () => {
    setIsLoading(true);
    setError(null);
    try {
      await signInWithGoogle();
    } catch (err: any) {
      console.error("Google sign in error:", err);
      setError(err?.message || "Failed to sign in with Google.");
      setIsLoading(false);
    }
  };

  const handleSendMobileOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanPhone = mobileNumber.trim().replace(/\s+/g, "");
    if (!cleanPhone || cleanPhone.length < 10) {
      setError("Please enter a valid mobile number (e.g. +91 9999999999)");
      return;
    }

    setIsLoading(true);
    setError(null);
    setSuccessMsg(null);

    try {
      await sendOtp(cleanPhone);
      setOtpSent(true);
      setSuccessMsg(`OTP sent to ${cleanPhone}. (Use 123456 for test numbers)`);
    } catch (err: any) {
      console.error("Send OTP error:", err);
      setError(err?.message || "Failed to send OTP. Please verify your phone number.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyMobileOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanPhone = mobileNumber.trim().replace(/\s+/g, "");
    if (!otpValue.trim() || otpValue.trim().length < 6) {
      setError("Please enter the 6-digit OTP.");
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      await confirmOtp(otpValue.trim(), cleanPhone);
      setSuccessMsg("Phone verified successfully! Redirecting...");
      await refreshProfile();
      setTimeout(() => {
        onClose();
        if (onSuccess) onSuccess();
        navigate("/onboarding");
      }, 800);
    } catch (err: any) {
      console.error("Verify OTP error:", err);
      setError(err?.message || "Invalid OTP. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200"
      onClick={onClose}
    >
      {/* Invisible reCAPTCHA element */}
      <div id="modal-recaptcha-container" />

      {/* Modal Card */}
      <div
        className="relative w-full max-w-[508px] bg-white rounded-[16px] shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        <button
          type="button"
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-700 p-2 rounded-full hover:bg-gray-100 transition-colors z-10 cursor-pointer"
          aria-label="Close modal"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        {/* Modal Body */}
        <div className="pt-8 pb-6 px-8 sm:px-10">
          {/* Header */}
          <div className="text-center mb-6">
            <h2 className="text-[44px] sm:text-[50px] font-extrabold text-[#000000E0] tracking-[-2.24px] leading-tight">
              seller hub
            </h2>
            <p className="text-xl sm:text-[24px] font-bold text-[#000000E0] leading-[1.3] mt-1">
              {mode === "signup" ? "Please sign up to continue" : "Please log in to continue"}
            </p>
          </div>

          {error && (
            <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm text-center">
              {error}
            </div>
          )}

          {successMsg && (
            <div className="mb-4 p-3 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm text-center">
              {successMsg}
            </div>
          )}

          {/* VIEW A: After Google OAuth (Email is Verified, needs Mobile Phone Verification) */}
          {isGoogleAuthenticated && !isPhoneVerified ? (
            <div className="space-y-4">
              {/* Verified Email Row */}
              <div className="space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-[14px] font-medium text-[#1F1F1F]">
                    Enter your email <span className="text-red-500">*</span>
                  </span>
                  <span className="inline-flex items-center gap-1 text-[12px] font-semibold text-[#318616]">
                    <svg className="w-4 h-4 fill-current" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                    Verified
                  </span>
                </div>
                <div className="text-[15px] font-medium text-[#1F1F1F] py-1">
                  {user?.email}
                </div>
              </div>

              {!otpSent ? (
                <form onSubmit={handleSendMobileOtp} className="space-y-4 pt-1">
                  <div>
                    <label className="block text-[14px] font-semibold text-[#1F1F1F] mb-2">
                      Enter your mobile number <span className="text-red-500">*</span>
                    </label>
                    <input
                      type="tel"
                      value={mobileNumber}
                      onChange={(e) => setMobileNumber(e.target.value)}
                      placeholder="Enter your mobile number"
                      required
                      className="w-full h-12 px-4 rounded-lg bg-white border border-[#D2D6DB] text-base text-[#1F1F1F] placeholder:text-[#9DA4AE] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 transition-all font-medium"
                    />
                  </div>

                  <div className="pt-2">
                    <button
                      type="submit"
                      disabled={isLoading || !mobileNumber.trim()}
                      className={`w-full h-12 flex items-center justify-center rounded-lg text-lg font-medium transition-all ${
                        mobileNumber.trim() && !isLoading
                          ? "bg-[#318616] hover:bg-[#286f12] text-white shadow-md active:scale-[0.99] cursor-pointer"
                          : "bg-[#E5E7EB] text-[#9DA4AE] cursor-not-allowed"
                      }`}
                    >
                      {isLoading ? "Sending OTP..." : "Send OTP"}
                    </button>
                  </div>
                </form>
              ) : (
                <form onSubmit={handleVerifyMobileOtp} className="space-y-4 pt-1">
                  <div>
                    <label className="block text-[14px] font-semibold text-[#1F1F1F] mb-2">
                      Enter 6-digit OTP sent to {mobileNumber}
                    </label>
                    <input
                      type="text"
                      maxLength={6}
                      value={otpValue}
                      onChange={(e) => setOtpValue(e.target.value)}
                      placeholder="123456"
                      required
                      className="w-full h-12 px-4 text-center tracking-widest text-2xl font-bold rounded-lg bg-white border border-[#D2D6DB] text-[#1F1F1F] placeholder:text-[#9DA4AE] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 transition-all"
                    />
                  </div>

                  <div className="pt-2">
                    <button
                      type="submit"
                      disabled={isLoading || !otpValue.trim()}
                      className="w-full h-12 flex items-center justify-center rounded-lg text-lg font-medium bg-[#318616] hover:bg-[#286f12] text-white shadow-md active:scale-[0.99] cursor-pointer transition-all"
                    >
                      {isLoading ? "Verifying..." : "Verify & Continue"}
                    </button>
                  </div>

                  <button
                    type="button"
                    onClick={() => setOtpSent(false)}
                    className="w-full text-center text-sm text-[#318616] hover:underline cursor-pointer"
                  >
                    Change mobile number
                  </button>
                </form>
              )}
            </div>
          ) : (
            /* VIEW B: Initial Unauthenticated View (Google Sign-In + Fallback OTP) */
            <div className="space-y-4">
              <div>
                <label className="block text-[15px] font-medium text-[#384250] mb-2">
                  Enter your email or phone number*
                </label>
                <input
                  type="text"
                  value={initialIdentifier}
                  onChange={(e) => setInitialIdentifier(e.target.value)}
                  placeholder="Email or phone"
                  className="w-full h-12 px-4 rounded-lg bg-white border border-[#D2D6DB] text-base text-[#1F1F1F] placeholder:text-[#9DA4AE] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 transition-all"
                />
              </div>

              <div className="pt-1">
                <button
                  type="button"
                  disabled={!initialIdentifier.trim() || isLoading}
                  onClick={() => {
                    setError("Please sign in with Google below to verify your Seller identity.");
                  }}
                  className={`w-full h-12 flex items-center justify-center rounded-lg text-lg font-medium transition-all ${
                    initialIdentifier.trim() && !isLoading
                      ? "bg-[#318616] hover:bg-[#286f12] text-white shadow-md active:scale-[0.99] cursor-pointer"
                      : "bg-[#E5E7EB] text-[#9DA4AE] cursor-not-allowed"
                  }`}
                >
                  Send OTP
                </button>
              </div>

              {/* Divider */}
              <div className="flex items-center justify-center gap-3 my-4">
                <div className="h-[1.5px] flex-1 bg-[#E6E9EF]" />
                <span className="text-[14px] leading-none text-[#000000E0] px-1 font-normal">Or</span>
                <div className="h-[1.5px] flex-1 bg-[#E6E9EF]" />
              </div>

              {/* Google Sign In Button */}
              <button
                type="button"
                onClick={handleGoogleSignInClick}
                disabled={isLoading}
                className="w-full h-[50px] flex items-center justify-center gap-3 rounded-lg border border-[#000000] hover:bg-black/5 active:scale-[0.99] transition-all cursor-pointer"
              >
                <img
                  src="/assets/landing/icon-google.svg"
                  alt="Google"
                  className="w-6 h-6 object-contain"
                />
                <span className="text-[14px] font-medium text-[#000000E0]">
                  {isLoading ? "Connecting..." : "Sign in with Google"}
                </span>
              </button>

              {/* Mode Switcher */}
              <div className="mt-3 text-center">
                {mode === "signup" ? (
                  <p className="text-sm text-[#666666]">
                    Already have a seller account?{" "}
                    <button
                      type="button"
                      onClick={() => setMode("login")}
                      className="font-semibold text-[#318616] hover:underline cursor-pointer"
                    >
                      Log in
                    </button>
                  </p>
                ) : (
                  <p className="text-sm text-[#666666]">
                    New to Seller Hub?{" "}
                    <button
                      type="button"
                      onClick={() => setMode("signup")}
                      className="font-semibold text-[#318616] hover:underline cursor-pointer"
                    >
                      Sign up
                    </button>
                  </p>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Modal Bottom Banner */}
        <div className="w-full py-3.5 px-6 bg-[#F4F6FB] border-t border-[#E6E9EF]">
          <p className="text-center text-[13px] sm:text-[14px] font-medium text-[#828282] leading-tight">
            By continuing you agree to our{" "}
            <a href="#" className="text-[#318616] font-semibold hover:underline">
              Terms of Use
            </a>{" "}
            &{" "}
            <a href="#" className="text-[#318616] font-semibold hover:underline">
              Privacy Policy
            </a>
          </p>
        </div>
      </div>
    </div>
  );
};

export const AuthModal: React.FC<AuthModalProps> = ({
  isOpen,
  initialMode = "signup",
  onClose,
  onSuccess,
}) => {
  if (!isOpen) return null;

  return (
    <AuthModalDialog
      key={`${initialMode}-${isOpen}`}
      initialMode={initialMode}
      onClose={onClose}
      onSuccess={onSuccess}
    />
  );
};
