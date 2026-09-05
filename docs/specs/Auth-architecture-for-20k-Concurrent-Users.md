# Spec: Auth Architecture for 20,000 Concurrent Users
### Google OAuth (vendors) + Phone OTP (consumers), on top of the locked Supabase backend
### Companion to SESSION_CONTEXT.md — this refines the "Auth — consumers" and "Auth — vendors" rows in the locked Technology Decisions table

---

## 0. Direct answers first

**"How long do apps like Blinkit/Zomato keep you logged in without re-registering?"**
Effectively indefinitely, until you explicitly log out, uninstall+reinstall, or the backend revokes the session for security reasons. They don't repeatedly re-run the Google OAuth or OTP flow — they run it **once**, exchange it for their own backend's long-lived session, and silently refresh a short-lived access token in the background forever. Section 1 explains exactly how, because this is the mechanism you're actually asking about, not "OAuth" itself.

**"Should I use Firebase for Google OAuth + Phone OTP and Supabase for everything else?"**
**Split it — don't use Firebase for both.**
- **Google OAuth: stay on Supabase's native flow.** No Firebase needed. It's simpler, free, and already what your locked stack says for vendors.
- **Phone OTP: use Firebase Auth**, bridged into Supabase via Supabase's official **Third-Party Auth (Firebase)** integration, which is now generally available and requires no custom JWT-minting code — Supabase's Data API, Storage, and Realtime trust Firebase-issued tokens directly.

The reasoning for treating these two differently is in Sections 2 and 3 — they have genuinely different risk profiles, not just "Firebase is easier."

---

## 1. Research: how session persistence actually works (this is the mechanism, regardless of provider)

Every major auth system — Supabase Auth, Firebase Auth, Auth0 — uses the same two-token pattern:

- **Access token**: a short-lived JWT (Supabase's default is **3600 seconds / 1 hour**), sent on every API request, verified statelessly (no DB lookup needed — just signature verification), embeds the user's ID and role for RLS.
- **Refresh token**: long-lived, opaque, stored securely on-device, used exactly once to mint a new access token — and Supabase (like Firebase) **rotates** it on every use: each refresh invalidates the previous refresh token and issues a new one, with a short grace window (`REFRESH_TOKEN_REUSE_INTERVAL`) to tolerate network retries/concurrency without falsely triggering theft-detection.

**What actually happens on your phone:**
1. User completes Google OAuth or Phone OTP once.
2. Your app never stores that raw Google/Firebase credential for reuse — it's exchanged immediately for **Supabase's own session** (access + refresh token pair).
3. The refresh token is written to secure, OS-backed storage (iOS Keychain / Android Keystore-backed EncryptedSharedPreferences — `supabase_flutter`'s default storage does this, or use `flutter_secure_storage` explicitly).
4. Every ~1 hour (or whenever a request needs a fresh token), the SDK silently calls refresh in the background — the user sees nothing, never re-enters credentials.
5. This continues **indefinitely** — weeks, months — until: the user logs out (revokes the refresh token server-side), the app is uninstalled (storage wiped), or Supabase's reuse-detection fires because a refresh token was used twice (a sign of token theft), which force-revokes the whole session chain as a security measure.

This is exactly the mechanism Blinkit/Zomato/every quick-commerce app relies on for "log in once, stay logged in." There's no special trick beyond correctly implementing token rotation + secure storage — which `supabase_flutter` already does correctly out of the box as long as you don't disable `persistSession`/`autoRefreshToken`.

**Implication for your build:** don't reduce the JWT expiry below Supabase's 1-hour default "to be safe" — going under ~5 minutes materially increases refresh-endpoint load at 20K concurrent users for no real security benefit (the refresh token, not the access token, is what actually needs to be protected/rotated).

---

## 2. Decision: Google OAuth → Supabase native, not Firebase

Your locked stack already says "Google OAuth via Supabase Auth" for vendors — this research confirms that's the right call, and extending it to consumers (if you ever add a "continue with Google" option there too) is equally fine.

**Why not Firebase for this part:**
- Flutter's native Google Sign-In (`google_sign_in` package) already gets you the OS-native account picker on both platforms — Firebase adds nothing here, it's not what makes the picker "native."
- Supabase Auth has first-class support for exactly this via `signInWithIdToken()`: your app gets a Google **ID token** on-device (no browser/WebView redirect needed), hands it to Supabase, and Supabase verifies + creates/links the user directly — this is a **single network call to your existing Supabase project**, no second backend involved.
- It keeps a single source of truth for identity (`auth.users`, `auth.uid()` works everywhere unmodified) — no dual-ID mapping problem, no extra Supabase billing category. (Using an external Firebase-issued token instead would put these users under Supabase's separate "Third-Party MAU" billing line — avoidable here for no benefit.)
- Zero additional cost, zero additional service to operate, zero additional abuse-surface — Google's OAuth infrastructure already handles bot/credential-stuffing protection upstream of you either way.

**Bottom line:** there is no scalability or security reason to route Google OAuth through Firebase in your stack. Keep it on Supabase native.

---

## 3. Decision: Phone OTP → Firebase Auth, bridged into Supabase

This is where the two providers genuinely differ, and where your instinct to reach for Firebase is well-founded — just not for the reason "Firebase is bigger."

### 3.1 What Supabase's built-in phone OTP actually requires you to operate

Supabase Auth's phone provider is a **thin pass-through** to a SMS vendor you bring yourself (Twilio, MessageBird, or Vonage) — Supabase doesn't send the SMS itself. This means:
- **You pay the SMS vendor directly**, per message, at that vendor's retail rate — for India-bound OTP SMS this is a real, non-trivial line item at 20K-concurrent-launch volume (this fluctuates by vendor/route, so get a current quote from Twilio/MessageBird before committing rather than trusting any fixed number here).
- **You own abuse protection.** The single biggest real-world risk with self-run OTP SMS is **toll/SMS-pumping fraud** — bots hitting your OTP-send endpoint to trigger paid SMS to premium-rate numbers, which silently drains your SMS vendor bill. Supabase's mitigation for this is a project-wide rate limit (`GOTRUE_RATE_LIMIT_SMS_SENT`, **default 30 SMS/hour for the entire project** — far too low for 20K concurrent users, and you must explicitly raise it via the dashboard or Management API) plus an optional CAPTCHA token check on the send-OTP call. You are responsible for wiring up that CAPTCHA (e.g., Cloudflare Turnstile) yourself.
- No device-level attestation (nothing verifying the request is actually coming from your real, unmodified app on a real device) is built in — you'd need to add that yourself if you want it.

### 3.2 What Firebase Phone Auth gives you instead

- **Built-in, Google-operated abuse protection**: invisible reCAPTCHA on web, and on Android, **Play Integrity API** device attestation (replacing the older SafetyNet) that lets Firebase silently verify the request is from a genuine, unmodified install of your app *before* it sends an SMS at all — this is meaningfully stronger fraud protection than a rate-limit counter, and it's exactly the kind of protection a consumer app handling real payments (per your other spec docs) benefits from having.
- **Billing is per-verification** (a per-SMS-equivalent charge), and Firebase absorbs the actual telecom SMS relationship — you don't separately manage a Twilio account for this piece.
- Proven at very large scale — this is the same phone-auth infrastructure behind a large share of consumer apps in the Indian market specifically, which is a reasonable proxy for "this holds up at 20K concurrent, and beyond."

### 3.3 The integration problem this used to cause — and why it's solved now

Historically, "use Firebase Auth but Supabase for everything else" meant hand-rolling a Deno Edge Function to verify the Firebase ID token and mint a matching custom Supabase JWT — extra latency, extra code to keep secure, one more thing to break at scale.

**This is no longer necessary.** Supabase now has an official **Third-Party Auth** integration for Firebase: you register your Firebase project ID in Supabase's Auth settings, and from then on Supabase's Data API, Storage, and Realtime **verify Firebase-issued JWTs directly** — no bridging function, no custom signing, no extra network hop. Supabase's hosted platform also automatically rejects any JWT from a Firebase project ID you haven't explicitly registered, closing the obvious spoofing hole.

The one real change this requires in your schema: RLS policies that used to say `auth.uid() = user_id` now need to compare against the Firebase-issued `sub` claim instead, and every Firebase user needs a `role: 'authenticated'` custom claim set (via a Firebase Cloud Function or Admin SDK call on user creation) so Supabase's RLS resolves them to the `authenticated` role rather than `anon`. Full detail in Section 5.

### 3.4 Verdict

| | Supabase native phone OTP (BYO Twilio) | Firebase Phone Auth + Supabase Third-Party Auth |
|---|---|---|
| Who operates SMS delivery | You, via Twilio/MessageBird/Vonage account | Firebase (Google) |
| Abuse protection | Manual: rate limit config + optional CAPTCHA you wire up | Built-in: Play Integrity + invisible reCAPTCHA |
| Identity stays in `auth.users`? | Yes, unmodified | No — Firebase UID becomes the identity; RLS keys off `sub` claim instead |
| Extra service to operate | No | Yes (a Firebase project) |
| Integration complexity | None (native) | Low (Third-Party Auth config, no custom bridging code) |
| Best fit | Lower-volume, or teams wanting single-provider simplicity | Consumer app at real scale, real fraud exposure, real money on the line |

**Recommendation for this project specifically, given you're building a payments-handling consumer app targeting 20K concurrent:** Firebase Phone Auth via Third-Party Auth. The abuse-protection gap in the self-run path is the deciding factor, not raw scalability — both approaches scale to 20K concurrent fine on the SMS-delivery side; the difference is what stops someone from turning your OTP-send endpoint into a fraud vector before you've even launched.

If you'd rather keep everything on one provider for simplicity and are comfortable manually configuring rate limits + CAPTCHA + monitoring SMS spend yourself, Supabase-native + Twilio is a legitimate, simpler fallback — just go in with eyes open about who owns the abuse-protection work.

---

## 4. Architecture overview

```
┌─────────────────────────────┐        ┌──────────────────────────────┐
│         Flutter App          │        │      Vendor Hub (React)       │
│                               │        │                                │
│  Phone OTP flow:              │        │  Google OAuth flow:            │
│  1. firebase_auth package     │        │  1. Supabase native OAuth      │
│     sends OTP via Firebase    │        │     (signInWithOAuth, Google)  │
│     (Play Integrity checked   │        │  2. Standard Supabase session  │
│     silently before send)     │        │     — auth.users, auth.uid()   │
│  2. User enters code           │        │     unmodified                │
│  3. Firebase confirms →        │        └──────────────┬─────────────────┘
│     Firebase ID token          │                       │
│  4. Passed as accessToken to   │                       │
│     Supabase client            │                       │
│     (no separate Supabase      │                       │
│     sign-in call needed)       │                       │
└──────────────┬────────────────┘                       │
               │                                          │
               ▼                                          ▼
     ┌────────────────────────────────────────────────────────┐
     │                  Supabase Project                        │
     │  - Third-Party Auth: Firebase project registered          │
     │  - Data API / Storage / Realtime verify BOTH:             │
     │      • native Supabase-issued JWTs (vendors)               │
     │      • Firebase-issued JWTs (consumers)                    │
     │  - RLS policies branch on which `sub`/claims format applies │
     │  - Edge Functions (Deno) verify either JWT type statelessly │
     └────────────────────────────────────────────────────────┘
```

Consumers and vendors end up on **two different token issuers**, which is fine — Supabase's Data API supports trusting multiple issuers simultaneously, it's a supported, documented pattern (this is exactly what Third-Party Auth was built for: coexisting with native Supabase Auth, not replacing it project-wide).

---

## 5. Schema changes required

Your locked schema has `users` and (implicitly) relies on `auth.uid()` for RLS. With Firebase in the mix for consumers, add an explicit mapping column rather than assuming `users.id = auth.uid()` everywhere:

```sql
-- users table: add explicit firebase_uid, keep existing id as your internal PK
alter table users
  add column firebase_uid text unique;

-- Index for the RLS lookup path
create index if not exists users_firebase_uid_idx on users(firebase_uid);
```

**RLS policy pattern, updated to accept either issuer:**

```sql
-- Example: cart_items, previously `auth.uid() = user_id`
create policy "consumers manage own cart (firebase-auth users)"
  on cart_items for all
  using (
    exists (
      select 1 from users
      where users.id = cart_items.user_id
        and users.firebase_uid = (auth.jwt() ->> 'sub')
    )
  );
```

For **vendor-hub tables** (still on native Supabase Auth), keep the existing `auth.uid() = vendor_users.user_id` pattern unchanged — nothing about vendor RLS needs to change.

**Firebase-side requirement:** every Firebase user must carry a `role: 'authenticated'` custom claim, or Supabase's Data API will treat their requests as `anon`. Set this via a Firebase Cloud Function's `beforeCreate`/`beforeSignIn` blocking trigger (requires Firebase Auth with Identity Platform) or via the Firebase Admin SDK immediately after your own `create-consumer-profile` Edge Function runs on first sign-in.

---

## 6. Step-by-step implementation plan (phased, matches your "one phase at a time" rule)

### Phase 4a — Firebase project setup (Phone Auth only)

1. Create a Firebase project (separate from — not replacing — your Supabase project).
2. Enable **Phone** as a sign-in provider in Firebase Auth.
3. Android: add your app's SHA-1/SHA-256 fingerprints (required for Play Integrity to silently verify your app without showing a reCAPTCHA challenge to real users).
4. iOS: enable APNs-based silent push for Firebase's device verification (Firebase falls back to reCAPTCHA if this isn't configured).
5. **Do not** enable any other Firebase product (Firestore, Realtime DB, Firebase Storage, Firebase Functions-for-business-logic) — this stays a single-purpose auth service; everything else remains Supabase per your locked stack.

### Phase 4b — Supabase Third-Party Auth configuration

1. In Supabase Dashboard → Authentication → Third-Party Auth, add a Firebase integration with your Firebase Project ID.
2. Equivalent CLI/config.toml entry for version control:
   ```toml
   [auth.third_party.firebase]
   enabled = true
   project_id = "<your-firebase-project-id>"
   ```
3. Apply the schema changes from Section 5 via `apply_migration` (MCP tool, per your locked workflow).
4. Write and test the updated RLS policies; verify with `get_advisors` that RLS is still enabled and non-permissive where required, per your "RLS test after every phase" rule.

### Phase 4c — Flutter: phone OTP flow

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
```

```dart
// features/auth/data/firebase_phone_auth_service.dart
class FirebasePhoneAuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> sendOtp({
    required String phoneNumber, // E.164 format: +91XXXXXXXXXX
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android auto-retrieval — sign in immediately without user typing code
        await _signInAndBridge(credential);
      },
      verificationFailed: onError,
      codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> confirmOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _signInAndBridge(credential);
  }

  Future<void> _signInAndBridge(PhoneAuthCredential credential) async {
    await _firebaseAuth.signInWithCredential(credential);
    // Nothing else to do here — Supabase client is configured with an
    // accessToken callback (Phase 4d) that pulls the current Firebase ID
    // token on every request. No separate Supabase sign-in call needed.
  }
}
```

### Phase 4d — Wiring the Supabase client to trust Firebase tokens

```dart
// core/network/supabase_client.dart
final supabase = SupabaseClient(
  supabaseUrl,
  supabaseAnonKey,
  accessToken: () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken(); // Firebase SDK auto-refreshes this
  },
);
```

`firebase_auth`'s own SDK already does the short-lived-token + silent-refresh dance internally (Firebase ID tokens are also short-lived, ~1 hour, auto-refreshed) — so Section 1's "stay logged in indefinitely" behavior is preserved automatically; you don't need to reimplement refresh logic yourself.

### Phase 4e — Flutter: Google OAuth flow (vendor hub is React/web — this section is for if/when consumers also get a Google option)

```yaml
dependencies:
  google_sign_in: ^latest
  supabase_flutter: ^latest
```

```dart
Future<void> signInWithGoogle() async {
  final googleSignIn = GoogleSignIn(
    serverClientId: '<web-client-id-from-google-cloud>',
  );
  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: googleAuth.idToken!,
    accessToken: googleAuth.accessToken,
  );
  // This IS a native Supabase Auth session — auth.uid() works normally,
  // no Third-Party Auth involved, no schema changes needed for this path.
}
```

### Phase 4f — Session persistence verification

- Confirm `supabase_flutter`'s default storage backend is being used (it wraps secure platform storage already) — do not swap in plain `SharedPreferences` for auth state.
- For the Firebase side, `firebase_auth`'s Flutter plugin persists its own session in platform-secure storage equivalently — no extra configuration needed.
- Test: force-close the app, reopen after >1 hour (past access-token expiry) with airplane mode toggled on/off during launch, confirm silent refresh recovers the session without dropping the user to a login screen.

### Phase 4g — Abuse/rate-limit hardening before opening to real traffic

1. Firebase: confirm Play Integrity is actually being invoked (check Firebase Auth logs for verification method used per sign-in — should show device-check success, not reCAPTCHA fallback, for the large majority of real Android users).
2. Supabase: even though phone OTP now flows through Firebase, **still raise Supabase's own default rate limits** (`rate_limit_token_refresh`, `rate_limit_verify`) via the Management API ahead of a launch/load-test, since the default 30-per-hour-per-bucket token-bucket limits are sized for a hobby project, not 20K concurrent users hitting refresh endpoints.
3. Add a Cloudflare Turnstile (or equivalent) challenge on the Google OAuth "continue" button on the vendor hub, since that path stays on Supabase-native and inherits Supabase's own (self-managed) abuse-protection posture rather than Firebase's.

### Phase 4h — k6 load testing additions (folds into your existing Phase 8)

- Simulate concurrent Firebase phone-sign-in **token refresh** (not full OTP send/verify — you shouldn't load-test real SMS sending against a live Twilio/Firebase account) by pre-provisioning test Firebase users and hammering `getIdToken(forceRefresh: true)`-equivalent calls.
- Simulate concurrent Supabase-native Google OAuth token refresh similarly using pre-provisioned test accounts.
- Verify Postgres/RLS query latency doesn't regress under the new "check `firebase_uid` via subquery" RLS pattern versus the old direct `auth.uid()` comparison — add an index (Section 5) and confirm via `EXPLAIN ANALYZE` that it's being used.

---

## 7. Cost shape (get current numbers before committing — these change)

| Component | Who bills you | What to check |
|---|---|---|
| Firebase Phone Auth verifications | Firebase (Google), per verification beyond free tier | Current Firebase pricing page, phone auth section |
| Supabase Third-Party MAU (Firebase-authenticated users) | Supabase, per Monthly Active Third-Party User | Current Supabase pricing page |
| Supabase native MAU (Google OAuth / vendor users) | Supabase, per Monthly Active User (standard, not Third-Party) | Current Supabase pricing page |
| Google OAuth itself | Free (Google doesn't charge for the OAuth handshake) | — |

Note that routing consumers through Firebase means they're billed as Supabase **Third-Party MAU** rather than standard MAU — factor this into your cost model rather than assuming it's a wash versus running Supabase-native phone auth end-to-end.

---

## 8. Summary

- **Session persistence** ("why don't users have to log in again") is a refresh-token-rotation mechanism, not a provider-specific trick — `supabase_flutter` and `firebase_auth` both implement it correctly by default; your job is to not disable it and to use secure storage, which is already the default.
- **Google OAuth stays on Supabase native** — no Firebase needed, zero extra cost, zero extra complexity, matches your locked stack.
- **Phone OTP moves to Firebase Auth**, bridged via Supabase's official Third-Party Auth integration — chosen specifically for its built-in device-attestation/abuse protection (Play Integrity + invisible reCAPTCHA), which matters more than raw throughput for a consumer app that's also handling payments, and requires no custom JWT-bridging code since Supabase now verifies Firebase JWTs natively.
- The real schema/RLS change this causes is small and contained: one `firebase_uid` mapping column, RLS policies keyed off `auth.jwt() ->> 'sub'` for consumer tables, `role: 'authenticated'` custom claim set on every Firebase user. Vendor-hub RLS is untouched.