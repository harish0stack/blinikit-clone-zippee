# Phase 4 — Auth Screens + Onboarding

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-4-auth-onboarding.md
> Branch: phase-4-auth
> Phases 0, 1, 2, 3 are COMPLETE.
> ```

---

## Goal

Implement authentication and onboarding for both apps:
- **Flutter consumer app**: Phone OTP login (via `otp-guard` Edge Function) → name capture → address onboarding
- **React vendor hub**: Google OAuth → business onboarding form → pending-review state

---

## How We Will Implement It

---

### Part A — Flutter Consumer Auth

#### Screen flow:

```
App launch
  → check auth state (Supabase session)
    → if logged in + has profile → HomeScreen
    → if logged in + no profile → ProfileSetupScreen
    → if not logged in → PhoneEntryScreen
                           → OtpVerifyScreen
                             → ProfileSetupScreen
                               → AddressOnboardingScreen
                                 → HomeScreen
```

#### Step 1 — Auth state provider

File: `lib/features/auth/presentation/providers/auth_provider.dart`
```dart
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return SupabaseClientService.client.auth.onAuthStateChange;
}

@riverpod
Future<bool> hasUserProfile(HasUserProfileRef ref) async {
  final session = SupabaseClientService.client.auth.currentSession;
  if (session == null) return false;
  final data = await SupabaseClientService.client
      .from('users')
      .select('id')
      .eq('auth_user_id', session.user.id)
      .maybeSingle();
  return data != null;
}
```

Update `lib/routing/app_router.dart` to use `authState` + `hasUserProfile` as redirect guards:
```dart
redirect: (context, state) async {
  final isLoggedIn = ref.read(authStateProvider).hasValue &&
      ref.read(authStateProvider).value!.session != null;
  final hasProfile = isLoggedIn && await ref.read(hasUserProfileProvider.future);

  if (!isLoggedIn) return '/auth/phone';
  if (!hasProfile) return '/auth/setup';
  return null;
}
```

#### Step 2 — PhoneEntryScreen

File: `lib/features/auth/presentation/screens/phone_entry_screen.dart`

UI elements:
- Country code picker (+91 default)
- Phone number text field (numeric keyboard, auto-format)
- "Get OTP" button
- Terms & Privacy text (required for app store compliance)

Logic:
```dart
// Call otp-guard Edge Function (NOT Supabase Auth OTP directly)
final response = await SupabaseClientService.client.functions.invoke(
  'otp-guard',
  body: {'phone': '+91$phoneNumber'},
);
if (response.status == 429) {
  // Show "Too many attempts. Try again in 10 minutes."
} else if (response.status == 200) {
  // Navigate to OtpVerifyScreen
}
```

#### Step 3 — OtpVerifyScreen

File: `lib/features/auth/presentation/screens/otp_verify_screen.dart`

UI elements:
- 6-digit OTP input (auto-focus, auto-advance)
- 60-second countdown resend timer
- "Resend OTP" link (calls `otp-guard` again after countdown)

Logic:
```dart
final response = await SupabaseClientService.client.auth.verifyOTP(
  phone: phone,
  token: otpCode,
  type: OtpType.sms,
);
// On success: session is created, router redirect kicks in
```

#### Step 4 — ProfileSetupScreen

File: `lib/features/auth/presentation/screens/profile_setup_screen.dart`

UI elements:
- Name text field (required)
- Optional email field
- "Continue" button

Logic:
```dart
// Insert into users table
await SupabaseClientService.client.from('users').insert({
  'phone': currentUser.phone,
  'name': name,
  'auth_user_id': currentUser.id,
});
// Navigate to AddressOnboardingScreen
```

#### Step 5 — AddressOnboardingScreen

File: `lib/features/auth/presentation/screens/address_onboarding_screen.dart`

UI elements:
- Address Line 1 (required)
- Address Line 2 (optional)
- City (required)
- Pincode (required, 6-digit numeric)
- Label dropdown (Home / Work / Other)
- "Save and Continue" button

> Map pin drop is stubbed in Tier A — just a text form. `geo_lat`/`geo_lng` default to null.

Logic:
```dart
final userId = await _getUserId();   // query users table for current auth.uid()
await SupabaseClientService.client.from('addresses').insert({
  'user_id': userId,
  'label': label,
  'line1': line1,
  'city': city,
  'pincode': pincode,
  'is_default': true,
});
// Navigate to HomeScreen
```

---

### Part B — React Vendor Hub Auth

#### Screen flow:

```
/ (root)
  → check Supabase session
    → if logged in + vendor approved → /dashboard
    → if logged in + vendor pending  → /pending-review
    → if logged in + no vendor       → /onboarding
    → if not logged in               → /login
```

#### Step 1 — Login page

File: `vendor-hub-web/src/features/auth/LoginPage.tsx`

```tsx
const handleGoogleLogin = async () => {
  await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
    },
  });
};
```

UI: centered card with Blinkit-yellow "Continue with Google" button + logo.

#### Step 2 — Auth callback handler

File: `vendor-hub-web/src/features/auth/AuthCallback.tsx`
```tsx
// Called after OAuth redirect
// Supabase auto-handles the code exchange
// After session is set, check vendor status and redirect
useEffect(() => {
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (session) {
      const { data } = await supabase
        .from('vendor_users')
        .select('vendors(status)')
        .eq('auth_user_id', session.user.id)
        .maybeSingle();

      if (!data) navigate('/onboarding');
      else if (data.vendors?.status === 'approved') navigate('/dashboard');
      else navigate('/pending-review');
    }
  });
}, []);
```

#### Step 3 — Onboarding form

File: `vendor-hub-web/src/features/auth/OnboardingPage.tsx`

Fields:
- Business Name (required)
- GSTIN (optional, validate format `[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}`)
- Category of business (dropdown)

Logic:
```typescript
// 1. Insert vendor (status defaults to 'pending')
const { data: vendor } = await supabase
  .from('vendors')
  .insert({ business_name, gstin })
  .select()
  .single();

// 2. Link vendor_user
await supabase.from('vendor_users').insert({
  vendor_id: vendor.id,
  auth_user_id: session.user.id,
  role: 'owner',
});

navigate('/pending-review');
```

#### Step 4 — Pending review page

File: `vendor-hub-web/src/features/auth/PendingReviewPage.tsx`

UI: Full-page state with:
- Blinkit logo
- "Your application is under review" heading
- Estimated review time (24–48 hours — static text for now)
- "Refresh status" button that re-checks `vendors.status` via Supabase Realtime subscription

```typescript
// Realtime: watch vendor status change
useEffect(() => {
  const channel = supabase
    .channel('vendor-status')
    .on('postgres_changes', {
      event: 'UPDATE',
      schema: 'public',
      table: 'vendors',
      filter: `id=eq.${vendorId}`,
    }, (payload) => {
      if (payload.new.status === 'approved') navigate('/dashboard');
    })
    .subscribe();
  return () => supabase.removeChannel(channel);
}, [vendorId]);
```

#### Step 5 — Route protection (React Router)

File: `vendor-hub-web/src/app/router.tsx`

```tsx
// ProtectedRoute component checks session + vendor status before rendering
<Route path="/dashboard" element={<ProtectedRoute requiredStatus="approved"><DashboardPage /></ProtectedRoute>} />
<Route path="/onboarding" element={<AuthRoute><OnboardingPage /></AuthRoute>} />
<Route path="/pending-review" element={<AuthRoute><PendingReviewPage /></AuthRoute>} />
<Route path="/login" element={<GuestRoute><LoginPage /></GuestRoute>} />
```

---

## Files in Scope

```
blinkit_clone_app/lib/features/auth/
├── presentation/
│   ├── screens/
│   │   ├── phone_entry_screen.dart          [CREATE]
│   │   ├── otp_verify_screen.dart           [CREATE]
│   │   ├── profile_setup_screen.dart        [CREATE]
│   │   └── address_onboarding_screen.dart   [CREATE]
│   └── providers/
│       └── auth_provider.dart               [CREATE]
└── (no new data/ files — auth uses Supabase SDK directly)

blinkit_clone_app/lib/routing/app_router.dart    [MODIFY — add auth redirect guards]

vendor-hub-web/src/features/auth/
├── LoginPage.tsx                             [CREATE]
├── AuthCallback.tsx                          [CREATE]
├── OnboardingPage.tsx                        [CREATE]
└── PendingReviewPage.tsx                     [CREATE]

vendor-hub-web/src/app/router.tsx            [MODIFY — add protected routes]
```

**Out of scope:** OTP via SMS provider (Supabase test mode is OK for development — configure real Twilio/MSG91 before going live). Vendor dashboard screens (Phase 5).

---

## Acceptance Criteria

### Flutter consumer app
- [ ] New user can enter phone → receive OTP → verify → enter name → enter address → land on HomeScreen
- [ ] Returning user with session lands directly on HomeScreen (no re-auth)
- [ ] 6th OTP request in 10 minutes shows error message from rate limiter
- [ ] `users` table has a new row after profile setup
- [ ] `addresses` table has a new row after address setup
- [ ] Auth state is preserved across app restarts (Supabase session persisted by SDK)
- [ ] Logout clears session and redirects to PhoneEntryScreen

### React vendor hub
- [ ] "Continue with Google" → Google OAuth → lands on onboarding form
- [ ] Submitting onboarding form creates `vendors` + `vendor_users` rows; status = `pending`
- [ ] PendingReviewPage shows after onboarding
- [ ] Manually flip vendor to `approved` in Supabase dashboard → PendingReviewPage auto-redirects to dashboard (Realtime working)
- [ ] Direct navigation to `/dashboard` while `status=pending` redirects to `/pending-review`
- [ ] Direct navigation to any auth route while logged out redirects to `/login`

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS | Verify: `users` table — one user cannot read another's row |
| 3 | OTP rate limiting | Verify: 6th request → 429 |
| 10 | Google OAuth only for vendors | Confirm: no password fields in vendor hub |
| 7 | Service-role key | Confirm absent from all client files |

---

## Next Phase

→ **Phase 5**: Vendor catalog upload flow (`docs/specs/phase-5-vendor-catalog-upload.md`)
