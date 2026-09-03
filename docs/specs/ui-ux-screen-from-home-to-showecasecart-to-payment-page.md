# Checkout & Payment UX Flow — Category Selection → Payment Page
### Source: reference screen recordings (Blinkit app), reverse-engineered frame-by-frame
### Target stack: Flutter + Riverpod + go_router (per SESSION_CONTEXT.md)

This describes every screen from tapping a category on Home to landing on the Payment page, what's on each screen, and exactly what transition/animation moves you from one to the next. Use this as the spec for `phase-1-flutter-home-ui.md` (screens) and a new `phase-checkout-payment-ui.md` (transitions + payment page).

---

## Screen 0 — Home

**Purpose:** Entry point, category discovery.

**Content:**
- Sticky search bar ("Search for atta, dal, c...") with mic icon
- Horizontal category tab strip (All / Ganeshotsav / Electronics / Beauty…) — scrollable, dark maroon/olive background band
- "OFFERS FOR YOU" horizontal offer-card carousel
- "Bestsellers" section — 2×3 grid of category tiles, each tile = 2×2 mini product-image collage + "+N more" badge + category label
- "Grocery & Kitchen" section starts below (infinite-scroll of category rows)
- Bottom nav bar: Home / Order Again / Categories / Print / Zomato (external)

**No animation on load** beyond a standard cross-fade/skeleton shimmer while the first API response resolves (see Skeleton Loading Pattern at the end of this doc).

---

## Screen 1 — Category / Subcategory Listing

**Trigger:** Tap a "Bestsellers" tile or a top category tab.

**Transition in:** Modal bottom sheet slides up from the bottom over a **dimmed, non-interactive Home screen** behind it (scrim `Colors.black54`). Sheet covers ~92% of screen height, rounded top corners. Duration ≈ 250–300ms, `Curves.easeOutCubic` (Flutter's default `showModalBottomSheet` animation is a good match — do not build this from scratch).

**Content:**
- Sheet header: category title ("Dairy, Bread, Eggs & More"), a small "X" close affordance floats above the sheet on the scrim
- Left rail: vertical list of subcategories (icon + label), current one highlighted with a green left-border indicator
- Right pane: 2-column product grid for the selected subcategory — image, weight/qty, price, "ADD" button (or stepper if already in cart), rating + order count, delivery-time chip, low-stock chip ("2 left")
- Selecting a different subcategory in the left rail **does not close the sheet** — right pane content cross-fades/scrolls to the new subcategory (`AnimatedSwitcher`, ~150ms fade)
- Bottom of sheet, once cart has ≥1 item: green **"View cart"** pill bar slides up and docks above the system nav bar (`AnimatedPositioned` / `SlideTransition` from `Offset(0,1)` → `Offset(0,0)`, ~200ms spring-ish curve)

**Exit:** Tap "X" or swipe down → sheet slides down (reverse of entry) and scrim fades out, returning to Home underneath.

---

## Screen 2 — Product Variant Selector

**Trigger:** Tap directly on a product card (not the ADD button) when it has multiple weight/size options.

**Transition in:** A **second, smaller bottom sheet stacks on top of** the category sheet — same slide-up + scrim pattern, but only covers ~55–60% of height (it's a nested modal). Background dims further (double scrim effect is visible in the recording as darker overlay).

**Content:**
- Product title ("Amul Taaza Toned Milk Pack")
- Horizontal row of variant cards (image, "ADD" button, size, price, price-per-unit) — 2 cards visible at a time, e.g. 500ml/₹30 and 1L/₹59
- Tapping "ADD" on a variant does **not** navigate anywhere — button morphs in place into a green stepper (`− 1 +`) via `AnimatedSwitcher`/`AnimatedContainer` crossfade, ~150ms

**Exit:** Tap outside sheet or drag down → slides down, revealing Screen 1 underneath with that product's card now also showing the stepper state (state is shared via a single cart provider, so both places update simultaneously — no navigation needed).

---

## Screen 3 — Add-to-Cart Micro-interaction (not a screen, a state transition)

- Grid card "ADD" button → stepper: `AnimatedSwitcher` crossfade + slight scale-in (0.9 → 1.0), ~150–200ms
- "View cart" bar: appears via slide-up-from-bottom + fade the **first time** an item is added in the session; subsequent quantity changes just update the item-count text in place (`AnimatedSwitcher` on the text, no re-slide)
- Recommend implementing this bar as a persistent widget in a `Stack`/`Scaffold.bottomSheet` slot that listens to cart-provider item count, rather than re-triggering navigation each time.

---

## Screen 4 — Checkout / Cart Page

**Trigger:** Tap "View cart".

**Transition in:** Full-screen **push** (standard `go_router`/`Navigator` push — slide-in from right on Android-style, or platform-default). This is a real route change, not a sheet — the AppBar changes to "Checkout" with back arrow, search icon, Share icon.

**Content:**
- "Delivery in 8 minutes" card with clock icon + "Shipment of 1 item" subtitle
- Cart line items: image, name, weight, stepper (`− 1 +`), price, "Move to wishlist" text link
- "You might also like" cross-sell horizontal carousel — same card pattern as Bestsellers, with discount badges ("13% OFF on MRP")
- Sticky bottom CTA bar: **"Choose address at next step"** (green, full-width)
- **Loading state:** on first entry, all of the above renders as grey shimmer/skeleton blocks (visible in the recording as blank rounded-rect placeholders) before content pops in — implement with `shimmer` package or a custom `AnimatedContainer` gradient sweep.

**Exit:** Tap the bottom CTA → bottom sheet slides up (same pattern as Screen 1).

---

## Screen 5 — "Select Delivery Location" Bottom Sheet

**Content:**
- List of the user's saved addresses (Home / Work / Other), each row: label icon, short address line, radio/selection indicator — tapping a row selects it directly, no intermediate confirmation step
- "Add new address" (green "+", chevron) — quick-add via map pin-drop only (see Note 1 below); no manual text-entry form in this flow
- "Request address from someone" (WhatsApp icon) — deep-links to WhatsApp share sheet
- "Import your addresses from Zomato" (Zomato icon)

**Transition in:** Standard modal bottom sheet slide-up, scrim over Checkout page — same pattern as Screen 1.

**Exit → directly into Screen 6 (Payment Page):** Tapping any address row (a saved address, or a freshly pin-dropped new one) does two things back-to-back, with no manual form and no toast in between:
1. Sheet slides down (reverse of entry, scrim fades out) — ~200ms
2. Immediately chained on completion of step 1: a full-screen **push** to the Payment page slides in from the right — ~300ms platform default

Implement this as a single chained transition rather than two independently-triggered ones, so there's no visible gap or flash of the bare Checkout page in between:

```dart
Future<void> onAddressSelected(Address address) async {
  cartController.setDeliveryAddress(address); // update state first
  Navigator.of(context).pop(); // close the sheet
  await Future.delayed(const Duration(milliseconds: 200)); // let sheet-close finish
  context.push('/checkout/payment'); // push straight into Screen 6
}
```

(An alternative that reads as a single continuous motion rather than two discrete steps: pop the sheet with `Navigator.pop()` and immediately `context.push()` in the same call stack — Flutter queues the push to start once the pop's route animation is disposed, so in practice the two transitions visually overlap into one smooth handoff rather than needing the explicit `Future.delayed`. Test both and pick whichever feels less like two separate motions on a real device.)

---

## Screen 6 — Payment Page ("Bill total: ₹57")

**Trigger:** Selecting an address on Screen 5 (see chained transition above) — there is no address-form screen in between anymore.

**Transition in:** Continuation of the Screen 5 exit transition — full-screen push, AppBar shows "Bill total: ₹57" as the title (dynamic — total amount, not a static "Payment" label) with back arrow only. Tapping back returns to Screen 4 (Checkout), now showing the address that was selected on Screen 5.

**Content, top to bottom, grouped into cards with section headers:**

1. **Recommended**
   - Single row: UPI app icon + **"FamApp UPI"** + chevron → this is *the* feature you asked about: the app detected an installed UPI-capable app on the device and surfaced it first, above generic payment methods, for one-tap pay.
2. **Cards**
   - "Add credit or debit…" row with green "ADD" action
   - Previously-saved instrument, e.g. "Pluxee" (meal card), no ADD needed, just tappable
3. **Wallets**
   - "Blinkit Money" — shows balance ("Balance: ₹0"), chevron
   - "Amazon Pay Balance" — "Link your Amazon Pay Bal…", green "ADD"
   - "Mobikwik" — "Link your Mobikwik wallet", green "ADD"
4. **Pay Later**
   - "LazyPay" — "Link your LazyPay account", green "ADD"
5. **Netbanking**
   - "Netbanking" row, green "ADD" → opens bank picker
6. **Pay on Delivery**
   - "Cash on Delivery" row, greyed out/disabled
   - Inline red warning banner: **"Cash on delivery is not available for orders below ₹50."** — conditional business rule, not a static label

**Loading state:** Same shimmer/skeleton pattern as Checkout — grey placeholder bars render first while payment-methods API resolves, then content pops in (this also matters for the "Recommended" row specifically, since it depends on an on-device UPI-app scan that isn't instant — see the payment-collection spec doc for how that detection works).

**Section entry animation:** Sections appear to fade/slide in top-to-bottom in the recording as content loads (staggered fade, ~50ms offset per section) rather than all popping at once — implement with a `ListView` + per-item `FadeTransition`/`AnimatedList`, or simply accept the shimmer→content swap if staggering adds complexity without much UX payoff at this stage.

**Exit (out of scope of the recording, but the natural next step):** Tap a payment method → either an in-app UPI-intent hand-off (app switches to the UPI app, e.g. FamPay, then returns via deep link) or a card/netbanking WebView, ending in an order-confirmation screen.

---

## Animation Reference Table (Flutter implementation mapping)

| Interaction | Widget/API | Duration | Curve |
|---|---|---|---|
| Category/variant bottom sheet | `showModalBottomSheet(isScrollControlled: true)` | ~250ms (default) | `easeOutCubic` (default) |
| Nested variant sheet over category sheet | second `showModalBottomSheet` from within the first sheet's context | ~250ms | default |
| ADD button → stepper | `AnimatedSwitcher` + `AnimatedContainer` | 150–200ms | `easeInOut` |
| "View cart" bar slide-up | `SlideTransition` (Offset(0,1)→Offset.zero) inside `Scaffold.bottomSheet` or `Stack` | 200–250ms | `easeOutBack` (slight overshoot matches the recording's spring feel) |
| Page-to-page (Checkout, Payment) | `go_router` push / `MaterialPageRoute` | platform default (~300ms) | platform default (`Cupertino`/`Material` slide) |
| Address-sheet → Payment page chained handoff | sheet `pop()` immediately followed by route `push()` (see Screen 5 code) | ~200ms pop + ~300ms push, overlapping | default |
| Skeleton loading | `shimmer` package or custom gradient `AnimatedContainer` sweep | loop ~1200ms | linear |
| Section stagger on Payment page load | `AnimatedList` or per-section `FadeTransition` with `Future.delayed` offsets | 50ms stagger, 200ms fade each | `easeOut` |

---

## Notes / Assumptions to confirm with you before building

1. Since the manual "Add address details" form is removed, **"Add new address" on Screen 5 is assumed to resolve via map pin-drop only** (drop a pin, confirm, done — no typed street/contact-details form). If you actually want zero new-address capability in this flow (only ever picking from previously saved addresses), say so and Screen 5's "Add new address" row can be removed too.
2. "Request address from someone" (WhatsApp) and "Import from Zomato" are both **out of scope for MVP** per your locked tech decisions (no Zomato integration, no WhatsApp Business API in the plan) — recommend hiding these two entries for Phase 4/5 and revisiting only if there's a later phase for it.
3. Card/Wallet/Pay Later "ADD" flows (linking Amazon Pay, Mobikwik, LazyPay) all require partner-specific integrations that are **not part of a UPI-recommendation system** — see the payment-collection spec doc, which focuses only on the "Recommended" UPI section, Cards, and Netbanking (the three you asked to make functional), and treats Wallets/Pay Later as out-of-scope stubs for MVP.
4. Removing the manual address form also removes the "Address saved successfully" toast and the "Delivering to Home — Sewri, Sewree…" re-render moment on the Checkout page that used to follow it — Screen 4 now simply reflects whichever saved/pin-dropped address was picked on Screen 5, updated in place the next time a user lands back on Checkout (e.g. via the Payment page's back arrow).

i have also provide the screenshot corresponding to this screens 