import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const BUCKET_NAME = 'hicode_assets';

// Klien Admin (Wajib SERVICE_ROLE)
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

/**
 * Helper untuk mengekstrak file path dari URL Supabase Storage
 */
function getPathFromUrl(url: string | null | undefined): string | null {
  if (!url) return null;
  try {
    const parsedUrl = new URL(url);
    const pathSegments = parsedUrl.pathname.split('/');
    const bucketIndex = pathSegments.indexOf(BUCKET_NAME);
    if (bucketIndex === -1 || bucketIndex === pathSegments.length - 1) {
      return null;
    }
    return pathSegments.slice(bucketIndex + 1).join('/');
  } catch (e) {
    console.error(`URL tidak valid: ${url}`, e);
    return null;
  }
}

/**
 * Helper untuk secara rekursif mencari semua URL gambar/video
 * di dalam JSONB konten (Quill Delta)
 */
function extractUrlsFromJson(content: any): Set<string> {
  const urls = new Set<string>();

  function traverse(node: any) {
    if (Array.isArray(node)) {
      for (const item of node) {
        traverse(item);
      }
    } else if (typeof node === 'object' && node !== null) {
      if (node.insert && typeof node.insert === 'object') {
        const insert = node.insert;
        if (insert.image && typeof insert.image === 'string') {
          urls.add(insert.image);
        }
        if (insert.video && typeof insert.video === 'string') {
          urls.add(insert.video);
        }
      } else {
        for (const key in node) {
          traverse(node[key]);
        }
      }
    }
  }

  traverse(content);
  return urls;
}

/**
 * Fungsi utama untuk mengekstrak semua URL dari satu record
 */
function getAllUrls(record: any): Set<string> {
  const urls = new Set<string>();

  if (record.image_url && typeof record.image_url === 'string') {
    urls.add(record.image_url);
  }
  if (record.icon_url && typeof record.icon_url === 'string') {
    urls.add(record.icon_url);
  }
  if (record.content) {
    extractUrlsFromJson(record.content).forEach(url => urls.add(url));
  }
  
  return urls;
}

// --- MAIN SERVER LOGIC ---

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  try {
    const payload = await req.json();

    // Event INSERT tidak perlu menghapus apa-apa
    if (payload.type === 'INSERT') {
      return new Response('Event INSERT, tidak ada file yang dihapus.', { status: 200 });
    }

    // Kita wajib punya old_record untuk tahu apa yang harus dihapus
    if (!payload.old_record) {
      return new Response('Tidak ada data lama (old_record).', { status: 200 });
    }

    // 1. Dapatkan semua URL dari data LAMA
    const oldUrls = getAllUrls(payload.old_record);
    let newUrls = new Set<string>();

    // 2. Jika ini UPDATE, dapatkan semua URL dari data BARU
    if (payload.type === 'UPDATE' && payload.record) {
      newUrls = getAllUrls(payload.record);
    }
    
    // 3. Tentukan file yang akan dihapus:
    //    (File yang ada di OLD) DIKURANGI (File yang ada di NEW)
    const urlsToDelete = new Set<string>();
    for (const url of oldUrls) {
      if (!newUrls.has(url)) {
        // URL ini ada di data lama, tapi tidak ada di data baru. HAPUS!
        urlsToDelete.add(url);
      }
    }

    if (urlsToDelete.size === 0) {
      return new Response('Tidak ada file yatim yang perlu dihapus.', { status: 200 });
    }

    // 4. Ubah URL menjadi file path
    const filePaths = Array.from(urlsToDelete)
      .map(getPathFromUrl)
      .filter((path): path is string => path !== null); // Filter null/invalid

    if (filePaths.length === 0) {
      return new Response('URL tidak valid atau tidak cocok dengan bucket.', { status: 200 });
    }

    // 5. Hapus file dari Storage
    console.log(`Mencoba menghapus ${filePaths.length} file yatim...`);
    console.log(filePaths);

    const { data, error } = await supabaseAdmin.storage
      .from(BUCKET_NAME)
      .remove(filePaths);

    if (error) {
      console.error('Supabase Storage Error:', error.message);
      return new Response(`Gagal menghapus file: ${error.message}`, { status: 500 });
    }

    return new Response(JSON.stringify({ success: true, removed: data }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (err) {
    console.error('Function Error:', err.message);
    return new Response(`Internal Server Error: ${err.message}`, { status: 500 });
  }
});