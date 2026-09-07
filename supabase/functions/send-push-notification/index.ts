// supabase/functions/send-push-notification/index.ts
// Supabase Edge Function: Real-time Vendor Product Push Notification Dispatcher
// Dispatches high-priority FCM v1 push notifications to all consumer devices when a vendor publishes a product.
// Delivered via Google Play Services / Apple APNs even when the consumer app is killed/terminated.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

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

// Send high-priority push notification through FCM v1 HTTP API
// Configured with high priority and system notification headers so it is delivered even when app is killed
async function sendFcmMessage(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  imageUrl?: string,
  dataPayload?: Record<string, string>,
) {
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  
  const message: Record<string, any> = {
    token: token,
    notification: {
      title,
      body,
      ...(imageUrl ? { image: imageUrl } : {}),
    },
    android: {
      priority: "HIGH",
      notification: {
        channel_id: "blinkit_notifications",
        sound: "default",
        default_sound: true,
        default_vibrate_timings: true,
        notification_priority: "PRIORITY_HIGH",
        visibility: "PUBLIC",
        ...(imageUrl ? { image: imageUrl } : {}),
      },
    },
    apns: {
      headers: {
        "apns-priority": "10",
        "apns-push-type": "alert",
      },
      payload: {
        aps: {
          alert: {
            title,
            body,
          },
          sound: "default",
          badge: 1,
          "content-available": 1,
        },
      },
      ...(imageUrl ? { fcm_options: { image: imageUrl } } : {}),
    },
    data: dataPayload ?? {},
  };

  const response = await fetch(fcmUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ message }),
  });

  const resJson = await response.json();
  return { status: response.status, data: resJson };
}

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const rawSecret = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
    if (!rawSecret) {
      return new Response(
        JSON.stringify({ error: "FCM_SERVICE_ACCOUNT_JSON secret not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const serviceAccount = JSON.parse(rawSecret);

    // Initialize Supabase admin client for data lookups
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseKey);

    const reqBody = await req.json().catch(() => ({}));

    // Support both direct invocation and Database Webhook payloads (type: 'INSERT' / record)
    const record = reqBody.record || reqBody.product || {};
    const productId = reqBody.productId || record.id;
    let productName = reqBody.productName || record.name;
    let vendorName = reqBody.vendorName || reqBody.vendorBusinessName;
    let sellingPrice = reqBody.sellingPrice ?? reqBody.price ?? record.selling_price;
    let unit = reqBody.unit || record.unit || "1 pack";
    let imageUrl = reqBody.imageUrl || record.image_url;
    const directToken = reqBody.token;

    // If productId is provided without full details, fetch from database
    if (productId && (!productName || !vendorName || sellingPrice === undefined || !imageUrl)) {
      const { data: productData } = await supabase
        .from("products")
        .select(`
          id, name, unit, selling_price, mrp, vendor_id,
          vendors ( business_name, name ),
          product_images ( webp_url, is_primary )
        `)
        .eq("id", productId)
        .maybeSingle();

      if (productData) {
        productName = productName || productData.name;
        sellingPrice = sellingPrice ?? productData.selling_price;
        unit = unit || productData.unit || "1 pack";
        vendorName =
          vendorName ||
          productData.vendors?.business_name ||
          productData.vendors?.name ||
          "Blinkit Store";

        if (!imageUrl && productData.product_images && productData.product_images.length > 0) {
          const primary = productData.product_images.find((img: any) => img.is_primary) || productData.product_images[0];
          imageUrl = primary?.webp_url;
        }
      }
    }

    vendorName = vendorName || "Partner Store";
    productName = productName || "New Product";
    const priceStr = sellingPrice !== undefined ? `₹${sellingPrice}` : "";

    // Construct the requested notification message:
    // Format: "{vendor business name} uploaded {product name} with {price} - Available now"
    const notifTitle = `🛍️ ${vendorName} • Available now!`;
    const notifBody = `${productName}${priceStr ? ` at ${priceStr}` : ""}${unit ? ` (${unit})` : ""} is now available for 10-minute delivery.`;

    console.log(`[Push Dispatch] Preparing push for: "${productName}" from "${vendorName}" at ${priceStr}`);

    const dataPayload: Record<string, string> = {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      type: "new_product_upload",
      productId: productId ? String(productId) : "",
      productName: String(productName),
      vendorName: String(vendorName),
      price: String(sellingPrice ?? ""),
      unit: String(unit),
      status: "available_now",
      ...(imageUrl ? { imageUrl: String(imageUrl) } : {}),
    };

    // Task that dispatches push notifications to target tokens
    const dispatchTask = async () => {
      try {
        const accessToken = await getGoogleOAuthAccessToken(serviceAccount);

        let tokensToSend: string[] = [];

        if (directToken) {
          tokensToSend = [directToken];
        } else {
          // Fetch all registered consumer device tokens from database
          const { data: deviceTokens, error: tokenError } = await supabase
            .from("device_tokens")
            .select("token");

          if (tokenError) {
            console.error("[Push] Error fetching device tokens:", tokenError);
          } else if (deviceTokens && deviceTokens.length > 0) {
            tokensToSend = deviceTokens.map((d: any) => d.token).filter(Boolean);
          }
        }

        console.log(`[Push] Dispatching to ${tokensToSend.length} device(s)...`);

        // Send to all device tokens concurrently
        const results = await Promise.allSettled(
          tokensToSend.map((t) =>
            sendFcmMessage(
              accessToken,
              serviceAccount.project_id,
              t,
              notifTitle,
              notifBody,
              imageUrl,
              dataPayload,
            ),
          ),
        );

        const succeeded = results.filter((r) => r.status === "fulfilled" && (r as any).value?.status === 200).length;
        console.log(`[Push] Finished dispatch: ${succeeded}/${tokensToSend.length} succeeded.`);
      } catch (err) {
        console.error(`[Push Background Error]:`, err);
      }
    };

    // @ts-ignore
    if (typeof EdgeRuntime !== "undefined" && EdgeRuntime.waitUntil) {
      // @ts-ignore
      EdgeRuntime.waitUntil(dispatchTask());
      return new Response(
        JSON.stringify({
          success: true,
          dispatched: true,
          productName,
          vendorName,
          sellingPrice,
          title: notifTitle,
          body: notifBody,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    } else {
      await dispatchTask();
      return new Response(
        JSON.stringify({
          success: true,
          dispatched: true,
          productName,
          vendorName,
          sellingPrice,
          title: notifTitle,
          body: notifBody,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
  } catch (err: any) {
    console.error(`[Push] Fatal Error:`, err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
