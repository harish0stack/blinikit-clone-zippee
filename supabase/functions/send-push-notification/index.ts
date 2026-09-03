// supabase/functions/send-push-notification/index.ts
// Phase 7 — Supabase Edge Function to dispatch FCM v1 System Push Notifications
// Uses EdgeRuntime.waitUntil for instant HTTP response (<50ms) and background 15s execution
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Convert PEM string to WebCrypto CryptoKey for RS256 signing
async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const cleanPem = pem
    .replace(/-----BEGIN [A-Z ]+-----/, "")
    .replace(/-----END [A-Z ]+-----/, "")
    .replace(/\s+/g, "");
  const binaryDer = Uint8Array.from(atob(cleanPem), (c) => c.charCodeAt(0));

  return await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );
}

// Generate Google OAuth2 Access Token for FCM v1 API
async function getGoogleOAuthAccessToken(serviceAccount: any): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const encodeBase64Url = (obj: any) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  const unsignedToken = `${encodeBase64Url(header)}.${encodeBase64Url(claimSet)}`;

  const privateKey = await importPrivateKey(serviceAccount.private_key);
  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(unsignedToken),
  );

  const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBuffer)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${unsignedToken}.${signature}`;

  // Exchange JWT for OAuth2 bearer token
  const tokenResp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenResp.json();
  if (!tokenResp.ok || !tokenData.access_token) {
    throw new Error(`Failed to obtain Google access token: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

// Send push notification through FCM v1 HTTP API
async function sendFcmMessage(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  dataPayload?: Record<string, string>,
) {
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const response = await fetch(fcmUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token: token,
        notification: {
          title,
          body,
        },
        android: {
          priority: "HIGH",
          notification: {
            channel_id: "blinkit_notifications",
            sound: "default",
            default_sound: true,
            default_vibrate_timings: true,
            notification_priority: "PRIORITY_HIGH",
          },
        },
        data: dataPayload ?? {},
      },
    }),
  });

  const resJson = await response.json();
  return { status: response.status, data: resJson };
}

serve(async (req: Request) => {
  // CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const rawSecret = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
    if (!rawSecret) {
      return new Response(
        JSON.stringify({ error: "FCM_SERVICE_ACCOUNT_JSON not set in Supabase secrets" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const serviceAccount = JSON.parse(rawSecret);
    const reqBody = await req.json().catch(() => ({}));
    const {
      token,
      type = "delayed_offer",
      delaySeconds = 0,
      title,
      content,
    } = reqBody;

    if (!token) {
      return new Response(
        JSON.stringify({ error: "Missing required 'token' parameter" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    let notifTitle = title;
    let notifBody = content;

    if (!notifTitle || !notifBody) {
      if (type === "welcome") {
        notifTitle = "Welcome to Blinkit ⚡";
        notifBody = "India's last minute app! Groceries delivered to your doorstep in 14 minutes.";
      } else {
        notifTitle = "⚡ 70% Flat OFF Available!";
        notifBody = "Your favorite snacks & groceries are waiting with exclusive deals. Tap to claim!";
      }
    }

    // Task that sends the notification
    const dispatchTask = async () => {
      try {
        if (delaySeconds > 0) {
          console.log(`[Push Background] Waiting ${delaySeconds}s before dispatch...`);
          await new Promise((resolve) => setTimeout(resolve, delaySeconds * 1000));
        }

        const accessToken = await getGoogleOAuthAccessToken(serviceAccount);
        const result = await sendFcmMessage(
          accessToken,
          serviceAccount.project_id,
          token,
          notifTitle,
          notifBody,
          {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            type: type,
          },
        );
        console.log(`[Push Background] Result for ${token.substring(0, 10)}: HTTP ${result.status}`);
      } catch (e) {
        console.error(`[Push Background Error]:`, e);
      }
    };

    // If delay > 0 and EdgeRuntime.waitUntil is available:
    // Respond to phone in ~20ms so connection drops don't cancel execution!
    // @ts-ignore
    if (typeof EdgeRuntime !== "undefined" && EdgeRuntime.waitUntil) {
      // @ts-ignore
      EdgeRuntime.waitUntil(dispatchTask());
      return new Response(
        JSON.stringify({ success: true, scheduled: true, delaySeconds }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    } else {
      // Direct execution fallback
      await dispatchTask();
      return new Response(
        JSON.stringify({ success: true, delivered: true }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
  } catch (err: any) {
    console.error(`[Push] Error:`, err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
