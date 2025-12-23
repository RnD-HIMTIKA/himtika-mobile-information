import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { create, getNumericDate } from "https://deno.land/x/djwt@v2.2/mod.ts";
// --- Fungsi Helper untuk Otentikasi Firebase ---
async function getAccessToken() {
  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!serviceAccountRaw) {
    throw new Error("Secret 'FIREBASE_SERVICE_ACCOUNT' not found.");
  }
  const serviceAccount = JSON.parse(serviceAccountRaw);
  const header = {
    alg: "RS256",
    typ: "JWT"
  };
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: getNumericDate(3600),
    iat: getNumericDate(0)
  };
  const jwt = await create(header, payload, serviceAccount.private_key);
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(`Gagal mendapatkan access token: ${data.error_description || JSON.stringify(data)}`);
  }
  return data.access_token;
}
// --- Fungsi Utama Edge Function ---
Deno.serve(async (req)=>{
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey'
  };
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL'), Deno.env.get('SUPABASE_SERVICE_ROLE_KEY'));
    const { data: notifications, error } = await supabaseClient.rpc('get_pending_notifications');
    if (error) throw error;
    if (!notifications || notifications.length === 0) {
      console.log("No new notifications to send.");
      return new Response(JSON.stringify({
        message: "No new notifications to send."
      }), {
        status: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }
    console.log(`Found ${notifications.length} notification batch(es) to send.`);
    const accessToken = await getAccessToken();
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID');
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    for (const notif of notifications){
      if (notif.tokens && notif.tokens.length > 0) {
        for (const token of notif.tokens){
          if (!token) continue; // Lewati jika token null
          // PERBAIKAN UTAMA DI SINI:
          // Struktur payload yang benar sesuai dokumentasi FCM HTTP v1.
          const payload = {
            message: {
              token: token,
              notification: {
                title: 'HiAgenda Reminder',
                body: `"${notif.title}" akan segera dimulai. Jangan sampai ketinggalan!`
              },
              android: {
                notification: {
                  sound: 'default',
                  color: '#0175C8',
                  priority: "HIGH"
                }
              }
            }
          };
          const fcmResponse = await fetch(fcmUrl, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify(payload)
          });
          if (fcmResponse.ok) {
            console.log(`Successfully sent notification for event: "${notif.title}" to token: ...${token.slice(-5)}`);
            // JIKA BERHASIL: Catat ke database agar tidak dikirim lagi
            await supabaseClient.from('sent_notifications').insert({
              event_id: notif.event_id,
              notification_time: notif.notification_time
            });
          } else {
            console.error(`FCM error for event "${notif.title}":`, await fcmResponse.text());
          }
        }
      }
    }
    return new Response(JSON.stringify({
      message: "Notification check complete."
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    console.error("Function error:", err.message);
    return new Response(String(err?.message ?? err), {
      status: 500,
      headers: corsHeaders
    });
  }
});
