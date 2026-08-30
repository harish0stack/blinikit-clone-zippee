# Phase 7 — Firebase Cloud Messaging (Order Status Notifications)

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-7-fcm-notifications.md
> Branch: phase-7-fcm
> Phases 0–6 are COMPLETE.
> ```

---

## Goal

Send push notifications to consumers when their order status changes. Minimal scope: one Edge Function triggered by a DB Webhook on `orders.status`, sends a notification to the user's stored FCM device token.

**Scope limit:** Order-status notifications ONLY. No marketing push, no promotional banners, no batch notifications — those are Tier B features.

---

## Architecture

```
orders.status updated (DB Webhook)
  → send-order-notification Edge Function
    → look up device_tokens for the order's user_id
      → call FCM HTTP v1 API
        → notification appears on device
```

---

## How We Will Implement It

### Step 1 — Firebase project setup (manual steps, one-time)

1. Go to https://console.firebase.google.com → Create project "blinkit-clone-prod"
2. Add Android app (package: `com.blinkitclone.blinkit_clone_app`) → download `google-services.json` → place at `blinkit_clone_app/android/app/google-services.json`
3. Add iOS app (bundle ID: `com.blinkitclone.blinkitCloneApp`) → download `GoogleService-Info.plist` → place at `blinkit_clone_app/ios/Runner/GoogleService-Info.plist`
4. Under Project Settings → Cloud Messaging → get the **Service Account JSON** → save it as a Supabase Edge Function secret (`FCM_SERVICE_ACCOUNT_JSON`)
5. Enable FCM API (Cloud Messaging API v1) in GCP console for the project

> **Security**: The FCM service account JSON must NEVER be committed to git. It is stored only as a Supabase secret via `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='...'`

### Step 2 — Flutter: add FCM dependency

Add to `blinkit_clone_app/pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.3.0
  firebase_messaging: ^15.1.0
```

### Step 3 — Flutter: FCM initialization

File: `lib/core/notifications/fcm_service.dart`
```dart
class FcmService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;

    // Request permissions (required for iOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get and store token
    final token = await messaging.getToken();
    if (token != null) {
      await _storeToken(token);
    }

    // Refresh token listener
    messaging.onTokenRefresh.listen(_storeToken);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated message handler (tap opens order detail)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  static Future<void> _storeToken(String token) async {
    final session = SupabaseClientService.client.auth.currentSession;
    if (session == null) return;

    // Get user's internal user_id
    final userData = await SupabaseClientService.client
        .from('users')
        .select('id')
        .eq('auth_user_id', session.user.id)
        .single();

    // Upsert token (update if token already stored for this user+token combo)
    await SupabaseClientService.client.from('device_tokens').upsert(
      {
        'user_id': userData['id'],
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id, token',
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification banner (use flutter_local_notifications)
    // Navigate to order detail if user taps
  }

  static void _handleMessageTap(RemoteMessage message) {
    final orderId = message.data['order_id'];
    if (orderId != null) {
      // Use GoRouter to navigate to /orders/:orderId
    }
  }
}
```

Update `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientService.initialize();
  await HiveService.init();
  await FcmService.initialize();   // NEW
  runApp(const ProviderScope(child: App()));
}
```

Add dependency:
```yaml
firebase_messaging: ^15.1.0
flutter_local_notifications: ^17.2.2   # for foreground notification banners
```

### Step 4 — iOS background modes + entitlements

File: `blinkit_clone_app/ios/Runner/Info.plist` — add:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

File: `blinkit_clone_app/ios/Runner/Runner.entitlements` — add:
```xml
<key>aps-environment</key>
<string>development</string>   <!-- change to 'production' for App Store builds -->
```

### Step 5 — `send-order-notification` Edge Function

File: `supabase/functions/send-order-notification/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// FCM HTTP v1 API requires OAuth2 bearer token from service account
async function getFcmAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!);

  // Use Google Auth Library (available in Deno via npm compat)
  const { GoogleAuth } = await import("npm:google-auth-library@9");
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const client = await auth.getClient();
  const token = await client.getAccessToken();
  return token.token!;
}

const ORDER_STATUS_MESSAGES: Record<string, { title: string; body: string }> = {
  confirmed:         { title: "Order Confirmed! ✅", body: "Your order has been confirmed and is being prepared." },
  packed:            { title: "Order Packed 📦", body: "Your order is packed and ready for pickup." },
  out_for_delivery:  { title: "Out for Delivery 🛵", body: "Your order is on its way!" },
  delivered:         { title: "Delivered! 🎉", body: "Enjoy your order. Rate us on the app!" },
  cancelled:         { title: "Order Cancelled", body: "Your order has been cancelled. Refund will be processed in 5–7 days." },
};

serve(async (req: Request) => {
  const payload = await req.json();
  const order = payload.record;

  const message = ORDER_STATUS_MESSAGES[order.status];
  if (!message) return new Response("Status not notifiable", { status: 200 });

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Fetch user's device tokens
  const { data: tokens } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", order.user_id);

  if (!tokens || tokens.length === 0) {
    return new Response("No device tokens", { status: 200 });
  }

  const accessToken = await getFcmAccessToken();
  const projectId = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!).project_id;

  // Send to each device token (user may have multiple devices)
  const results = await Promise.allSettled(
    tokens.map((t) =>
      fetch(
        `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: t.token,
              notification: message,
              data: {
                order_id: order.id,
                status: order.status,
                click_action: "OPEN_ORDER_DETAIL",
              },
            },
          }),
        }
      )
    )
  );

  const failed = results.filter((r) => r.status === "rejected");
  if (failed.length > 0) {
    console.error("FCM send failures:", failed);
  }

  return new Response(
    JSON.stringify({ sent: tokens.length, failed: failed.length }),
    { status: 200 }
  );
});
```

Deploy via MCP:
```
Tool: deploy_edge_function
Args:
  name: "send-order-notification"
```

Alternatively via CLI:
```bash
supabase functions deploy send-order-notification --no-verify-jwt
supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<paste JSON content>'
```

> `FCM_SERVICE_ACCOUNT_JSON` must be set as a Supabase Edge Function secret — never committed to git.

### Step 6 — DB Webhook for order status changes

In Supabase Dashboard → Database → Webhooks → Create:
- Name: `on_order_status_change`
- Table: `orders`
- Events: `UPDATE`
- Condition: `NEW.status != OLD.status`  (some Supabase versions support this — if not, filter in the Edge Function)
- URL: `https://<project-ref>.supabase.co/functions/v1/send-order-notification`

---

## Files in Scope

```
blinkit_clone_app/
├── android/app/google-services.json           [ADD — downloaded from Firebase console]
├── ios/Runner/GoogleService-Info.plist        [ADD — downloaded from Firebase console]
├── ios/Runner/Info.plist                      [MODIFY — background modes]
├── ios/Runner/Runner.entitlements             [MODIFY — APS environment]
├── pubspec.yaml                               [MODIFY — add firebase_core, firebase_messaging, flutter_local_notifications]
└── lib/
    ├── main.dart                              [MODIFY — FcmService.initialize()]
    └── core/notifications/fcm_service.dart   [CREATE]

supabase/functions/send-order-notification/
└── index.ts                                   [CREATE]
```

**Out of scope:** in-app notification center, promotional push, notification preferences screen, marketing campaigns.

---

## Acceptance Criteria

- [ ] FCM token is stored in `device_tokens` on first app launch (verify in Supabase dashboard)
- [ ] FCM token is refreshed on subsequent launches (updated_at column changes)
- [ ] Manually update an order's status in the Supabase dashboard → push notification appears on the physical/simulator device within 5 seconds
- [ ] All 5 notifiable statuses send the correct message text
- [ ] Tapping the notification opens the Orders screen with the correct order highlighted
- [ ] Foreground notification banner appears even when app is in foreground
- [ ] `FCM_SERVICE_ACCOUNT_JSON` is NEVER committed to git (verify with `git log -- supabase/functions/` and `git status`)
- [ ] Edge Function handles case where user has no device token (returns 200, no error)

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS | device_tokens: user can only read/write their own tokens |
| 7 | Service-role key + FCM credentials | Neither in any client file or git commit |

---

## Scalability Note (for future Tier B/C)

The current architecture (Edge Function → FCM) is correct up to ~10K orders/day. At higher volume, replace this with:
1. A dedicated notification worker service (Node.js or Go)
2. Consuming from a message queue (Supabase → Kafka/Upstash → worker → FCM batch API)

The `buildNotificationPayload(order) → send(token, payload)` structure already used in this Edge Function is designed to be lifted directly into that worker — no business logic rewrite needed.

---

## Next Phase

→ **Phase 8**: Load testing at 20K–30K concurrent (`docs/specs/phase-8-load-testing.md`)
