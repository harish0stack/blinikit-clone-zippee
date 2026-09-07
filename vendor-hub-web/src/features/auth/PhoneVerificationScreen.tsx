// src/features/auth/PhoneVerificationScreen.tsx
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "./AuthContext";
import { initRecaptcha, sendOtp, confirmOtp } from "./phoneVerification";

export const PhoneVerificationScreen: React.FC = () => {
  const navigate = useNavigate();
  const { user, isPhoneVerified, refreshProfile } = useAuth();

  const [phone, setPhone] = useState("+91 ");
  const [otp, setOtp] = useState("");
  const [otpSent, setOtpSent] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  useEffect(() => {
    if (isPhoneVerified) {
      navigate("/onboarding");
    }
  }, [isPhoneVerified, navigate]);

  useEffect(() => {
    // Initialize reCAPTCHA on mount
    try {
      initRecaptcha("recaptcha-container");
    } catch (err) {
      console.warn("reCAPTCHA init error:", err);
    }
  }, []);

  const handleSendOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanPhone = phone.trim().replace(/\s+/g, "");
    if (!cleanPhone || cleanPhone.length < 10) {
      setError("Please enter a valid phone number with country code (e.g. +91 9999999999)");
      return;
    }

    setIsLoading(true);
    setError(null);
    setSuccessMsg(null);

    try {
      await sendOtp(cleanPhone);
      setOtpSent(true);
      setSuccessMsg(`OTP sent to ${cleanPhone}. (Use test OTP 123456 for test numbers)`);
    } catch (err: any) {
      console.error("Send OTP error:", err);
      setError(err?.message || "Failed to send OTP. Please check your number and try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    const cleanPhone = phone.trim().replace(/\s+/g, "");
    if (!otp.trim() || otp.trim().length < 6) {
      setError("Please enter the 6-digit OTP.");
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      await confirmOtp(otp.trim(), cleanPhone);
      setSuccessMsg("Phone number verified successfully!");
      await refreshProfile();
      setTimeout(() => {
        navigate("/onboarding");
      }, 800);
    } catch (err: any) {
      console.error("Confirm OTP error:", err);
      setError(err?.message || "Invalid OTP. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-[#F9FAFB] p-4 font-['Lexend',sans-serif]">
      {/* Invisible Recaptcha Container */}
      <div id="recaptcha-container" />

      {/* Main Verification Card */}
      <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        {/* Header */}
        <div className="bg-[#324B39] p-6 text-center text-white">
          <div className="inline-flex items-center justify-center w-12 h-12 bg-white/10 rounded-full mb-3">
            <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold">Verify Your Phone</h1>
          <p className="text-xs text-white/80 mt-1">
            Linked to Google Account: <span className="font-semibold text-white">{user?.email}</span>
          </p>
        </div>

        {/* Card Body */}
        <div className="p-8">
          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">
              {error}
            </div>
          )}

          {successMsg && (
            <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 text-emerald-800 text-sm rounded-lg">
              {successMsg}
            </div>
          )}

          {!otpSent ? (
            <form onSubmit={handleSendOtp} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  Mobile Number *
                </label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+91 9999999999"
                  required
                  className="w-full h-12 px-4 rounded-lg bg-white border border-[#D2D6DB] text-base text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 transition-all font-medium"
                />
                <p className="text-xs text-gray-500 mt-1.5">
                  We'll send an SMS with a one-time verification code.
                </p>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 bg-[#318616] hover:bg-[#286f12] active:scale-[0.99] text-white font-semibold rounded-lg shadow-md transition-all cursor-pointer flex items-center justify-center"
              >
                {isLoading ? "Sending OTP..." : "Send Verification OTP"}
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyOtp} className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  Enter 6-Digit OTP
                </label>
                <input
                  type="text"
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  placeholder="123456"
                  required
                  className="w-full h-12 px-4 text-center tracking-widest text-2xl font-bold rounded-lg bg-white border border-[#D2D6DB] text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 transition-all"
                />
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-12 bg-[#318616] hover:bg-[#286f12] active:scale-[0.99] text-white font-semibold rounded-lg shadow-md transition-all cursor-pointer flex items-center justify-center"
              >
                {isLoading ? "Verifying..." : "Verify & Continue to Onboarding"}
              </button>

              <button
                type="button"
                onClick={() => setOtpSent(false)}
                className="w-full text-center text-sm text-[#318616] hover:underline cursor-pointer pt-2"
              >
                Change Phone Number
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};
