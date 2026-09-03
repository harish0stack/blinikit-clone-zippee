// supabase/functions/create-payment-order/index.ts
// Creates a FamGateway payment session and stores pending dev_payment record
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const FAMGATEWAY_BASE = "https://famgateway.in/api";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { amount, cartOrderId, upiVpa } = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const apiKey = Deno.env.get("FAMGATEWAY_API_KEY");
    const receiverVpa = upiVpa || Deno.env.get("FAM_RECEIVER_VPA") || "8928560233@ybl";

    const requestedAmount = Number(amount) > 0 ? Number(amount) : 2.00;
    let orderId = `FG_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    let payableAmount = requestedAmount;
    let qrUrl = "";

    // If FamGateway API key is configured, request session from FamGateway API
    if (apiKey) {
      try {
        const fgUrl = `${FAMGATEWAY_BASE}/qr.php?upi=${encodeURIComponent(receiverVpa)}&amount=${requestedAmount}&api_key=${apiKey}`;
        const fgRes = await fetch(fgUrl);
        if (fgRes.ok) {
          const fgData = await fgRes.json();
          if (fgData.order_id) orderId = fgData.order_id;
          if (fgData.payable_amount) payableAmount = Number(fgData.payable_amount);
          if (fgData.qr_url) qrUrl = fgData.qr_url;
        }
      } catch (err) {
        console.error("FamGateway API error, using direct intent fallback:", err);
      }
    }

    // Insert pending payment record
    const { error: insertErr } = await supabase
      .from("dev_payments")
      .insert({
        order_id: orderId,
        cart_order_id: cartOrderId || `ORDER_${Date.now()}`,
        requested_amount: requestedAmount,
        payable_amount: payableAmount,
        upi_vpa: receiverVpa,
        status: "pending",
        provider: "fampay_dev",
      });

    if (insertErr) {
      console.error("DB Insert error:", insertErr);
    }

    // Format fixed-amount UPI intent for FamApp / GPay / PhonePe
    const upiIntent =
      `upi://pay?pa=${encodeURIComponent(receiverVpa)}` +
      `&pn=Blinkit` +
      `&am=${payableAmount.toFixed(2)}` +
      `&tr=${orderId}` +
      `&tn=${encodeURIComponent(`Order_${orderId}`)}` +
      `&cu=INR`;

    return new Response(
      JSON.stringify({
        orderId,
        payableAmount,
        upiIntent,
        qrUrl,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
