# Spec: FamPay-via-FamGateway "Fake-Real" Payment Workaround (Dev/Demo Only)
### Simulates a full real-money UPI payment confirmation loop, using your personal FamPay `@fam` VPA as the receiver, without a licensed Payment Aggregator
### Companion to `payment-collection-recommended-upi.md` — read the "Scope & Limitations" section below before building

---

## 0. Scope & Limitations (read this first)

This document specs out exactly what you asked for: a way to accept **real money into your real FamPay account**, get **real-time confirmation** in Supabase, and show a **real success screen** in Flutter — for development, testing, and showcasing the app to people (investors, friends, a demo day), without signing up for Cashfree/Razorpay/PhonePe PG.

This works via **FamGateway** (`famgateway.in`), a free third-party tool built by an independent developer (Aryan Gupta / "Aryanispe"). It is **not official FamPay infrastructure** — FamPay/Trio has no public developer API. FamGateway works by:
1. You give it a **Gmail App Password** for the Gmail inbox linked to your FamPay account
2. It watches that inbox via IMAP for FamPay's "you received ₹X" confirmation emails
3. When it sees one matching an order it's tracking, it fires a webhook to your server

**Before you build on this, be clear about what it is and isn't:**
- ✅ It genuinely works for real money movement, in real time, for **you personally testing your own app**.
- ✅ It's free, has no signup friction, and matches almost exactly the flow you described.

**Recommended framing for your project:** build this now as `PaymentProvider = 'fampay_dev'`, feature-flagged and swappable, so that when you're ready for real users you swap in Option A from the companion doc (a licensed PA) without touching your Flutter UI or Realtime plumbing — both providers plug into the exact same `orders`/`payments` schema and Realtime pattern below.

---

## 1. Architecture

```
[Flutter App]                         [Your Supabase Project]                [FamGateway]
     │                                        │                                    │
     │ 1. Open Payment page                   │                                    │
     │    → subscribe to Realtime early ──────┤ (channel primed, no cold-start     │
     │                                        │  latency later)                    │
     │                                        │                                    │
     │ 2. Tap "Pay via FamPay"                │                                    │
     ├──POST /create-payment-order───────────►│                                    │
     │                                        ├──POST /api/qr.php────────────────► │
     │                                        │   (upi=you@fam, amount=57)         │
     │                                        │◄─────order_id, qr_url,             │
     │                                        │       payable_amount=57.04         │
     │◄──order_id + upi intent string─────────┤                                    │
     │                                        │                                    │
     │ 3. Launch upi://pay?...&am=57.04       │                                    │
     │    at user's "Recommended" UPI app     │                                    │
     │    (per companion doc's detection)     │                                    │
     │                                        │                                    │
  [User pays inside GPay/PhonePe/FamPay/etc.] │                                    │
     │                                        │                                    │  4. FamPay emails
     │                                        │                                    │     "you received ₹57.04"
     │                                        │                                    │  5. FamGateway's IMAP
     │                                        │                                    │     IDLE catches it in
     │                                        │                                    │     ~3–5s, matches by
     │                                        │                                    │     unique amount + note
     │                                        │◄──POST /payment-webhook───────────┤
     │                                        │   {order_id, utr, amount, status}  │
     │                                        │                                    │
     │                                        │  6. verify signature, UPDATE       │
     │                                        │     orders SET status='paid'       │
     │                                        │     WHERE order_id=...             │
     │                                        │                                    │
     │◄──7. Realtime push (already            │                                    │
     │      subscribed since step 1) ─────────┤                                    │
     │                                        │                                    │
  8. Play success animation, navigate to      │                                    │
     order-confirmation screen                │                                    │
```

The two things that make this feel "instant" instead of "laggy" are (a) subscribing to Realtime **before** the user even taps pay, so there's no connection-setup time in the critical path, and (b) FamGateway's IMAP **IDLE** (push-based email watching, not polling their own inbox) — see Section 6 for more on this.

---

## 2. Step 1 — Set up FamGateway

1. Create a dedicated Gmail account just for this (recommended), or use your existing FamPay-linked Gmail if you accept the tradeoff above.
2. Go to `famgateway.in`, create an account, and in the dashboard connect that Gmail account with a **Gmail App Password** (not your real password — generate one under Google Account → Security → App Passwords; requires 2FA enabled on the Gmail account).
3. Grab your API key from the dashboard.
4. Note your FamPay UPI ID (e.g. `yourname@fam`) — this is the `pa` (payee address) you'll pass on every order.
5. Set your webhook URL in the FamGateway dashboard to your Supabase Edge Function URL (Step 4 below) — you'll get this URL after deploying it, so come back to this after Section 4.

Store the FamGateway API key as a Supabase secret, never in client code:
```bash
supabase secrets set FAMGATEWAY_API_KEY=your_key_here
supabase secrets set FAMGATEWAY_WEBHOOK_SECRET=your_webhook_signing_secret
```

---

## 3. Step 2 — Supabase schema

Extends the `payments`/`orders` tables from your existing plan. Using a dedicated `dev_payments` table keeps this cleanly separate from the production-PA schema in the companion doc, so swapping providers later is a config change, not a migration.

```sql
create table if not exists dev_payments (
  id uuid primary key default gen_random_uuid(),
  order_id text unique not null,              -- FamGateway's order_id, also our client-facing ref
  user_id uuid not null references auth.users(id),
  cart_order_id uuid not null references orders(id),
  requested_amount numeric(10,2) not null,     -- e.g. 57.00
  payable_amount numeric(10,2),                -- e.g. 57.04 (FamGateway's uniqueness offset)
  upi_vpa text not null,                       -- your receiver @fam id
  status text not null default 'pending',      -- pending | paid | expired | failed
  utr text,                                    -- bank reference, filled on success
  sender_name text,
  provider text not null default 'fampay_dev',
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

-- Index for the webhook's UPDATE ... WHERE order_id = $1 (keep this hot path fast)
create unique index if not exists dev_payments_order_id_idx on dev_payments(order_id);

-- RLS: users can only read their own payment row (for polling fallback / order history),
-- but never write to it directly — only the Edge Function (service role) writes.
alter table dev_payments enable row level security;

create policy "users read own dev_payments"
  on dev_payments for select
  using (auth.uid() = user_id);

-- no insert/update policy for anon/authenticated role at all — service role bypasses RLS

-- Turn on Realtime for this table
alter publication supabase_realtime add table dev_payments;
```

---

## 4. Step 3 — Edge Function: `create-payment-order`

```
supabase/functions/create-payment-order/index.ts
```

```typescript
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FAMGATEWAY_BASE = "https://famgateway.in/api";

serve(async (req) => {
  try {
    const { cartOrderId } = await req.json();
    const authHeader = req.headers.get("Authorization")!;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Auth: resolve the calling user from their JWT
    const { data: userData, error: authErr } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", "")
    );
    if (authErr || !userData.user) {
      return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
    }
    const userId = userData.user.id;

    // NEVER trust a client-sent amount — recompute server-side from the cart order
    const { data: cartOrder, error: orderErr } = await supabase
      .from("orders")
      .select("id, total_amount, user_id")
      .eq("id", cartOrderId)
      .single();

    if (orderErr || !cartOrder || cartOrder.user_id !== userId) {
      return new Response(JSON.stringify({ error: "invalid order" }), { status: 400 });
    }

    // Ask FamGateway for a payment session
    const fgRes = await fetch(
      `${FAMGATEWAY_BASE}/qr.php?upi=${encodeURIComponent(Deno.env.get("FAM_RECEIVER_VPA")!)}` +
      `&amount=${cartOrder.total_amount}&api_key=${Deno.env.get("FAMGATEWAY_API_KEY")}`
    );
    const fgData = await fgRes.json();
    // fgData: { order_id, qr_url, payable_amount }

    const { data: paymentRow, error: insertErr } = await supabase
      .from("dev_payments")
      .insert({
        order_id: fgData.order_id,
        user_id: userId,
        cart_order_id: cartOrder.id,
        requested_amount: cartOrder.total_amount,
        payable_amount: fgData.payable_amount,
        upi_vpa: Deno.env.get("FAM_RECEIVER_VPA"),
        status: "pending",
      })
      .select()
      .single();

    if (insertErr) {
      return new Response(JSON.stringify({ error: insertErr.message }), { status: 500 });
    }

    // Build the raw UPI intent string for the client to fire at the user's
    // "Recommended" app (per companion doc's detection logic) instead of
    // just showing FamGateway's own QR/hosted page.
    const upiIntent =
      `upi://pay?pa=${encodeURIComponent(Deno.env.get("FAM_RECEIVER_VPA")!)}` +
      `&pn=BlinkitClone` +
      `&am=${fgData.payable_amount}` +
      `&tn=Order_${fgData.order_id}` +
      `&cu=INR`;

    return new Response(
      JSON.stringify({
        orderId: fgData.order_id,
        payableAmount: fgData.payable_amount,
        upiIntent,
        qrUrl: fgData.qr_url, // fallback for desktop/no-UPI-app testing
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
```

---

## 5. Step 4 — Edge Function: `payment-webhook`

```
supabase/functions/payment-webhook/index.ts
```

```typescript
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { crypto } from "https://deno.land/std/crypto/mod.ts";

serve(async (req) => {
  const rawBody = await req.text();
  const signature = req.headers.get("x-famgateway-signature") ?? "";

  // Verify the payload actually came from FamGateway, not a spoofed POST.
  // (Check FamGateway's docs for their exact signing scheme — HMAC-SHA256
  // over the raw body with your FAMGATEWAY_WEBHOOK_SECRET is their documented
  // approach; adjust the comparison to match their header format exactly.)
  const expectedSig = await hmacSha256Hex(
    Deno.env.get("FAMGATEWAY_WEBHOOK_SECRET")!,
    rawBody
  );
  if (signature !== expectedSig) {
    return new Response(JSON.stringify({ error: "bad signature" }), { status: 401 });
  }

  const payload = JSON.parse(rawBody);
  const { order_id, status, utr, sender_name, amount } = payload;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Idempotent, single-row, indexed UPDATE — this is the hot path, keep it minimal.
  // Only flip pending -> paid; never overwrite an already-settled row (protects
  // against duplicate webhook delivery).
  const { data, error } = await supabase
    .from("dev_payments")
    .update({
      status: status === "success" ? "paid" : "failed",
      utr,
      sender_name,
      paid_at: new Date().toISOString(),
    })
    .eq("order_id", order_id)
    .eq("status", "pending") // guards against double-processing
    .select("cart_order_id")
    .single();

  if (error || !data) {
    // Either already processed, or unknown order — return 200 anyway so
    // FamGateway doesn't retry-storm you; log for investigation instead.
    console.error("webhook update miss", order_id, error);
    return new Response(JSON.stringify({ received: true }), { status: 200 });
  }

  // Fire-and-forget: queue order confirmation (FCM push) rather than doing it
  // synchronously here, so the webhook responds fast and FamGateway doesn't
  // time out / retry.
  await supabase.from("notification_queue").insert({
    type: "order_paid",
    order_id: data.cart_order_id,
  });

  return new Response(JSON.stringify({ received: true }), { status: 200 });
});

async function hmacSha256Hex(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  return Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
```

Set this function's URL as the webhook target in the FamGateway dashboard (back to Section 2, step 5).

---

## 6. Performance: making confirmation feel instant

FamGateway's own docs claim ~3–5s from payment to webhook, via IMAP **IDLE** (a push-based IMAP mode where the server notifies the client of new mail immediately, instead of the client polling its inbox every N seconds) — that's the best-case latency of the piece you don't control. Everything below is about not adding any latency on top of that:

1. **Subscribe to Realtime before the payment even starts.** Open the `dev_payments` Realtime channel filtered to the user the moment the Payment page mounts (you don't have an `order_id` yet, so subscribe broadly to `user_id = auth.uid()` and narrow the client-side listener once you have the `order_id` back from `create-payment-order`). This removes WebSocket handshake time from the critical path between "user pays" and "you see success."
2. **Filter the Realtime subscription precisely** once you have the `order_id`, so you're not re-rendering on unrelated rows:
   ```dart
   supabase
     .from('dev_payments')
     .stream(primaryKey: ['id'])
     .eq('order_id', orderId)
     .listen((rows) { ... });
   ```
3. **Dual-path confirmation, not webhook-only.** Run a lightweight client-side poll of a `payment-status` Edge Function (which just does a `select status from dev_payments where order_id = $1`) every 2s **in parallel** with the Realtime subscription, for up to ~30s. Whichever arrives first wins — this protects you from the rare case where a Realtime message is dropped (network blip) without falling back to slow polling as your primary mechanism.
4. **Keep the webhook handler's DB write to one indexed UPDATE.** Don't do the FCM send, analytics event, or anything non-critical synchronously inside `payment-webhook` — queue it (see `notification_queue` insert above) and let a separate, non-latency-sensitive function process it. This keeps the webhook's response time low, which matters because FamGateway will retry (and cause duplicate-processing risk) if your webhook is slow to respond.
5. **Pre-empt Deno cold starts.** Supabase Edge Functions can have a cold-start delay on infrequent invocation. If demo-day latency matters, hit `payment-webhook` and `create-payment-order` with a harmless health-check ping every few minutes (e.g. a scheduled GitHub Action or `pg_cron` job calling a `/health` route) to keep the function instance warm. Not necessary at real traffic volumes, useful specifically for a low-traffic demo.
6. **Show optimistic UI immediately after intent launch**, don't wait in a blank state: as soon as the UPI app is launched, show a "Confirming your payment…" screen (Section 7 below has the full widget) so the 3–5s gap has something reassuring on screen rather than feeling stuck.

---

## 7. Flutter: launch payment, listen, and show success

### 7a. Trigger + listen

```dart
// features/checkout/payment_controller.dart
class PaymentController {
  final supabase = Supabase.instance.client;
  StreamSubscription? _sub;

  Future<void> payAndListen({
    required String cartOrderId,
    required BuildContext context,
  }) async {
    // 1. Create the order server-side
    final res = await supabase.functions.invoke('create-payment-order',
        body: {'cartOrderId': cartOrderId});
    final data = res.data as Map<String, dynamic>;
    final orderId = data['orderId'] as String;
    final upiIntent = data['upiIntent'] as String;

    // 2. Start listening BEFORE launching the UPI app (subscription is
    //    already warm from Payment-page mount; this just narrows the filter)
    _sub = supabase
        .from('dev_payments')
        .stream(primaryKey: ['id'])
        .eq('order_id', orderId)
        .listen((rows) {
      if (rows.isEmpty) return;
      final status = rows.first['status'];
      if (status == 'paid') {
        _sub?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
      } else if (status == 'failed') {
        _sub?.cancel();
        // show failure UI
      }
    });

    // 3. Launch the recommended UPI app with the intent (see companion doc's
    //    UpiAppService.getRecommendedApp() for choosing which app to target)
    final recommendedApp = await UpiAppService().getRecommendedApp();
    if (recommendedApp != null) {
      await UpiPay().initiateTransaction(
        app: recommendedApp,
        receiverUpiId: Uri.parse(upiIntent).queryParameters['pa']!,
        receiverName: 'BlinkitClone',
        transactionRefId: orderId,
        transactionNote: 'Order_$orderId',
        amount: double.parse(Uri.parse(upiIntent).queryParameters['am']!),
      );
    }

    // 4. Show "Confirming your payment…" screen while we wait
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ConfirmingPaymentScreen()),
    );
  }
}
```

### 7b. "Confirming your payment…" holding screen

```dart
class ConfirmingPaymentScreen extends StatelessWidget {
  const ConfirmingPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48, height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text('Confirming your payment…',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('This usually takes a few seconds',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

### 7c. Success animation (original, no external assets)

A self-contained checkmark-draw + scale-bounce + soft radial burst, in the spirit of the "payment success" micro-interaction pattern common to UPI apps — built from scratch with `CustomPainter`, no copied assets or third-party Lottie files (avoids any asset-licensing concerns).

```dart
// core/widgets/payment_success_animation.dart
import 'dart:math';
import 'package:flutter/material.dart';

class PaymentSuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  const PaymentSuccessAnimation({super.key, this.onComplete});

  @override
  State<PaymentSuccessAnimation> createState() => _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _burstProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Circle pops in first (0–40% of timeline)
    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    // Checkmark draws in next (30–70%)
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    // Soft radial burst plays alongside the checkmark finishing (50–100%)
    _burstProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF16A34A); // matches the app's existing green CTA color
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: _SuccessPainter(
              circleScale: _circleScale.value,
              checkProgress: _checkProgress.value,
              burstProgress: _burstProgress.value,
              color: green,
            ),
          ),
        );
      },
    );
  }
}

class _SuccessPainter extends CustomPainter {
  final double circleScale;
  final double checkProgress;
  final double burstProgress;
  final Color color;

  _SuccessPainter({
    required this.circleScale,
    required this.checkProgress,
    required this.burstProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Radial burst (short rays fading outward)
    if (burstProgress > 0) {
      final rayPaint = Paint()
        ..color = color.withOpacity((1 - burstProgress) * 0.6)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi;
        final start = center + Offset(cos(angle), sin(angle)) * (radius + 4);
        final end = center +
            Offset(cos(angle), sin(angle)) * (radius + 4 + 14 * burstProgress);
        canvas.drawLine(start, end, rayPaint);
      }
    }

    // Filled circle, scaling in
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(center, radius * circleScale, circlePaint);

    // Checkmark, drawn progressively via a path metric
    if (checkProgress > 0) {
      final checkPath = Path();
      final p1 = center + Offset(-radius * 0.45, 0);
      final p2 = center + Offset(-radius * 0.12, radius * 0.35);
      final p3 = center + Offset(radius * 0.5, -radius * 0.35);
      checkPath.moveTo(p1.dx, p1.dy);
      checkPath.lineTo(p2.dx, p2.dy);
      checkPath.lineTo(p3.dx, p3.dy);

      final metrics = checkPath.computeMetrics().first;
      final extractPath =
          metrics.extractPath(0, metrics.length * checkProgress);

      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(extractPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessPainter oldDelegate) => true;
}
```

### 7d. Success screen wiring it together

```dart
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PaymentSuccessAnimation(
              onComplete: () {
                // e.g. auto-advance to order tracking after a beat
                Future.delayed(const Duration(milliseconds: 600), () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OrderTrackingScreen()),
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Payment successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
```

---

## 8. Testing checklist before a demo/showcase

- [ ] Pay a small real amount (₹1–₹10) from a second phone to confirm the full loop end-to-end at least once before relying on it live
- [ ] Kill and reopen the Flutter app mid-payment (after launching the UPI app, before returning) — confirm the Realtime listener still fires when you relaunch and land back on the confirming screen (re-subscribe on screen re-mount using the stored `order_id`)
- [ ] Deliberately let a payment go unpaid for 2 minutes — confirm you show a timeout/"still waiting, contact support" state instead of hanging forever
- [ ] Confirm the webhook signature check actually rejects a forged POST (send one manually with `curl` and a wrong signature, expect 401)
- [ ] Confirm duplicate webhook delivery (FamGateway retry) doesn't double-fire your FCM notification — the `eq('status', 'pending')` guard in Section 5 should make the second UPDATE a no-op

---

## 9. Migration path to production

When you're ready to onboard real customers beyond your own testing, swap `provider: 'fampay_dev'` for a licensed PA per the companion doc (`payment-collection-recommended-upi.md`, Section 5). Because both flows share the same shape — create-order → webhook → Realtime push → same Flutter success screen — the only things that change are:
- Which Edge Function `create-payment-order` calls out to
- The webhook signature verification scheme
- Swapping the `dev_payments` table for the production `payments` table (or just renaming/repointing)

Everything in Sections 6 and 7 (Realtime pre-subscription, dual-path confirmation, the success animation) carries over unchanged.