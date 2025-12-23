import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { create, getNumericDate } from "https://deno.land/x/djwt@v2.2/mod.ts";

// --- (Fungsi getAccessToken yang sudah kita buat sebelumnya bisa disalin ke sini) ---
async function getAccessToken() {
  const serviceAccountRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!serviceAccountRaw) throw new Error("Secret 'FIREBASE_SERVICE_ACCOUNT' not found.");
  
  const serviceAccount = JSON.parse(serviceAccountRaw);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: getNumericDate(3600),
    iat: getNumericDate(0),
  };
  
  const jwt = await create(header, payload, serviceAccount.private_key);

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const data = await response.json();
  if (!response.ok) throw new Error(`Gagal mendapatkan access token: ${data.error_description || JSON.stringify(data)}`);
  return data.access_token;
}


// --- Fungsi Utama Edge Function ---
Deno.serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey',
  };
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  
  try {
    const payload = await req.json();
    // Ambil data undangan baru dari payload webhook
    const invitation = payload.record;

    // Pastikan ini adalah undangan personal, bukan undangan via link atau role
    if (!invitation || invitation.invitation_type !== 'personal' || !invitation.invitee_id) {
      return new Response(JSON.stringify({ message: "Not a personal invitation, skipping." }), { status: 200, headers: corsHeaders });
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );
    
    // Ambil data lengkap pengundang dan pengguna yang diundang
    const { data: inviterData, error: inviterError } = await supabaseClient.from('users').select('full_name').eq('id', invitation.inviter_id).single();
    const { data: inviteeData, error: inviteeError } = await supabaseClient.from('users').select('fcm_token').eq('id', invitation.invitee_id).single();
    const { data: workspaceData, error: workspaceError } = await supabaseClient.from('user_workspace').select('title').eq('id', invitation.workspace_id).single();

    if (inviterError || inviteeError || workspaceError) throw new Error("Failed to fetch user or workspace data.");
    
    const fcmToken = inviteeData.fcm_token;
    if (!fcmToken) {
      console.log(`User ${invitation.invitee_id} does not have an FCM token.`);
      return new Response(JSON.stringify({ message: "User has no FCM token." }), { status: 200, headers: corsHeaders });
    }

    const accessToken = await getAccessToken();
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!;
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    
    const message = {
      message: {
        token: fcmToken,
        notification: {
          title: 'HiAgenda: Undangan Workspace Baru!',
          body: `${inviterData.full_name} mengundang Anda untuk bergabung ke workspace "${workspaceData.title}".`,
        },
        // Data payload ini bisa digunakan di aplikasi untuk navigasi
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "/notifications" // Arahkan ke halaman notifikasi
        },
        android: {
          notification: {
            sound: 'default',
            color: '#0175C8',
          }
        }
      }
    };
    
    await fetch(fcmUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify(message),
    });

    console.log(`Sent invitation notification to user ${invitation.invitee_id}`);

    return new Response(JSON.stringify({ message: "Invitation notification sent." }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (err) {
    console.error("Function error:", err.message);
    return new Response(String(err?.message ?? err), { status: 500, headers: corsHeaders });
  }
});