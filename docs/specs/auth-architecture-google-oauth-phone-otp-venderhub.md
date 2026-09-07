# Spec: Vendor Hub Auth, Simplified Onboarding, Dashboard, Image Pipeline & Consumer Sync
### Companion to SESSION_CONTEXT.md, `auth-architecture-google-oauth-phone-otp.md`
### Target: vendor-hub-web (React + Vite  + TypeScript) + Supabase Cloud (free tier) + Firebase (phone OTP only)

---

## 0. Decisions this spec locks in (read first)

1. **Vendor auth = Supabase native Google OAuth + Firebase phone OTP (test numbers), not a 6-step wizard.** Matches your existing locked "Auth — vendors: Google OAuth via Supabase Auth" row, extended with a phone-verification second factor per your request, using the same Firebase-for-phone-OTP decision from the earlier auth spec — except here it's the **web** Firebase JS SDK (vendor hub is React, not Flutter), and configured with **Firebase Console test phone numbers** so you can develop without real SMS or billing.
2. **Onboarding is 2 steps, not Blinkit's 6** (Image 1 shows their real production wizard: Business details → Brand details → Bank details → Shipping locations → Digital signature → Verify and submit). For prototyping, you're keeping: **Step 1 — Basic details** (what they sell), **Step 2 — Caution/acknowledgement** (clone of Image 3). Bank details, digital signature, shipping-location setup, and brand verification are explicitly deferred — flagged in Section 3 so it's a documented decision, not a silent omission.
3. **Image handling stays client-side compression, no Cloudinary.** Explained fully in Section 5 — this isn't a corner cut, it's what your own locked stack already specifies (`browser-image-compression`), it's free, and it's genuinely how a prototype-stage marketplace should do this before justifying a paid image CDN.
4. **Design tokens come from your Paper MCP server, not guessed here.** I don't have access to that MCP connection in this conversation, so wherever this spec needs a color/spacing/type value, it says "pull from Paper" rather than inventing one — the implementing agent should query the Paper MCP tool for the actual token set before writing any component styling, and treat any placeholder hex values below (carried over from your existing Flutter screens' green/off-white palette, for continuity) as fallback only.

---

## 1. Vendor Hub Authentication

### 1.1 Step A — Google OAuth (Supabase native)

Identical mechanism to the Flutter-side decision in `auth-architecture-google-oauth-phone-otp.md` Section 2, just via the web SDK instead of native mobile — Supabase's OAuth redirect flow, no Firebase involved for this half.

```typescript
// src/lib/supabaseClient.ts (already exists per your locked structure)
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
);
```

```typescript
// features/auth/googleSignIn.ts
export async function signInWithGoogle() {
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
    },
  });
  if (error) throw error;
  // Browser redirects to Google, then back to /auth/callback with a session
}
```

```typescript
// routes/auth/callback.tsx — Supabase's client SDK auto-exchanges the
// redirect code for a session; just wait for it and route onward.
export function AuthCallback() {
  const navigate = useNavigate();
  useEffect(() => {
    supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_IN' && session) {
        navigate('/onboarding/phone-verification');
      }
    });
  }, []);
  return <LoadingScreen />;
}
```

At this point, `auth.users` has a real Supabase-native row for the vendor — `auth.uid()` and standard RLS work unmodified, exactly as decided in the earlier auth spec (Google OAuth was never routed through Firebase, and still isn't).

### 1.2 Step B — Phone verification (Firebase, test numbers)

This is a **second factor**, layered on top of the Google session, not a replacement for it — the vendor is already authenticated with Supabase by this point; this step just confirms/records a phone number against their `vendor_users` row.

**Firebase Console setup (one-time, dev-only):**
1. Create/open your Firebase project (or reuse the one from the consumer-app phone-OTP spec — this is a fine place to share a project, since this is purely for OTP delivery, not data storage).
2. Authentication → Sign-in method → Phone → enable.
3. Scroll to **"Phone numbers for testing"** → add a fixed pair, e.g. `+91 9999999999` / `123456`. Entering this exact number + code combination anywhere in your app succeeds without sending a real SMS and without needing Firebase billing enabled — this is Google's own documented mechanism for exactly this situation, not a workaround.

**Web SDK integration:**

```typescript
// src/lib/firebaseClient.ts
import { initializeApp } from 'firebase/app';
import { getAuth, RecaptchaVerifier, signInWithPhoneNumber } from 'firebase/auth';

const firebaseApp = initializeApp({
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
});

export const firebaseAuth = getAuth(firebaseApp);
```

```typescript
// features/onboarding/phoneVerification.ts
import { firebaseAuth } from '@/lib/firebaseClient';
import { RecaptchaVerifier, signInWithPhoneNumber, type ConfirmationResult } from 'firebase/auth';

let confirmationResult: ConfirmationResult | null = null;

export function initRecaptcha(containerId: string) {
  return new RecaptchaVerifier(firebaseAuth, containerId, {
    size: 'invisible', // no visible challenge for the test-number happy path
  });
}

export async function sendOtp(phoneNumber: string, verifier: RecaptchaVerifier) {
  confirmationResult = await signInWithPhoneNumber(firebaseAuth, phoneNumber, verifier);
}

export async function confirmOtp(code: string): Promise<boolean> {
  if (!confirmationResult) return false;
  try {
    await confirmationResult.confirm(code);
    return true;
  } catch {
    return false;
  }
}
```

**Important architectural note — do not route vendor identity through Firebase.** Unlike the consumer app's phone-OTP decision (where Firebase *becomes* the identity provider via Supabase's Third-Party Auth), here Firebase phone auth is used **only as a one-time verification step**, not as an ongoing session. Once `confirmOtp` succeeds:

```typescript
// After confirmOtp() returns true:
const { data: { user } } = await supabase.auth.getUser(); // the existing Google-OAuth Supabase user

await supabase
  .from('vendor_users')
  .update({ phone_number: phoneNumber, phone_verified: true })
  .eq('user_id', user.id);

// Immediately sign out of the Firebase app instance — you don't want two
// live sessions/identities to reason about. Firebase's job here is done.
await firebaseAuth.signOut();
```

This keeps exactly one identity system for vendors (Supabase-native, Google-OAuth-backed), with Firebase used as a disposable OTP-delivery utility — simpler than the consumer-app pattern because vendors don't need phone-based *login*, just phone *verification* once during onboarding.

**Schema addition:**
```sql
alter table vendor_users
  add column phone_number text,
  add column phone_verified boolean not null default false;
```

---

## 2. Simplified 2-step onboarding

### Step 1 — Basic details

Single form, single screen (no left-rail step tracker needed at 2 steps — that UI pattern from Image 1 exists specifically to manage a long 6-step flow's cognitive load, which you no longer have).

**Fields:**
- **Business/shop name** (text, required) — what shows to consumers as the seller name
- **What will you be selling?** — multi-select category picker (reuse your `categories` table as the source, same categories consumers browse: (Dairy/Bread/Eggs, Chips & Namkeen, Fresh Vegetables & Fruits,pet food and supplies, Energy Drinks and juices,biscuits and cookies), matching your Supabase Storage bucket's folder-per-category structure) — cap at, say, 5 for MVP rather than Blinkit's "up to 10," since a prototype vendor is realistically testing one or two categories
- **Contact person name** (text, required) — pre-fillable from the Google account's display name, editable
- Primary button: **"Continue"**

```typescript
// vendors table already exists per locked schema — this writes into it
await supabase.from('vendors').insert({
  user_id: user.id,
  business_name: formValues.businessName,
  contact_name: formValues.contactName,
  categories: formValues.selectedCategoryIds, // or a join table if you prefer normalized
  onboarding_status: 'basic_details_complete',
});
```

now above defined content/input boxes of onbaording u have to implement for the screen basic detials designed inside the paper design tool as it is and also try to not loose the design tokens of the screens provoided from the paper tool and dont try enter ur own deisgn tokens or style i want to strictly follow the given design tokens try to maintain it- https://app.paper.design/file/01KRTB83SGFZYAYTP6YGVJA2TP/1-0/BLN-0

### Step 2 — Caution / acknowledgement screen (clone of Image 3)

Static content screen, no form inputs beyond a single acknowledgement action — this is a direct clone of the reference image's content and layout:
so u dont have to manually /guesss the css or the layout for the cautious screen bcz i have the exact design tokens and layout and contnet designed in the paper design tool and u just have to get it thorugh the paper mcp server to implement as it is design to code without introducing our css values and also get the assests download in like webp, svg foramt for optimzed /perforamt from the paper design tool  - https://app.paper.design/file/01KRTB83SGFZYAYTP6YGVJA2TP/1-0/40U-0



```typescript
async function completeOnboarding() {
  await supabase
    .from('vendors')
    .update({ onboarding_status: 'complete' })
    .eq('user_id', user.id);
  navigate('/dashboard');
}
```

Use `onboarding_status` as a simple state machine (`basic_details_complete` → `complete`) rather than a numeric step count — it's clearer to branch UI/routing logic on, and trivially extensible if you add real steps back later (bank details, etc.) without a schema change.

---

## 3. Vendor Dashboard (post-onboarding main interface)

Modeled on what a Blinkit-style seller hub dashboard actually contains, scoped to what's relevant for your MVP (payments/settlement dashboards, bulk-catalog-upload tooling, and analytics deep-dives are real parts of Blinkit's actual Seller Hub but out of scope for a prototype focused on catalog upload + consumer sync):

### 3.1 Layout shell

- **Left sidebar** (persistent, matches the dark green sidebar pattern from Image 1's onboarding wizard — pull the exact color from Paper): logo/branding at top, nav items below:
  - Dashboard (home/overview)
  - Catalog (product list + add-product entry point — Section 3.3, the focus of this spec)
  - Orders (list of incoming orders for this vendor's products — stub/placeholder acceptable for MVP if order-fulfillment isn't built yet)
  - Profile & Settings (Section 3.4)
  - Logout (bottom-anchored, matches Image 1's placement)
- **Top bar** (within main content area): page title, maybe a quick-search input for the vendor's own catalog

### 3.2 Dashboard / overview page

Simple metrics cards row (pull from `products`/`orders` tables via a lightweight aggregate query or Postgres view):
- Total live products
- Products pending review
- Total orders (if order data exists yet)
- A shortcut card: "Add a new product" → routes straight to Section 3.3's form

### 3.3 Catalog — product list + Add Product flow (the core of this spec)

**Product list view:**
- Table or card-grid of the vendor's own products (filtered `where vendor_id = current_vendor.id`), columns/fields: thumbnail, name, category, price, status badge (`draft` / `pending_review` / `live` / `rejected`, color-coded), stock qty, "Edit" action
- "Add Product" button, top-right, primary style

**Add/Edit Product form** — this is the screen that needs "every detail used in showcasing/syncing the product on the consumer app," matching your locked `products`/`product_images` schema:

| Field | Type | Notes |
|---|---|---|
| Product name | text, required | shown as the product title in the consumer app's category grid and detail view |
| Category | select, required | must match one of the vendor's onboarding-selected categories, and must map to a real Storage bucket folder (Section 5) |
| Description | textarea, required | shown on the consumer product-detail view |
| Price (MRP) | number, required | |
| Selling price | number, required | must be ≤ MRP; the discount badge shown on the consumer app (e.g. "13% OFF on MRP") is derived from these two, not entered separately |
| Weight/quantity per unit | text, required | e.g. "500 ml", "1 kg" — matches the variant pattern from your checkout-flow UX doc |
| Variants (optional) | repeatable group of {weight, price} | mirrors the "Product Variant Selector" bottom sheet from the consumer UX spec — a product can have multiple purchasable sizes |
| Stock quantity | number, required | maps to your locked `products.stock_qty` single-global-column MVP decision |
| Product images | multi-file upload, at least 1 required, up to 5 | full pipeline in Section 5 |
| Ingredient/attribute tags (optional) | multi-select chips | powers the small tag chips shown on consumer product cards ("Toned", "Full Cream", "Paraben Free", etc. from your UX reference screenshots) |

Submit button: **"Submit for review"** — writes `status = 'pending_review'` (per your locked `products.status` flow: `draft → pending_review → live/rejected`), not directly `live`. Whatever your review process is (manual admin approval, or an automated check) is out of scope here — this spec only needs the vendor-facing upload to land correctly in that state.

### 3.4 Profile & Settings page

- Business details (editable: name, categories, contact) — same fields as onboarding Step 1, now editable
- Phone number (read-only display + "verified" badge, re-verification flow if they need to change it — reuses Section 1.2's flow)
- Google account email (read-only, from `auth.users`)
- Logout button

---
and while implementing the new svg icons in the screen u can use like lucide icons for good modern svgs icons like for profile 
## 4. Design tokens

Pull the real values from your Paper MCP server before implementing any of the above — specifically: color palette (background, card surface, text primary/secondary, accent/CTA color, status badge colors for draft/pending/live/rejected), typography scale, spacing scale, corner-radius scale, and the shadcn/ui theme config if Paper has one exported. Don't hardcode guessed hex values into the actual components.

u can go thorugh like for getting th edesign tokens idea for the dashboard screen to design correctly -
https://app.paper.design/file/01KRTB83SGFZYAYTP6YGVJA2TP/1-0/40U-0
https://app.paper.design/file/01KRTB83SGFZYAYTP6YGVJA2TP/1-0/3Y8-0
https://app.paper.design/file/01KRTB83SGFZYAYTP6YGVJA2TP/1-0/BLN-0

As a fallback only (if Paper's tokens aren't reachable when this is implemented), the values already established across your Flutter consumer-app screens are a reasonable placeholder for visual consistency between the two surfaces:
- Accent/CTA green: `#0C831F`
- Primary text: `#1E1E1E`, secondary text: `#7E7E7E`
- Background: off-white/cream tones (`#FFFDF7` / `#F4F6FB` depending on screen)
- Card corner radius: 14px

---

## 5. Image upload, optimization, and correctness — without Cloudinary

### 5.1 Why not Cloudinary here

Cloudinary is a genuinely good product, but adding it right now means: a second cloud service to configure and pay for (beyond its free tier once you have real volume), a second API key to manage server-side, and a second point of failure — for a capability your **own locked stack already specifies for free**: `browser-image-compression` (npm), doing WebP conversion + 150–300KB target size, client-side, before upload. That decision predates this spec and this spec doesn't need to override it.

Separately: I checked whether **Supabase's own built-in image transformation/resizing** (which does exist and would be a natural fit) could substitute — it requires the **Pro plan**, not available on the free tier your stack is locked to. So that's not a free option either, right now.

**Net: for this prototyping phase, client-side compression is the correct call, not a corner cut** — it's free, it's already decided, and it fully solves the "vendor uploads a huge file" problem. What it does *not* solve on its own is aspect ratio / dimension correctness or a malicious/bypassed client — Sections 5.2 and 5.3 close those two gaps without adding a paid service.

**When to revisit this:** if you later need multiple responsive derivative sizes served efficiently across many device sizes/densities at real production volume, that's the point to reconsider Cloudinary, imgix, or upgrading to Supabase Pro's built-in transformation — not before.

### 5.2 Client-side: compress + enforce aspect ratio before upload

Two libraries, both free, both npm:

```bash
npm install browser-image-compression react-easy-crop
```

**Step 1 — crop to a fixed aspect ratio** (use `react-easy-crop` to let the vendor frame their photo into your catalog's required ratio — recommend **1:1 square**, matching the product-card thumbnails in your consumer UX spec):
the crop/aspect ratio of images inorder able to showcase correclty accroding to the box diaplyed on the client/user side on the flutter app side 

```tsx
// components/ProductImageCropper.tsx
import Cropper from 'react-easy-crop';

export function ProductImageCropper({ imageSrc, onCropComplete }: Props) {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);

  return (
    <div className="relative h-80 w-full">
      <Cropper
        image={imageSrc}
        crop={crop}
        zoom={zoom}
        aspect={1} // enforce 1:1 — every product thumbnail is guaranteed square
        onCropChange={setCrop}
        onZoomChange={setZoom}
        onCropComplete={(_, croppedAreaPixels) => onCropComplete(croppedAreaPixels)}
      />
    </div>
  );
}
```

**Step 2 — compress the cropped result:**

```typescript
import imageCompression from 'browser-image-compression';

export async function compressProductImage(file: File): Promise<File> {
  return imageCompression(file, {
    maxSizeMB: 0.3,           // 300KB target, matches your locked spec
    maxWidthOrHeight: 1024,   // consumer app never needs a larger source than this
    useWebWorker: true,       // keeps the compression off the main thread — no UI jank
    fileType: 'image/webp',
  });
}
```

Reject (with an inline error, before even attempting upload) any file that isn't an image MIME type or exceeds a hard ceiling (e.g. 10MB original, before compression) — cheap client-side checks that avoid wasting the compression step on obviously-invalid input.

### 5.3 Server-side: a validation gate, not a processing pipeline

Client-side checks can be bypassed (a vendor calling your API directly, or disabling JS). Add a lightweight **validation-only** check in your existing `publish-product` Edge Function (already in your locked folder structure) — this is deliberately *not* a re-compression/re-processing pipeline, since running native image libraries like `sharp`/`libvips` inside a Deno Edge Function is unreliable (they depend on native bindings Deno's runtime doesn't support well) — pure dimension/size checks are enough as a backstop:

```typescript
// supabase/functions/publish-product/index.ts (addition to existing function)
import { imageSize } from 'npm:image-size'; // pure-JS, no native bindings — safe in Deno

async function validateProductImage(fileBytes: Uint8Array): Promise<{ valid: boolean; reason?: string }> {
  if (fileBytes.byteLength > 500 * 1024) {
    return { valid: false, reason: 'Image exceeds 500KB after compression — re-upload from the app, not a direct API call.' };
  }
  const dimensions = imageSize(fileBytes);
  if (!dimensions.width || !dimensions.height) {
    return { valid: false, reason: 'Could not read image dimensions — file may be corrupt.' };
  }
  const aspectRatio = dimensions.width / dimensions.height;
  if (Math.abs(aspectRatio - 1) > 0.05) { // allow a small tolerance around exact 1:1
    return { valid: false, reason: 'Image must be square (1:1 aspect ratio).' };
  }
  return { valid: true };
}
```

Run this check **before** the `supabase.storage.upload()` call inside the Edge Function, and reject the whole product submission with a clear error if it fails — this is your real enforcement point; the client-side crop/compress step is what makes the common case fast and correct, this is what makes it actually safe.

### 5.4 Storage path convention

Keep using the category-folder structure your existing bucket already has (visible in your screenshot: `biscuits_and_cookies/`, `chips_and_namkeen/`, `dairy-bread-eggs/`, etc.) — write new vendor uploads into the folder matching the product's selected category, with a collision-proof filename:

```typescript
const filePath = `${categorySlug}/${vendorId}_${crypto.randomUUID()}.webp`;
await supabase.storage.from('product-images').upload(filePath, compressedFile);
const { data: { publicUrl } } = supabase.storage.from('product-images').getPublicUrl(filePath);
// store publicUrl directly on product_images.image_url, per the earlier search-feature spec
```

---

## 6. Syncing a newly-uploaded product to the consumer app, fast

### 6.1 The path from vendor submit to consumer visibility

Vendor submits product ──► publish-product Edge Function runs
                            image validation (Section 5.3) only
                                    │
                                    ▼
                    products inserted with status = 'live' directly
                                    │
                                    ▼
Supabase Realtime (already part of your locked stack)
broadcasts a postgres_changes event on the `products` table
                                    │
                                    ▼
Every consumer app instance with an open Realtime subscription
filtered to that product's category receives the change
                                    │
                                    ▼
Riverpod catalog provider updates in-memory state,
Hive local cache is updated to match,
category grid re-renders with the new product

For now, pending_review and rejected are unused states — every submission that passes the image validation gate (Section 5.3, which stays in place; it's a data-integrity check, not a review process) goes straight to live. This is a deliberate, temporary simplification: no vendor trust model exists yet, so there's nothing meaningful to gate on. Section 6.4 below covers what a real review pipeline looks like and how to reintroduce it later without restructuring anything you build now — reintroducing it is a matter of changing what publish-product writes to status, not changing the schema, the form, or the sync mechanism.

This is the same Realtime mechanism your locked stack already designates for Phase 3 ("Realtime Catalog Sync") — this spec doesn't introduce a new sync mechanism, it just confirms the vendor-upload path feeds into the same one, and specifies the subscription shape needed for low latency.

### 6.2 Flutter side: category-scoped subscription (not one giant table-wide subscription)

```dart
// features/catalog/data/catalog_realtime_service.dart
final _channel = supabase
    .channel('products-category-$categoryId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'products',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_id',
        value: categoryId,
      ),
      callback: (payload) {
        // Update the Riverpod provider + Hive cache for this category only
        catalogNotifier.upsertProduct(Product.fromJson(payload.newRecord));
      },
    )
    .subscribe();
```

**Why filtered, not table-wide, matters at 20K concurrent:** an unfiltered subscription to the entire `products` table pushes every product change (across every category, every vendor) to every connected consumer, regardless of what they're looking at — at scale this multiplies Realtime message fan-out for no benefit. Scoping the subscription to the category the user currently has open (and re-subscribing when they navigate to a different category sheet, per your checkout-flow UX doc's Screen 1) keeps each client's message volume proportional to what they're actually viewing.

### 6.3 Latency expectations

This is a Postgres row change → Realtime's logical replication stream → WebSocket push to subscribed clients — typically **sub-second** end-to-end once the `UPDATE` commits, which is what "low latency" means in practice here; there's no polling interval to tune, no cache-invalidation delay to wait out. The real latency budget you control is on the vendor-upload side (image compression + Edge Function validation + Storage upload, Section 5), not the sync side — a fast-enough approval step is the only variable that determines "how soon after a vendor hits submit does a live product actually show up," and that's a business-process decision (manual review turnaround), not an engineering one.

---

## 7. Step-by-step implementation plan for the agent

### Phase A — Vendor auth
1. Set up Firebase project (or reuse the consumer-app one), enable Phone auth, add a test phone number + fixed OTP in the console
2. `apply_migration`: `vendor_users.phone_number`, `vendor_users.phone_verified` columns
3. Implement Google OAuth sign-in (Section 1.1) in vendor-hub-web
4. Implement Firebase phone-verification step (Section 1.2), including the explicit `firebaseAuth.signOut()` after confirmation so Firebase never becomes an ongoing session

### Phase B — Onboarding
5. `apply_migration`: `vendors.onboarding_status` column (if not already present in your locked schema)
6. Build Step 1 (Basic details) form + submit handler
7. Build Step 2 (Caution screen, clone of Image 3) + "Got it" handler routing to `/dashboard`
8. Route-guard the dashboard: redirect to onboarding if `onboarding_status != 'complete'`

### Phase C — Dashboard shell + Catalog
9. Pull design tokens from Paper MCP server; build the sidebar/top-bar shell (Section 3.1)
10. Build the Dashboard overview page (Section 3.2) with basic aggregate metric cards
11. Build the product list view (Section 3.3), scoped to `vendor_id = current_vendor.id`
12. Build the Add/Edit Product form (Section 3.3's field table)

### Phase D — Image pipeline
13. `npm install browser-image-compression react-easy-crop image-size` (the last one inside `supabase/functions/publish-product`, not the web app)
14. Implement `ProductImageCropper` (1:1 enforced) + `compressProductImage` (Section 5.2)
15. Add the validation gate to `publish-product` Edge Function (Section 5.3) — dimension/size/aspect-ratio checks before Storage upload
16. Confirm the category-folder Storage path convention (Section 5.4) matches your existing bucket structure

### Phase E — Consumer sync
17. Confirm/implement the category-scoped Realtime subscription pattern (Section 6.2) on the Flutter side, if Phase 3 hasn't already built this
18. End-to-end test: submit a product as a vendor → manually flip its status to `live` via `execute_sql` → confirm it appears in the running Flutter consumer app within a second or two, in the correct category, with the correct (compressed, square) image

### Phase F — Verification
19. `get_advisors`: confirm RLS on `vendors`/`vendor_users`/`products` — a vendor should only read/write their own rows, never another vendor's
20. Test the "bypass the client" case: call `publish-product` directly with an oversized/non-square test image, confirm the Edge Function rejects it rather than trusting client-side compression alone