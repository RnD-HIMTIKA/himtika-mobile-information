

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."hicode_option_type" AS (
	"id" "uuid",
	"option_text" "text",
	"image_url" "text"
);


ALTER TYPE "public"."hicode_option_type" OWNER TO "postgres";


CREATE TYPE "public"."hicode_question_with_options_type" AS (
	"id" "uuid",
	"question_text" "text",
	"image_url" "text",
	"options" "public"."hicode_option_type"[]
);


ALTER TYPE "public"."hicode_question_with_options_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_invitation_by_id"("p_invitation_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
  invite_record RECORD;
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
BEGIN
  -- 1. Ambil data undangan berdasarkan ID dan pastikan pengguna saat ini adalah yang diundang
  SELECT * INTO invite_record FROM public.workspace_invitations
  WHERE id = p_invitation_id AND invitee_id = current_user_id AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Undangan tidak valid atau sudah tidak berlaku.';
  END IF;

  -- 2. Tambahkan pengguna ke workspace_access
  INSERT INTO public.workspace_access (workspace_id, user_id, role)
  VALUES (invite_record.workspace_id, current_user_id, invite_record.role_to_grant)
  ON CONFLICT DO NOTHING;

  -- 3. Perbarui status undangan menjadi 'accepted'
  UPDATE public.workspace_invitations SET status = 'accepted' WHERE id = p_invitation_id;
END;$$;


ALTER FUNCTION "public"."accept_invitation_by_id"("p_invitation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_invitation_by_token"("p_invitation_token" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  invite_record RECORD;
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
BEGIN
  -- 1. Ambil data undangan berdasarkan TOKEN
  SELECT * INTO invite_record FROM public.workspace_invitations
  WHERE token = p_invitation_token AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Link undangan tidak valid atau sudah kedaluwarsa.';
  END IF;

  -- 2. Tambahkan pengguna ke workspace_access
  INSERT INTO public.workspace_access (workspace_id, user_id, role)
  VALUES (invite_record.workspace_id, current_user_id, invite_record.role_to_grant)
  ON CONFLICT DO NOTHING;

  -- 3. Perbarui status undangan menjadi 'accepted' dan set invitee_id
  UPDATE public.workspace_invitations SET status = 'accepted', invitee_id = current_user_id
  WHERE id = invite_record.id;
END;
$$;


ALTER FUNCTION "public"."accept_invitation_by_token"("p_invitation_token" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."accept_link_invitation"("p_invitation_token" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  invite_record RECORD;
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
BEGIN
  -- 1. Ambil data undangan link berdasarkan TOKEN
  SELECT * INTO invite_record FROM public.workspace_invitations
  WHERE token = p_invitation_token AND invitation_type = 'link' AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Link undangan tidak valid atau sudah tidak berlaku.';
  END IF;

  -- 2. Cek apakah link sudah kedaluwarsa
  IF invite_record.expires_at < now() THEN
    RAISE EXCEPTION 'Link undangan ini sudah kedaluwarsa.';
  END IF;
  
  -- 3. Cek apakah pengguna sudah menjadi anggota
  IF EXISTS (SELECT 1 FROM public.workspace_access WHERE workspace_id = invite_record.workspace_id AND user_id = current_user_id) THEN
    -- Pengguna sudah menjadi anggota, tidak perlu melakukan apa-apa.
    RETURN;
  END IF;

  -- 4. Tambahkan pengguna ke workspace_access
  INSERT INTO public.workspace_access (workspace_id, user_id, role)
  VALUES (invite_record.workspace_id, current_user_id, invite_record.role_to_grant)
  ON CONFLICT DO NOTHING;

  -- Catatan: Kita tidak mengubah status undangan link agar bisa digunakan lagi oleh orang lain.
END;
$$;


ALTER FUNCTION "public"."accept_link_invitation"("p_invitation_token" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_overall_exam_availability"("p_user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  last_exam_time timestamptz;
  start_of_current_week timestamptz;
BEGIN
  -- Tentukan waktu reset global (Senin 00:00 UTC/WIB)
  -- 'week' di PostgreSQL dimulai hari Senin.
  start_of_current_week := date_trunc('week', now());

  -- Cek kapan terakhir kali user mengambil ujian
  SELECT last_exam_timestamp
  INTO last_exam_time
  FROM public.hicode_leaderboard
  WHERE user_id = p_user_id;

  -- Jika user belum pernah ujian (NOT FOUND), dia boleh ikut.
  IF NOT FOUND THEN
    RETURN TRUE;
  END IF;

  -- Jika user pernah ujian, cek apakah waktu ujian terakhirnya
  -- LEBIH LAMA dari (SEBELUM) waktu reset minggu ini.
  -- Contoh:
  -- last_exam_time = Minggu lalu. '2025-11-03' < '2025-11-06' (Senin ini) -> TRUE (Boleh)
  -- last_exam_time = Selasa ini.  '2025-11-07' < '2025-11-06' (Senin ini) -> FALSE (Tunggu)
  RETURN last_exam_time < start_of_current_week;

END;
$$;


ALTER FUNCTION "public"."check_overall_exam_availability"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_for_reset"("p_email" "text") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Cari user di tabel auth.users
  SELECT * INTO user_record
  FROM auth.users
  WHERE email = p_email
  LIMIT 1;

  -- Jika tidak ditemukan sama sekali
  IF NOT FOUND THEN
    RETURN 'not_found';
  END IF;

  -- Cek apakah user memiliki identitas 'email' (pengguna manual)
  -- Pengguna OAuth murni tidak akan memiliki ini.
  IF EXISTS (
    SELECT 1 FROM auth.identities
    WHERE user_id = user_record.id AND provider = 'email'
  ) THEN
    RETURN 'can_reset';
  ELSE
    RETURN 'is_oauth';
  END IF;
END;
$$;


ALTER FUNCTION "public"."check_user_for_reset"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_sent_notifications"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Hapus semua catatan notifikasi yang terhubung ke event
  -- yang waktu mulainya (start_time) sudah lebih dari 1 hari yang lalu.
  -- Jeda 1 hari ini memberikan keamanan jika ada notifikasi yang sedikit terlambat.
  DELETE FROM public.sent_notifications
  WHERE event_id IN (
    SELECT id
    FROM public.events
    WHERE start_time < (now() - interval '1 day')
  );

  -- Catat ke log database (opsional, untuk verifikasi)
  RAISE NOTICE 'Cleanup of sent_notifications table completed.';
END;
$$;


ALTER FUNCTION "public"."cleanup_sent_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_hicode_category"("p_name" "text", "p_icon_url" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO public.hicode_categories(name, icon_url) VALUES (p_name, p_icon_url);
END;
$$;


ALTER FUNCTION "public"."create_hicode_category"("p_name" "text", "p_icon_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_hicode_chapter"("p_material_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    new_order smallint;
BEGIN
  -- Tentukan 'order' secara otomatis
  SELECT COALESCE(MAX("order"), -1) + 1 INTO new_order
  FROM public.hicode_chapters
  WHERE material_id = p_material_id;

  INSERT INTO public.hicode_chapters(material_id, title, content, estimated_read_time, "order")
  VALUES (p_material_id, p_title, p_content, p_estimated_read_time, new_order);
END;
$$;


ALTER FUNCTION "public"."create_hicode_chapter"("p_material_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_hicode_material"("p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO public.hicode_materials(category_id, title, description, image_url, border_color)
  VALUES (p_category_id, p_title, p_description, p_image_url, p_border_color);
END;
$$;


ALTER FUNCTION "public"."create_hicode_material"("p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_hicode_question_with_options"("p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  new_question_id uuid;
  option_data jsonb;
BEGIN
  -- Validasi dasar (tetap sama) ...
  IF NOT (p_question_type = ANY (ARRAY['QUIZ'::text, 'FINAL_PRACTICE'::text, 'OVERALL_EXAM'::text])) THEN RAISE EXCEPTION '...'; END IF;
  IF NOT (p_difficulty = ANY (ARRAY['Mudah'::text, 'Menengah'::text, 'Sulit'::text])) THEN RAISE EXCEPTION '...'; END IF;
  IF p_question_text IS NULL OR trim(p_question_text) = '' THEN RAISE EXCEPTION '...'; END IF;
  IF p_options IS NULL OR jsonb_array_length(p_options) < 2 THEN RAISE EXCEPTION '...'; END IF;
  IF (SELECT count(*) FROM jsonb_array_elements(p_options) opt WHERE (opt->>'is_correct')::boolean = true) <> 1 THEN RAISE EXCEPTION '...'; END IF;

  -- Masukkan ke tabel hicode_questions (tetap sama)
  INSERT INTO public.hicode_questions (related_id, question_type, difficulty, question_text, image_url)
  VALUES (p_related_id, p_question_type, p_difficulty, p_question_text, p_image_url)
  RETURNING id INTO new_question_id;

  -- Masukkan setiap opsi ke tabel hicode_options (dengan image_url)
  FOR option_data IN SELECT * FROM jsonb_array_elements(p_options)
  LOOP
    INSERT INTO public.hicode_options (question_id, option_text, is_correct, image_url) -- Tambah image_url
    VALUES (
      new_question_id,
      option_data->>'option_text',
      (option_data->>'is_correct')::boolean,
      option_data->>'image_url' -- Ambil image_url dari JSON (bisa null)
    );
  END LOOP;

  RETURN new_question_id;
END;
$$;


ALTER FUNCTION "public"."create_hicode_question_with_options"("p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_new_workspace"("p_title" "text", "p_description" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  -- Dapatkan ID internal pengguna yang sedang login
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  new_workspace_id UUID;
BEGIN
  -- Pastikan pengguna yang memanggil fungsi ini memang ada di tabel users
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Pengguna tidak ditemukan.';
  END IF;

  -- 1. Insert workspace baru dan dapatkan ID-nya
  INSERT INTO public.user_workspace (title, description, owner_id)
  VALUES (p_title, p_description, current_user_id)
  RETURNING id INTO new_workspace_id;

  -- 2. Daftarkan si pembuat sebagai 'owner' di tabel akses
  -- Operasi ini juga akan berhasil karena fungsi berjalan sebagai admin
  INSERT INTO public.workspace_access (workspace_id, user_id, role)
  VALUES (new_workspace_id, current_user_id, 'owner');

  -- 3. Kembalikan ID workspace baru
  RETURN new_workspace_id;
END;
$$;


ALTER FUNCTION "public"."create_new_workspace"("p_title" "text", "p_description" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_recurring_event_transaction"("p_workspace_id" "uuid", "p_created_by" "uuid", "p_title" "text", "p_description" "text", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_by_day" "text"[], "p_until_date" timestamp with time zone, "p_reminder_minutes_before" integer[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  new_recurrence_id UUID;
BEGIN
  INSERT INTO public.event_recurrence (frequency, by_day, until_date)
  VALUES ('WEEKLY', p_by_day, p_until_date)
  RETURNING id INTO new_recurrence_id;

  INSERT INTO public.events (workspace_id, created_by, title, description, start_time, end_time, recurrence_id, reminder_minutes_before)
  VALUES (p_workspace_id, p_created_by, p_title, p_description, p_start_time, p_end_time, new_recurrence_id, p_reminder_minutes_before);
END;
$$;


ALTER FUNCTION "public"."create_recurring_event_transaction"("p_workspace_id" "uuid", "p_created_by" "uuid", "p_title" "text", "p_description" "text", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_by_day" "text"[], "p_until_date" timestamp with time zone, "p_reminder_minutes_before" integer[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_workspace_invitation_link"("p_workspace_id" "uuid", "p_role_to_grant" "text", "p_duration_minutes" integer DEFAULT 30) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  new_invitation_token UUID;
BEGIN
  -- 1. Pastikan hanya owner yang bisa membuat link
  IF (SELECT public.get_role_in_workspace(p_workspace_id)) <> 'owner' THEN
    RAISE EXCEPTION 'Hanya owner yang bisa membuat link undangan.';
  END IF;

  -- 2. Buat entri undangan bertipe 'link' dengan waktu kedaluwarsa
  INSERT INTO public.workspace_invitations (workspace_id, inviter_id, role_to_grant, invitation_type, expires_at)
  VALUES (p_workspace_id, current_user_id, p_role_to_grant, 'link', now() + (p_duration_minutes * interval '1 minute'))
  RETURNING token INTO new_invitation_token;

  RETURN new_invitation_token;
END;
$$;


ALTER FUNCTION "public"."create_workspace_invitation_link"("p_workspace_id" "uuid", "p_role_to_grant" "text", "p_duration_minutes" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."decline_workspace_invitation"("p_invitation_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  invite_record RECORD;
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
BEGIN
  -- Cukup verifikasi dan perbarui status
  SELECT * INTO invite_record FROM public.workspace_invitations
  WHERE id = p_invitation_id AND invitee_id = current_user_id AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Undangan tidak valid atau sudah tidak berlaku.';
  END IF;

  UPDATE public.workspace_invitations SET status = 'declined' WHERE id = p_invitation_id;
END;
$$;


ALTER FUNCTION "public"."decline_workspace_invitation"("p_invitation_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_hicode_category"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM public.hicode_categories WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_hicode_category"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_hicode_chapter"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM public.hicode_chapters WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_hicode_chapter"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_hicode_material"("p_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  DELETE FROM public.hicode_materials WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."delete_hicode_material"("p_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_hicode_question"("p_question_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Hapus soal dari tabel hicode_questions
  -- Opsi akan terhapus otomatis karena ON DELETE CASCADE
  DELETE FROM public.hicode_questions WHERE id = p_question_id;

  -- Optional: Tambahkan pengecekan apakah soal ada sebelum delete
  -- IF NOT FOUND THEN
  --   RAISE WARNING 'Soal dengan ID % tidak ditemukan untuk dihapus.', p_question_id;
  -- END IF;
END;
$$;


ALTER FUNCTION "public"."delete_hicode_question"("p_question_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_unverified_users"() RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_to_delete RECORD;
BEGIN
    -- Loop melalui semua user di auth.users yang belum terverifikasi lebih dari 24 jam
    FOR user_to_delete IN
        SELECT id FROM auth.users
        WHERE email_confirmed_at IS NULL
        AND created_at < (now() - interval '24 hours')
    LOOP
        -- Gunakan fungsi admin Supabase untuk menghapus user.
        -- Ini akan menangani penghapusan dari semua tabel terkait (auth, public.users, user_roles) secara aman.
        PERFORM auth.admin_delete_user(user_to_delete.id);
        RAISE LOG 'Menghapus user yang belum terverifikasi: %', user_to_delete.id;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."delete_unverified_users"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."email_exists"("p_email" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Cek apakah email ada di tabel auth.users
  RETURN EXISTS (
    SELECT 1
    FROM auth.users
    WHERE email = p_email
  );
END;
$$;


ALTER FUNCTION "public"."email_exists"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_dashboard_info"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_auth_id UUID := auth.uid();
    user_info RECORD;
    pengurus_roles TEXT[];
    result JSONB;
BEGIN
    -- 1. Ambil informasi dasar dari tabel public.users dan auth.users
    SELECT
        u.username,
        u.profile_url,
        au.raw_user_meta_data->>'avatar_url' AS google_avatar_url
    INTO user_info
    FROM public.users u
    JOIN auth.users au ON u.auth_id = au.id
    WHERE u.auth_id = current_auth_id;

    -- Jika user tidak ditemukan, kembalikan null
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- 2. Ambil semua nama role yang group_name-nya 'Pengurus'
    SELECT array_agg(r.name)
    INTO pengurus_roles
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = current_auth_id)
      AND r.group_name = 'Pengurus';

    -- 3. Bangun objek JSON sebagai hasil akhir
    result := jsonb_build_object(
        'username', user_info.username,
        'pengurus_roles', COALESCE(pengurus_roles, '{}'),
        'profile_picture', COALESCE(user_info.profile_url, user_info.google_avatar_url)
    );

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_admin_dashboard_info"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_hicode_chapters"("p_material_id" "uuid") RETURNS TABLE("id" "uuid", "title" "text", "order" smallint)
    LANGUAGE "sql"
    AS $$
SELECT
    c.id,
    c.title,
    c."order"
FROM
    public.hicode_chapters c
WHERE
    c.material_id = p_material_id
ORDER BY
    c."order";
$$;


ALTER FUNCTION "public"."get_admin_hicode_chapters"("p_material_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_hicode_materials"() RETURNS TABLE("id" "uuid", "title" "text", "category_name" "text", "chapter_count" bigint)
    LANGUAGE "sql"
    AS $$
SELECT
    m.id,
    m.title,
    c.name as category_name,
    (SELECT count(*) FROM public.hicode_chapters ch WHERE ch.material_id = m.id) as chapter_count
FROM
    public.hicode_materials m
LEFT JOIN 
    public.hicode_categories c ON m.category_id = c.id
ORDER BY
    m.created_at DESC; -- Mengurutkan berdasarkan yang terbaru
$$;


ALTER FUNCTION "public"."get_admin_hicode_materials"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_chapters_for_admin"() RETURNS TABLE("id" "uuid", "title" "text", "material_id" "uuid")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT 
    ch.id, 
    m.title || ' - ' || ch.title AS title,
    ch.material_id -- <-- TAMBAHKAN BARIS INI
  FROM public.hicode_chapters ch
  JOIN public.hicode_materials m ON ch.material_id = m.id
  ORDER BY m.title, ch."order";
$$;


ALTER FUNCTION "public"."get_all_chapters_for_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_materials_for_admin"() RETURNS TABLE("id" "uuid", "title" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT id, title
  FROM public.hicode_materials
  ORDER BY title;
$$;


ALTER FUNCTION "public"."get_all_materials_for_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_roles_grouped"() RETURNS "jsonb"
    LANGUAGE "sql"
    AS $$
SELECT jsonb_object_agg(sub.group_name, sub.roles)
FROM (
    SELECT
        r.group_name,
        jsonb_agg(
            jsonb_build_object('id', r.id, 'name', r.name)
            ORDER BY r.name
        ) as roles
    FROM public.roles r
    GROUP BY r.group_name
    ORDER BY r.group_name
) as sub;
$$;


ALTER FUNCTION "public"."get_all_roles_grouped"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_users_with_roles"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  result jsonb;
begin
  select jsonb_agg(user_data) into result
  from (
    select
      u.id,
      u.npm,
      u.username,
      u.full_name,
      (
        select jsonb_agg(r)
        from (
          select r.id, r.name, r.group_name
          from roles r
          join user_roles ur on ur.role_id = r.id
          where ur.user_id = u.id
        ) r
      ) as roles
    from users u
  ) user_data;
  return result;
end;
$$;


ALTER FUNCTION "public"."get_all_users_with_roles"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_assignable_roles"() RETURNS TABLE("id" "uuid", "name" "text", "group_name" "text")
    LANGUAGE "sql"
    AS $$
    SELECT r.id, r.name, r.group_name
    FROM public.roles r
    WHERE r.group_name = 'Pengurus'
    ORDER BY r.name;
$$;


ALTER FUNCTION "public"."get_assignable_roles"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_chapter_list"("p_user_id" "uuid", "p_material_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  material_info jsonb;
  chapters_data jsonb;
  all_chapters_completed boolean;
  final_practice_status text;
  final_practice_question_count INT; -- <-- TAMBAHKAN VARIABEL INI
  result jsonb;
BEGIN
  -- 1. Ambil informasi dasar materi
  SELECT jsonb_build_object(
    'title', m.title,
    'description', m.description,
    'icon_path', m.image_url
  )
  INTO material_info
  FROM public.hicode_materials m
  WHERE m.id = p_material_id;

  -- Jika materi tidak ditemukan
  IF material_info IS NULL THEN
    RETURN jsonb_build_object(
      'title', 'Materi Tidak Ditemukan',
      'description', '',
      'icon_path', '',
      'chapters', '[]'::jsonb,
      'final_practice_status', 'locked',
      'final_practice_question_count', 0 -- <-- Tambahkan nilai default
    );
  END IF;

  -- 1b. Hitung jumlah soal Latihan Final (INI BAGIAN BARU)
  SELECT count(*)::int
  INTO final_practice_question_count
  FROM public.hicode_questions q
  WHERE q.related_id = p_material_id AND q.question_type = 'FINAL_PRACTICE';

  -- 2. Ambil daftar chapter beserta statusnya (Logika ini tetap sama)
  SELECT jsonb_agg(ch_data ORDER BY ch_data.chapter_order) INTO chapters_data FROM (
    SELECT
      ch.id,
      ch.title,
      ch."order" as chapter_order,
      COALESCE((SELECT count(*)::text || ' Soal Kuis'
                FROM public.hicode_questions q
                WHERE q.related_id = ch.id AND q.question_type = 'QUIZ'), '0 Soal Kuis') as details,
      EXISTS(
        SELECT 1 FROM public.hicode_user_progress up_check
        WHERE up_check.chapter_id = ch.id AND up_check.user_id = p_user_id AND up_check.is_completed = true
      ) as is_completed,
      (
        ch."order" > 1
        AND NOT EXISTS (
          SELECT 1
          FROM public.hicode_chapters ch_prev
          JOIN public.hicode_user_progress up_prev ON ch_prev.id = up_prev.chapter_id
          WHERE ch_prev.material_id = p_material_id
            AND ch_prev."order" = (ch."order" - 1)
            AND up_prev.user_id = p_user_id
            AND up_prev.is_completed = true
        )
      ) as is_locked
    FROM public.hicode_chapters ch
    WHERE ch.material_id = p_material_id
  ) ch_data;

  -- 3. Cek apakah SEMUA chapter sudah selesai (Logika ini tetap sama)
  SELECT NOT EXISTS (
    SELECT 1
    FROM public.hicode_chapters ch_all
    WHERE ch_all.material_id = p_material_id
      AND NOT EXISTS (
        SELECT 1 FROM public.hicode_user_progress up_all
        WHERE up_all.chapter_id = ch_all.id AND up_all.user_id = p_user_id AND up_all.is_completed = true
      )
  ) INTO all_chapters_completed;

  IF all_chapters_completed AND EXISTS (SELECT 1 FROM public.hicode_chapters WHERE material_id = p_material_id) THEN
    final_practice_status := 'unlocked';
  ELSE
    final_practice_status := 'locked';
  END IF;

  -- 4. Gabungkan hasil (Tambahkan field baru)
  result := material_info || jsonb_build_object(
    'chapters', COALESCE(chapters_data, '[]'::jsonb),
    'final_practice_status', final_practice_status,
    'final_practice_question_count', final_practice_question_count -- <-- TAMBAHKAN INI
  );

  RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_chapter_list"("p_user_id" "uuid", "p_material_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "workspace_id" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "recurrence_id" "uuid",
    "reminder_minutes_before" integer[]
);


ALTER TABLE "public"."events" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_events_in_range"("p_workspace_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) RETURNS SETOF "public"."events"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- 1. Kembalikan semua event biasa (non-berulang) dalam rentang tanggal
  RETURN QUERY
  SELECT *
  FROM public.events e
  WHERE 
    e.workspace_id = p_workspace_id AND
    e.recurrence_id IS NULL AND
    e.start_time <= p_end_date AND
    e.end_time >= p_start_date;

  -- 2. "Hitung" dan kembalikan semua event berulang dalam rentang tanggal
  RETURN QUERY
  SELECT
    e.id, 
    e.workspace_id,
    e.created_by,
    e.title,
    e.description,
    -- Hitung start_time dan end_time yang baru untuk setiap perulangan
    (d.day::date + e.start_time::time)::timestamptz as start_time,
    (d.day::date + e.end_time::time)::timestamptz as end_time,
    e.created_at,
    e.recurrence_id,
    -- PERBAIKAN DI SINI: Tambahkan kolom yang hilang
    e.reminder_minutes_before
  FROM 
    public.events e
  JOIN 
    public.event_recurrence r ON e.recurrence_id = r.id
  JOIN 
    generate_series(p_start_date, p_end_date, '1 day'::interval) AS d(day) ON true
  WHERE
    e.workspace_id = p_workspace_id AND
    e.recurrence_id IS NOT NULL AND
    (r.until_date IS NULL OR d.day::date <= r.until_date::date) AND
    -- Gunakan format hari yang benar (misal: 'MO', 'TU')
    to_char(d.day, 'DY') = ANY(r.by_day);
END;
$$;


ALTER FUNCTION "public"."get_events_in_range"("p_workspace_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_categories"() RETURNS TABLE("id" "uuid", "name" "text", "icon_url" "text", "order" smallint)
    LANGUAGE "sql"
    AS $$
  SELECT id, name, icon_url, "order" FROM public.hicode_categories ORDER BY "order";
$$;


ALTER FUNCTION "public"."get_hicode_categories"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    chapter_data RECORD;
    quiz_count INT;
BEGIN
    -- Ambil data utama dari chapter
    SELECT title, content, estimated_read_time
    INTO chapter_data
    FROM public.hicode_chapters
    WHERE id = p_chapter_id;

    -- Hitung jumlah kuis yang terkait dengan chapter ini
    SELECT count(*)
    INTO quiz_count
    FROM public.hicode_questions
    WHERE related_id = p_chapter_id AND question_type = 'QUIZ';

    -- Gabungkan semua data menjadi satu objek JSON
    RETURN jsonb_build_object(
        'title', chapter_data.title,
        'read_time', chapter_data.estimated_read_time || ' Menit waktu pembaca',
        'quiz_count', quiz_count || ' Soal Kuis',
        'content_blocks', chapter_data.content -> 'blocks'
    );
END;
$$;


ALTER FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid", "p_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  chapter_data RECORD;
  quiz_count INT;
  progress_data RECORD; -- Akan menampung 3 kolom
BEGIN
  -- 1. Ambil data chapter (termasuk is_quizless)
  SELECT title, content, estimated_read_time, is_quizless
  INTO chapter_data
  FROM public.hicode_chapters
  WHERE id = p_chapter_id;

  IF NOT FOUND THEN
     RETURN jsonb_build_object(
       'title', 'Chapter Tidak Ditemukan', 'read_time', 'N/A', 'quiz_count', 'N/A',
       'content_blocks', '[]'::jsonb, 'last_scroll_position', 0.0, 
       'is_quiz_unlocked', false, 'is_quizless', false
     );
  END IF;
  
  -- 2. Hitung kuis (tidak berubah)
  SELECT count(*) INTO quiz_count
  FROM public.hicode_questions
  WHERE related_id = p_chapter_id AND question_type = 'QUIZ';

  -- 3. Ambil data progress (Ambil is_completed juga!)
  SELECT last_scroll_position, has_reached_bottom, is_completed -- <-- TAMBAHKAN is_completed
  INTO progress_data
  FROM public.hicode_user_progress
  WHERE user_id = p_user_id AND chapter_id = p_chapter_id;

  -- 4. Gabungkan hasil
  RETURN jsonb_build_object(
    'title', chapter_data.title,
    'read_time', COALESCE(chapter_data.estimated_read_time::text || ' Menit waktu pembaca', 'Estimasi tidak tersedia'),
    'quiz_count', quiz_count::text || ' Soal Kuis',
    'content_blocks', COALESCE(chapter_data.content, '[]'::jsonb),
    'last_scroll_position', COALESCE(progress_data.last_scroll_position, 0.0),
    
    -- LOGIKA KRUSIAL DI SINI:
    -- Kuis/Tombol "Selesai" dianggap terbuka jika:
    -- 1. User sudah scroll ke bawah (has_reached_bottom = true)
    -- ATAU
    -- 2. Chapter ini sudah ditandai selesai (is_completed = true)
    'is_quiz_unlocked', (COALESCE(progress_data.has_reached_bottom, false) OR COALESCE(progress_data.is_completed, false)),
    
    'is_quizless', chapter_data.is_quizless -- <-- PASTIKAN INI ADA
  );
END;
$$;


ALTER FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_main_screen"("p_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  result jsonb;
  category_data jsonb;
  material_data jsonb;
  required_material_count INT;
  completed_material_count INT;
  all_chapters_within_completed_materials_done BOOLEAN;
  can_take_exam_today BOOLEAN;
  materials_are_complete BOOLEAN;
  next_exam_time timestamptz; -- <-- Variabel baru
BEGIN
  -- 1. Ambil kategori (Tidak berubah)
  SELECT jsonb_agg(cats) INTO category_data FROM (
    SELECT id, name, icon_url FROM public.hicode_categories ORDER BY "order"
  ) cats;

  -- 2. Ambil materi & progres (Tidak berubah)
  SELECT jsonb_agg(mats) INTO material_data FROM (
    SELECT
      m.id, m.title, m.image_url, m.border_color,
      (SELECT COUNT(*) FROM public.hicode_chapters ch WHERE ch.material_id = m.id) as total_chapters,
      (SELECT COUNT(*)
       FROM public.hicode_user_progress up
       JOIN public.hicode_chapters ch ON up.chapter_id = ch.id
       WHERE up.user_id = p_user_id AND ch.material_id = m.id AND up.is_completed = true
      ) as completed_chapters
    FROM public.hicode_materials m
    ORDER BY m."order", m.created_at
  ) mats;

  -- 3. Cek Kesiapan Ujian Akhir
  
  -- 3a. Cek kelengkapan materi (Tidak berubah)
  SELECT COUNT(DISTINCT m.id)
  INTO required_material_count
  FROM public.hicode_materials m
  WHERE EXISTS (SELECT 1 FROM public.hicode_chapters ch WHERE ch.material_id = m.id);

  SELECT COUNT(DISTINCT mp.material_id)
  INTO completed_material_count
  FROM public.hicode_material_progress mp
  WHERE mp.user_id = p_user_id AND mp.is_completed = true;

  SELECT NOT EXISTS (
      SELECT 1
      FROM public.hicode_material_progress mp
      JOIN public.hicode_chapters ch ON mp.material_id = ch.material_id
      WHERE mp.user_id = p_user_id AND mp.is_completed = true
      AND NOT EXISTS (
          SELECT 1
          FROM public.hicode_user_progress up
          WHERE up.user_id = p_user_id AND up.chapter_id = ch.id AND up.is_completed = true
      )
  ) INTO all_chapters_within_completed_materials_done;

  -- Tentukan status kelengkapan materi
  materials_are_complete := (required_material_count > 0)
                          AND (completed_material_count = required_material_count)
                          AND all_chapters_within_completed_materials_done;

  -- 3b. Cek Cooldown Mingguan (Menggunakan RPC yang sudah ada)
  SELECT public.check_overall_exam_availability(p_user_id)
  INTO can_take_exam_today;

  -- 3c. Tentukan kapan ujian berikutnya tersedia (BARU)
  IF can_take_exam_today THEN
    next_exam_time := null; -- Boleh ujian kapan saja
  ELSE
    -- Jika tidak boleh, hitung kapan Senin depan jam 00:00
    next_exam_time := date_trunc('week', now() + interval '1 week');
  END IF;

  -- 4. Gabungkan hasil
  result := jsonb_build_object(
    'categories', COALESCE(category_data, '[]'::jsonb),
    'materials', COALESCE(material_data, '[]'::jsonb),
    
    -- GANTI 'is_exam_ready' DENGAN 3 FIELD INI:
    'all_materials_complete', materials_are_complete,
    'can_take_exam_today', can_take_exam_today,
    'next_exam_available_at', next_exam_time
  );

  RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_hicode_main_screen"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_questions"("p_related_id" "uuid", "p_question_type" "text") RETURNS SETOF "public"."hicode_question_with_options_type"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        q.id,
        q.question_text,
        q.image_url,
        ARRAY( -- Ambil opsi sebagai array dari tipe custom
            SELECT ROW(o.id, o.option_text, o.image_url)::hicode_option_type
            FROM public.hicode_options o
            WHERE o.question_id = q.id
            ORDER BY random() -- Acak opsi
        ) as options
    FROM public.hicode_questions q
    WHERE q.related_id = p_related_id AND q.question_type = p_question_type
    ORDER BY random(); -- Acak soal
END;
$$;


ALTER FUNCTION "public"."get_hicode_questions"("p_related_id" "uuid", "p_question_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "question_text" "text", "question_type" "text", "difficulty" "text", "related_id" "uuid", "related_title" "text", "option_count" integer, "created_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
SELECT
  q.id,
  q.question_text,
  q.question_type,
  q.difficulty,
  q.related_id,
  COALESCE(
     (SELECT ch.title FROM public.hicode_chapters ch WHERE ch.id = q.related_id AND q.question_type = 'QUIZ'),
     (SELECT m.title FROM public.hicode_materials m WHERE m.id = q.related_id AND q.question_type = 'FINAL_PRACTICE'),
     'Ujian Akhir'
  ) AS related_title,
  (SELECT count(*) FROM public.hicode_options opt WHERE opt.question_id = q.id)::int AS option_count,
  q.created_at
FROM public.hicode_questions q
ORDER BY q.created_at DESC
LIMIT p_limit
OFFSET p_offset;
$$;


ALTER FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_question_type" "text" DEFAULT NULL::"text") RETURNS TABLE("id" "uuid", "question_text" "text", "question_type" "text", "difficulty" "text", "related_id" "uuid", "related_title" "text", "option_count" integer, "created_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
	SELECT
	  q.id,
	  q.question_text,
	  q.question_type,
	  q.difficulty,
	  q.related_id,
	  COALESCE(
	     (SELECT ch.title FROM public.hicode_chapters ch WHERE ch.id = q.related_id AND q.question_type = 'QUIZ'),
	     (SELECT m.title FROM public.hicode_materials m WHERE m.id = q.related_id AND q.question_type = 'FINAL_PRACTICE'),
	     'Ujian Akhir'
	  ) AS related_title,
	  (SELECT count(*) FROM public.hicode_options opt WHERE opt.question_id = q.id)::int AS option_count,
	  q.created_at
	FROM public.hicode_questions q
	WHERE 
    -- TAMBAHKAN KLAUSA WHERE INI 
	    (p_question_type IS NULL OR q.question_type = p_question_type)
	ORDER BY q.created_at DESC
	LIMIT p_limit
	OFFSET p_offset;
$$;


ALTER FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0, "p_question_type" "text" DEFAULT NULL::"text", "p_related_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "question_text" "text", "question_type" "text", "difficulty" "text", "related_id" "uuid", "related_title" "text", "option_count" integer, "created_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
	SELECT
	  q.id,
	  q.question_text,
	  q.question_type,
	  q.difficulty,
	  q.related_id,
	  COALESCE(
	     (SELECT ch.title FROM public.hicode_chapters ch WHERE ch.id = q.related_id AND q.question_type = 'QUIZ'),
	     (SELECT m.title FROM public.hicode_materials m WHERE m.id = q.related_id AND q.question_type = 'FINAL_PRACTICE'),
	     'Ujian Akhir'
	  ) AS related_title,
	  (SELECT count(*) FROM public.hicode_options opt WHERE opt.question_id = q.id)::int AS option_count,
	  q.created_at
	FROM public.hicode_questions q
	WHERE
	  (p_question_type IS NULL OR q.question_type = p_question_type)
	  AND (p_related_id IS NULL OR q.related_id = p_related_id)
	ORDER BY q.created_at DESC
	LIMIT p_limit
	OFFSET p_offset;
$$;


ALTER FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text", "p_related_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_leaderboard"("p_filter" "text" DEFAULT 'all'::"text") RETURNS TABLE("rank" bigint, "user_id" "uuid", "username" "text", "full_name" "text", "profile_url" "text", "highest_score" integer, "fastest_time_seconds" integer, "last_exam_timestamp" timestamp with time zone)
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        RANK() OVER (ORDER BY lb.highest_score DESC, lb.fastest_time_seconds ASC) as rank,
        u.id as user_id,
        u.username,
        u.full_name,
        COALESCE(u.profile_url, au.raw_user_meta_data->>'avatar_url') as profile_url, -- Menggabungkan profile_url dari users dan auth.users
        lb.highest_score,
        lb.fastest_time_seconds,
        lb.last_exam_timestamp
    FROM public.hicode_leaderboard lb
    JOIN public.users u ON lb.user_id = u.id
    LEFT JOIN auth.users au ON u.auth_id = au.id -- Join ke auth.users untuk avatar Google
    WHERE
        -- Terapkan filter waktu jika 'weekly'
        CASE
            WHEN p_filter = 'weekly' THEN lb.last_exam_timestamp >= date_trunc('week', now())
            ELSE true -- Jika 'all' atau filter tidak dikenal, tampilkan semua
        END
    ORDER BY
        rank ASC, -- Urutkan berdasarkan peringkat
        lb.last_exam_timestamp DESC -- Jika peringkat sama (jarang terjadi karena waktu), yang terbaru duluan
    LIMIT 100; -- Batasi hasil untuk performa (misal 100 teratas)
END;
$$;


ALTER FUNCTION "public"."get_leaderboard"("p_filter" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_material_details"("p_material_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  material_data record;
BEGIN
  -- 1. Ambil data utama materi
  SELECT * INTO material_data
  FROM public.hicode_materials
  WHERE id = p_material_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Materi dengan ID % tidak ditemukan.', p_material_id;
  END IF;

  -- 2. Bangun JSON (bisa tambahkan field lain jika perlu nanti)
  RETURN jsonb_build_object(
    'id', material_data.id,
    'category_id', material_data.category_id,
    'title', material_data.title,
    'description', material_data.description,
    'image_url', material_data.image_url,
    'border_color', material_data.border_color,
    'order', material_data."order",
    'created_at', material_data.created_at
  );
END;
$$;


ALTER FUNCTION "public"."get_material_details"("p_material_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_workspace_ids"() RETURNS SETOF "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT workspace_id 
  FROM public.workspace_access 
  WHERE user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid());
END;
$$;


ALTER FUNCTION "public"."get_my_workspace_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_workspaces_with_members"() RETURNS json
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  -- Kita harus menggunakan auth.uid() DI DALAM fungsi
  current_user_auth_id UUID := auth.uid(); 
  current_user_internal_id UUID;
BEGIN
  -- Dapatkan ID internal (dari public.users) milik user yang memanggil fungsi ini
  SELECT id INTO current_user_internal_id FROM public.users WHERE auth_id = current_user_auth_id;

  -- Jika user (penelepon) tidak ditemukan, kembalikan array kosong
  IF current_user_internal_id IS NULL THEN
    RETURN '[]'::json;
  END IF;

  -- Kueri ini sekarang berjalan sebagai 'DEFINER' (admin)
  RETURN (
    SELECT json_agg(
      json_build_object(
        'workspace', ws,
        'members', (
          SELECT json_agg(
            json_build_object(
              'user_data', user_with_avatar,
              'role', wa_inner.role
            )
          )
          FROM public.workspace_access wa_inner
          
          -- 1. Kita JOIN dengan subquery (tabel virtual)
          JOIN (
              SELECT
                u.id, u.auth_id, u.username, u.full_name, u.email,
                u.phone_number, u.date_of_birth,
                
                -- 2. Kita timpa 'profile_url' di sini
                COALESCE(u.profile_url, au.raw_user_meta_data->>'avatar_url') as profile_url,
                
                u.npm, u.nomor_mahasiswa, u.is_email_verified,
                u.is_from_unsika, u.created_at, u.verified_at, u.fcm_token
              
              -- 3. Subquery (sebagai admin) bisa mengakses kedua tabel ini
              FROM public.users u
              LEFT JOIN auth.users au ON u.auth_id = au.id
          ) 
          -- 4. Beri nama tabel virtual itu 'user_with_avatar'
          AS user_with_avatar ON wa_inner.user_id = user_with_avatar.id
          
          WHERE wa_inner.workspace_id = ws.id
        ),
        'currentUserRole', (
          -- Subquery ini (sebagai admin) tetap mencari role
          -- untuk 'current_user_internal_id' (user yang memanggil)
          SELECT role FROM public.workspace_access
          WHERE workspace_id = ws.id AND user_id = current_user_internal_id
          LIMIT 1
        )
      )
    )
    FROM public.user_workspace ws
    -- Meskipun RLS ter-bypass, kita filter manual agar user
    -- HANYA melihat workspace miliknya sendiri
    WHERE ws.id IN (SELECT workspace_id FROM public.workspace_access WHERE user_id = current_user_internal_id)
  );
END;
$$;


ALTER FUNCTION "public"."get_my_workspaces_with_members"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_pending_notifications"() RETURNS json
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  now_utc TIMESTAMPTZ := now();
BEGIN
  RETURN (
    SELECT json_agg(
      -- Kita sekarang butuh event_id dan notification_time untuk dicatat nanti
      json_build_object(
        'event_id', pending.id,
        'notification_time', pending.notification_time,
        'title', pending.title,
        'tokens', pending.tokens
      )
    )
    FROM (
      SELECT
        e.id,
        e.title,
        (e.start_time - (minutes.value * interval '1 minute')) as notification_time,
        (
          SELECT json_agg(u.fcm_token)
          FROM public.workspace_access wa
          JOIN public.users u ON wa.user_id = u.id
          WHERE wa.workspace_id = e.workspace_id AND u.fcm_token IS NOT NULL
        ) as tokens
      FROM 
        public.events e,
        unnest(e.reminder_minutes_before) AS minutes(value)
      WHERE 
        e.reminder_minutes_before IS NOT NULL AND
        -- Ambil semua alarm yang waktunya sudah lewat
        (e.start_time - (minutes.value * interval '1 minute')) <= now_utc AND
        -- DAN belum pernah dikirim sebelumnya
        NOT EXISTS (
          SELECT 1
          FROM public.sent_notifications sn
          WHERE sn.event_id = e.id AND sn.notification_time = (e.start_time - (minutes.value * interval '1 minute'))
        )
    ) AS pending
  );
END;
$$;


ALTER FUNCTION "public"."get_pending_notifications"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_question_details"("p_question_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
  question_data record;
  options_data jsonb;
BEGIN
  -- 1. Ambil data utama soal (tetap sama)
  SELECT * INTO question_data FROM public.hicode_questions WHERE id = p_question_id;
  IF NOT FOUND THEN RAISE EXCEPTION '...'; END IF;

  -- 2. Ambil semua opsi (tambahkan image_url)
  SELECT jsonb_agg(
            jsonb_build_object(
                'id', o.id,
                'option_text', o.option_text,
                'is_correct', o.is_correct,
                'image_url', o.image_url -- <-- Tambahkan ini
            ) ORDER BY o.created_at
         )
  INTO options_data
  FROM public.hicode_options o
  WHERE o.question_id = p_question_id;

  -- 3. Gabungkan JSON (tetap sama)
  RETURN jsonb_build_object(
    'id', question_data.id,
    'related_id', question_data.related_id,
    'question_type', question_data.question_type,
    'difficulty', question_data.difficulty,
    'question_text', question_data.question_text,
    'image_url', question_data.image_url,
    'created_at', question_data.created_at,
    'options', COALESCE(options_data, '[]'::jsonb)
  );
END;
$$;


ALTER FUNCTION "public"."get_question_details"("p_question_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_role_in_workspace"("p_workspace_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  current_user_internal_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  user_role TEXT;
BEGIN
  -- Fungsi ini aman karena RLS di workspace_access sudah mengizinkan
  -- anggota untuk melihat data di dalam workspace yang sama.
  SELECT wa.role INTO user_role
  FROM public.workspace_access wa
  WHERE wa.workspace_id = p_workspace_id AND wa.user_id = current_user_internal_id;
  
  RETURN user_role;
END;
$$;


ALTER FUNCTION "public"."get_role_in_workspace"("p_workspace_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_auth_user"("user_id" "uuid", "user_email" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    npm_text TEXT;
    kode_prodi_text TEXT;
    kode_fakultas_text TEXT;
    angkatan_digits TEXT;
    role_id_prodi UUID;
    role_id_fakultas UUID;
    role_id_pengunjung UUID;
    angkatan_role_id UUID;
    angkatan_role_name1 TEXT;
    angkatan_role_name2 TEXT;
BEGIN
    -- Ambil role default pengunjung (sekali saja)
    SELECT id INTO role_id_pengunjung
    FROM public.roles
    WHERE LOWER(name) = 'pengunjung'
    LIMIT 1;

    -- Cek apakah email domain Unsika student
    IF user_email ILIKE '%@student.unsika.ac.id' THEN
        -- ambil local-part (npm candidate)
        npm_text := split_part(user_email, '@', 1);

        -- safety: pastikan local-part cukup panjang (minimal 9; NPM contoh 13)
        IF npm_text IS NOT NULL AND char_length(npm_text) >= 9 THEN
            -- Ambil bagian-bagian NPM berdasarkan format yang disepakati:
            -- angkatan: 2 digit pertama (pos 1..2)
            angkatan_digits := SUBSTR(npm_text, 1, 2);

            -- kode fakultas: 3 digit (pos 3..5)
            kode_fakultas_text := SUBSTR(npm_text, 3, 3);

            -- kode prodi: 4 digit (pos 6..9)
            kode_prodi_text := SUBSTR(npm_text, 6, 4);

            -- Cari role fakultas berdasarkan tabel kode_fakultas (kode -> nama),
            -- lalu matching ke roles.name (case-insensitive)
            SELECT r.id INTO role_id_fakultas
            FROM public.kode_fakultas kf
            JOIN public.roles r ON LOWER(r.name) = LOWER(kf.nama)
            WHERE kf.kode = kode_fakultas_text
            LIMIT 1;

            -- Cari role prodi berdasarkan tabel kode_prodi
            SELECT r.id INTO role_id_prodi
            FROM public.kode_prodi kp
            JOIN public.roles r ON LOWER(r.name) = LOWER(kp.nama)
            WHERE kp.kode = kode_prodi_text
            LIMIT 1;

            -- Assign role fakultas jika ditemukan
            IF role_id_fakultas IS NOT NULL THEN
                INSERT INTO public.user_roles(user_id, role_id)
                VALUES (user_id, role_id_fakultas)
                ON CONFLICT DO NOTHING;
            END IF;

            -- Assign role prodi jika ditemukan
            IF role_id_prodi IS NOT NULL THEN
                INSERT INTO public.user_roles(user_id, role_id)
                VALUES (user_id, role_id_prodi)
                ON CONFLICT DO NOTHING;
            END IF;

            -- Assign role angkatan (cek dua kemungkinan penamaan, contoh tersupport):
            -- 1) Angkatan_20{angkatan_digits}  (mis. Angkatan_2023)
            -- 2) Angkatan_{angkatan_digits}     (mis. Angkatan_23)
            angkatan_role_name1 := 'Angkatan_' || '20' || angkatan_digits;  -- e.g. Angkatan_2023
            angkatan_role_name2 := 'Angkatan_' || angkatan_digits;          -- e.g. Angkatan_23

            SELECT id INTO angkatan_role_id
            FROM public.roles
            WHERE name = angkatan_role_name1 OR name = angkatan_role_name2
            LIMIT 1;

            IF angkatan_role_id IS NOT NULL THEN
                INSERT INTO public.user_roles(user_id, role_id)
                VALUES (user_id, angkatan_role_id)
                ON CONFLICT DO NOTHING;
            END IF;

            -- Jika tidak ada mapping fakultas/prodi/angkatan sama sekali → fallback ke pengunjung
            IF role_id_fakultas IS NULL AND role_id_prodi IS NULL AND angkatan_role_id IS NULL THEN
                IF role_id_pengunjung IS NOT NULL THEN
                    INSERT INTO public.user_roles(user_id, role_id)
                    VALUES (user_id, role_id_pengunjung)
                    ON CONFLICT DO NOTHING;
                END IF;
            END IF;
        ELSE
            -- local-part terlalu pendek / tidak terduga, fallback ke pengunjung
            IF role_id_pengunjung IS NOT NULL THEN
                INSERT INTO public.user_roles(user_id, role_id)
                VALUES (user_id, role_id_pengunjung)
                ON CONFLICT DO NOTHING;
            END IF;
        END IF;

    ELSE
        -- Non-Unsika langsung pengunjung
        IF role_id_pengunjung IS NOT NULL THEN
            INSERT INTO public.user_roles(user_id, role_id)
            VALUES (user_id, role_id_pengunjung)
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."handle_new_auth_user"("user_id" "uuid", "user_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  npm_text TEXT;
  angkatan_digits TEXT;
  kode_kampus_text TEXT;
  kode_prodi_text TEXT;
  nomor_mahasiswa_text TEXT;
  prodi_record RECORD;
  role_id_fakultas UUID;
  role_id_prodi UUID;
  angkatan_role_id UUID;
  role_id_pengunjung UUID;
  angkatan_role_name TEXT;
  local_user_id UUID;
  username_text TEXT;
  agenda_himtika_workspace_id UUID; -- <<< PERBAIKAN: Variabel ditambahkan di sini
BEGIN
  -- Ambil ID role "Pengunjung"
  SELECT id INTO role_id_pengunjung FROM public.roles WHERE LOWER(name) = 'pengunjung' LIMIT 1;

  -- Cek apakah email Unsika dan parse NPM dari data user BARU (NEW.email)
  IF NEW.email ILIKE '%@student.unsika.ac.id' THEN
    npm_text := split_part(NEW.email, '@', 1);
    
    IF char_length(npm_text) = 13 THEN
      angkatan_digits := SUBSTRING(npm_text, 1, 2);
      kode_kampus_text := SUBSTRING(npm_text, 3, 4);
      kode_prodi_text := SUBSTRING(npm_text, 7, 4);
      nomor_mahasiswa_text := SUBSTRING(npm_text, 11, 3);
    ELSE
      npm_text := NULL;
      nomor_mahasiswa_text := NULL;
    END IF;
  ELSE
    npm_text := NULL;
    nomor_mahasiswa_text := NULL;
  END IF;

  -- Tentukan username sementara
  username_text := COALESCE(npm_text, 'guest_' || gen_random_uuid());

  -- Insert user ke public.users menggunakan data dari user BARU (NEW)
  INSERT INTO public.users (auth_id, username, full_name, email, npm, nomor_mahasiswa, is_email_verified, is_from_unsika)
  VALUES (NEW.id, username_text, COALESCE(NEW.raw_user_meta_data->>'full_name', ''), NEW.email, npm_text, nomor_mahasiswa_text, (NEW.email_confirmed_at IS NOT NULL), (npm_text IS NOT NULL))
  RETURNING id INTO local_user_id;

  -- Jika user adalah mahasiswa Unsika
  IF npm_text IS NOT NULL AND kode_kampus_text = '1063' THEN
    -- Ambil data dari tabel program_studi yang baru
    SELECT nama_prodi, nama_fakultas INTO prodi_record FROM public.program_studi WHERE kode_prodi = kode_prodi_text LIMIT 1;

    IF FOUND THEN
      -- Assign role prodi
      SELECT id INTO role_id_prodi FROM public.roles WHERE name = prodi_record.nama_prodi AND group_name = 'Prodi' LIMIT 1;
      IF role_id_prodi IS NOT NULL THEN
        INSERT INTO public.user_roles(user_id, role_id) VALUES (local_user_id, role_id_prodi) ON CONFLICT DO NOTHING;
      END IF;

      -- Assign role fakultas
      SELECT id INTO role_id_fakultas FROM public.roles WHERE name = prodi_record.nama_fakultas AND group_name = 'Fakultas' LIMIT 1;
      IF role_id_fakultas IS NOT NULL THEN
        INSERT INTO public.user_roles(user_id, role_id) VALUES (local_user_id, role_id_fakultas) ON CONFLICT DO NOTHING;
      END IF;
      
      -- Assign role angkatan
      angkatan_role_name := 'Angkatan_' || angkatan_digits;
      SELECT id INTO angkatan_role_id FROM public.roles WHERE name = angkatan_role_name AND group_name = 'Angkatan' LIMIT 1;
      IF angkatan_role_id IS NOT NULL THEN
        INSERT INTO public.user_roles(user_id, role_id) VALUES (local_user_id, angkatan_role_id) ON CONFLICT DO NOTHING;
      END IF;
    END IF;
  END IF;
  
  -- Jika tidak ada role yang di-assign (termasuk non-Unsika), berikan role "Pengunjung"
  IF NOT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = local_user_id) AND role_id_pengunjung IS NOT NULL THEN
     INSERT INTO public.user_roles(user_id, role_id) VALUES (local_user_id, role_id_pengunjung) ON CONFLICT DO NOTHING;
  END IF;

  -- 1. Cari ID workspace "Agenda Himtika"
  SELECT id INTO agenda_himtika_workspace_id FROM public.user_workspace WHERE title = 'Agenda Himtika' LIMIT 1;
  
  -- 2. Jika ditemukan, berikan akses 'viewer' kepada pengguna baru
  IF agenda_himtika_workspace_id IS NOT NULL THEN
    INSERT INTO public.workspace_access (workspace_id, user_id, role)
    VALUES (agenda_himtika_workspace_id, local_user_id, 'viewer')
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."invite_user_to_workspace"("p_workspace_id" "uuid", "p_invitee_email" "text", "p_role_to_grant" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  invitee_user_id UUID;
BEGIN
  -- 1. Pastikan hanya owner yang bisa mengundang
  IF (SELECT public.get_role_in_workspace(p_workspace_id)) <> 'owner' THEN
    RAISE EXCEPTION 'Hanya owner yang bisa mengundang pengguna lain.';
  END IF;

  -- 2. Cari ID pengguna yang diundang berdasarkan email
  SELECT id INTO invitee_user_id FROM public.users WHERE email = p_invitee_email;
  IF invitee_user_id IS NULL THEN
    RAISE EXCEPTION 'Pengguna dengan email tersebut tidak ditemukan.';
  END IF;
  
  -- 3. Pastikan tidak mengundang diri sendiri
  IF invitee_user_id = current_user_id THEN
    RAISE EXCEPTION 'Anda tidak bisa mengundang diri sendiri.';
  END IF;

  -- 4. Buat entri undangan di tabel invitations
  INSERT INTO public.workspace_invitations (workspace_id, inviter_id, invitee_id, role_to_grant)
  VALUES (p_workspace_id, current_user_id, invitee_user_id, p_role_to_grant)
  ON CONFLICT (workspace_id, invitee_id) DO UPDATE 
  SET role_to_grant = p_role_to_grant, status = 'pending'; -- Jika sudah pernah diundang, update saja perannya
END;
$$;


ALTER FUNCTION "public"."invite_user_to_workspace"("p_workspace_id" "uuid", "p_invitee_email" "text", "p_role_to_grant" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."invite_users_by_roles"("p_workspace_id" "uuid", "p_target_role_ids" "uuid"[], "p_role_to_grant" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  target_user_id UUID;
  role_count INT := array_length(p_target_role_ids, 1);
BEGIN
  -- 1. Pastikan hanya owner
  IF (SELECT public.get_role_in_workspace(p_workspace_id)) <> 'owner' THEN
    RAISE EXCEPTION 'Hanya owner yang bisa membagikan workspace.';
  END IF;

  -- 2. Loop melalui SETIAP pengguna yang memiliki SEMUA role yang ditargetkan (Logika AND)
  FOR target_user_id IN
    SELECT ur.user_id
    FROM public.user_roles ur
    WHERE ur.role_id = ANY(p_target_role_ids)
    GROUP BY ur.user_id
    HAVING COUNT(DISTINCT ur.role_id) = role_count
  LOOP
    -- 3. Buat undangan 'personal' untuk setiap user yang cocok
    -- Abaikan jika user adalah diri sendiri
    IF target_user_id <> current_user_id THEN
      INSERT INTO public.workspace_invitations (workspace_id, inviter_id, invitee_id, role_to_grant, invitation_type)
      VALUES (p_workspace_id, current_user_id, target_user_id, p_role_to_grant, 'personal')
      ON CONFLICT (workspace_id, invitee_id) DO UPDATE
      SET role_to_grant = p_role_to_grant, status = 'pending', created_at = now();
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."invite_users_by_roles"("p_workspace_id" "uuid", "p_target_role_ids" "uuid"[], "p_role_to_grant" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_agenda_manager"() RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  current_user_internal_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
BEGIN
  -- Fungsi ini mengembalikan TRUE jika pengguna memiliki salah satu dari role pengurus inti.
  -- Anda bisa menambahkan nama role lain di dalam array ini di masa depan.
  RETURN EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE ur.user_id = current_user_internal_id
    AND r.name IN ('Ketua Himpunan', 'Wakil Ketua Himpunan', 'RnD', 'Ketua Pelaksana')
  );
END;
$$;


ALTER FUNCTION "public"."is_agenda_manager"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."on_email_verified"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF NEW.email_confirmed_at IS NOT NULL AND OLD.email_confirmed_at IS NULL THEN
    PERFORM public.set_email_verified(NEW.id);
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."on_email_verified"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_admin_users"("p_query" "text", "p_scope" "text" DEFAULT 'HIMA'::"text") RETURNS TABLE("user_id" "uuid", "username" "text", "full_name" "text", "roles" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id as user_id,
        u.username,
        u.full_name,
        (
            SELECT jsonb_agg(
                jsonb_build_object('id', r.id, 'name', r.name, 'group_name', r.group_name)
            )
            FROM public.user_roles ur
            JOIN public.roles r ON ur.role_id = r.id
            WHERE
                ur.user_id = u.id
                AND (p_scope = 'GENERAL' OR r.group_name IN ('Pengurus', 'Angkatan')) -- Logika filter dinamis
        ) as roles
    FROM public.users u
    WHERE
        p_query IS NULL OR p_query = '' OR
        u.full_name ILIKE '%' || p_query || '%' OR
        u.username ILIKE '%' || p_query || '%' OR
        u.email ILIKE '%' || p_query || '%' OR
        u.npm ILIKE '%' || p_query || '%'
    ORDER BY u.created_at DESC -- Menampilkan user terbaru di atas
    LIMIT 20;
END;
$$;


ALTER FUNCTION "public"."search_admin_users"("p_query" "text", "p_scope" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."search_users"("p_query" "text") RETURNS TABLE("id" "uuid", "full_name" "text", "username" "text", "email" "text", "profile_url" "text", "auth_avatar_url" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.full_name,
    u.username,
    u.email, -- Kolom email sekarang disertakan
    u.profile_url,
    au.raw_user_meta_data->>'avatar_url' AS auth_avatar_url
  FROM
    public.users u
  JOIN
    auth.users au ON u.auth_id = au.id
  WHERE
    p_query <> '' AND
    -- Logika pencarian dari awal string sudah benar
    (u.full_name ILIKE p_query || '%' OR u.username ILIKE p_query || '%') AND
    u.auth_id <> auth.uid()
  LIMIT 10;
END;
$$;


ALTER FUNCTION "public"."search_users"("p_query" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_email_verified"("user_uuid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.users
  SET is_email_verified = TRUE, verified_at = NOW()
  WHERE auth_id = user_uuid;
END;
$$;


ALTER FUNCTION "public"."set_email_verified"("user_uuid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  answer_data jsonb;
  question_id_uuid uuid;
  option_id_uuid uuid;
  correct_option_id uuid;
  question_difficulty text;
  total_score INT := 0;
  correct_count INT := 0;
  question_count INT := 0;
  -- Variabel untuk menyimpan info pertanyaan pertama (asumsi semua soal dalam submit ini dari quiz yg sama)
  first_question_related_id uuid := NULL;
  first_question_type text := NULL;
BEGIN
  -- Validasi input format (pastikan ini array)
  IF jsonb_typeof(p_answers) <> 'array' THEN
    RAISE EXCEPTION 'Invalid format for p_answers. Expected JSON array of objects like [{"questionId": "...", "optionId": "..."}].';
  END IF;
   IF jsonb_array_length(p_answers) = 0 THEN
      RAISE EXCEPTION 'p_answers cannot be an empty array.';
   END IF;


  -- Loop melalui array jawaban
  FOR answer_data IN SELECT * FROM jsonb_array_elements(p_answers)
  LOOP
    question_count := question_count + 1;

    -- Ekstrak UUID secara eksplisit dan aman
    question_id_uuid := (answer_data->>'questionId')::uuid;
    option_id_uuid := (answer_data->>'optionId')::uuid;

    -- Ambil ID jawaban benar, kesulitan, related_id, dan tipe soal
    SELECT o.id, q.difficulty, q.related_id, q.question_type
    INTO correct_option_id, question_difficulty, first_question_related_id, first_question_type
    FROM public.hicode_options o
    JOIN public.hicode_questions q ON o.question_id = q.id
    WHERE o.question_id = question_id_uuid AND o.is_correct = true;

    -- Jika ini loop pertama, simpan related_id dan type (asumsi 1 quiz = 1 related_id/type)
    -- IF question_count = 1 THEN
      -- first_question_related_id := current_related_id;
      -- first_question_type := current_question_type;
    -- END IF;

    -- Cek jawaban benar
    IF option_id_uuid = correct_option_id THEN
      correct_count := correct_count + 1;
      -- Kalkulasi skor
      CASE question_difficulty
        WHEN 'Mudah' THEN total_score := total_score + 5;
        WHEN 'Menengah' THEN total_score := total_score + 10;
        WHEN 'Sulit' THEN total_score := total_score + 15;
        ELSE total_score := total_score + 0;
      END CASE;
    END IF;
  END LOOP;

  -- Update user progress HANYA JIKA ini adalah Kuis Chapter ('QUIZ')
  -- DAN semua jawaban benar
  IF first_question_type = 'QUIZ' AND first_question_related_id IS NOT NULL AND correct_count = question_count THEN
    -- Pastikan related_id memang ID chapter
    IF EXISTS (SELECT 1 FROM public.hicode_chapters WHERE id = first_question_related_id) THEN
      INSERT INTO public.hicode_user_progress(user_id, chapter_id, is_completed, completed_at, has_reached_bottom)
      VALUES (p_user_id, first_question_related_id, true, now(), true) -- Anggap selesai baca jika kuis selesai
      ON CONFLICT (user_id, chapter_id) DO UPDATE
      SET is_completed = true,
          completed_at = now(),
          has_reached_bottom = true; -- Pastikan has_reached_bottom juga true
    END IF;
  END IF;

  -- TODO: Logika update leaderboard jika first_question_type = 'OVERALL_EXAM'
  -- Membutuhkan parameter time_taken dari Flutter

  -- Kembalikan hasil
  RETURN jsonb_build_object(
    'score', total_score,
    'correct_count', correct_count,
    'total_questions', question_count
  );
END;
$$;


ALTER FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb", "p_time_taken_seconds" integer DEFAULT NULL::integer) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  answer_data jsonb;
  question_id_uuid uuid;
  option_id_uuid uuid;
  correct_option_id uuid;
  question_difficulty text;
  total_score INT := 0;
  correct_count INT := 0;
  question_count_submitted INT := 0; -- <-- Ganti nama variabel
  first_question_related_id uuid := NULL;
  first_question_type text := NULL;
  current_material_id uuid := NULL;
  passed_final_practice BOOLEAN := FALSE;
  existing_leaderboard RECORD;
  
  -- --- TAMBAHAN VARIABEL ---
  total_questions_in_quiz INT := 0; -- Total soal di kuis (dari DB)
  -- --- AKHIR TAMBAHAN ---
  
BEGIN
  IF jsonb_typeof(p_answers) <> 'array' THEN
    RAISE EXCEPTION 'Invalid format for p_answers. Expected JSON array.';
  END IF;

  -- Hitung jumlah jawaban yang disubmit
  question_count_submitted := jsonb_array_length(p_answers);
  
  -- Loop melalui jawaban yang disubmit
  FOR answer_data IN SELECT * FROM jsonb_array_elements(p_answers)
  LOOP
    question_id_uuid := (answer_data->>'questionId')::uuid;
    option_id_uuid := (answer_data->>'optionId')::uuid;

    SELECT
        o.id, q.difficulty
    INTO correct_option_id, question_difficulty
    FROM public.hicode_options o
    JOIN public.hicode_questions q ON o.question_id = q.id
    WHERE o.question_id = question_id_uuid AND o.is_correct = true
    LIMIT 1;
    
    -- Ambil detail kuis dari soal PERTAMA
    IF first_question_type IS NULL THEN
        SELECT 
            q.related_id, 
            q.question_type,
            CASE WHEN q.question_type = 'FINAL_PRACTICE' THEN q.related_id ELSE NULL END
        INTO first_question_related_id, first_question_type, current_material_id
        FROM public.hicode_questions q
        WHERE q.id = question_id_uuid
        LIMIT 1;
    END IF;

    IF option_id_uuid = correct_option_id THEN
      correct_count := correct_count + 1;
      CASE question_difficulty
        WHEN 'Mudah' THEN total_score := total_score + 5;
        WHEN 'Menengah' THEN total_score := total_score + 10;
        WHEN 'Sulit' THEN total_score := total_score + 15;
        ELSE total_score := total_score + 0;
      END CASE;
    END IF;
  END LOOP;

  -- --- LOGIKA PERBAIKAN (BUG 7) ---
  -- Ambil total soal SEBENARNYA dari database
  IF first_question_type IS NOT NULL THEN
    SELECT count(*)::int
    INTO total_questions_in_quiz
    FROM public.hicode_questions q
    WHERE q.related_id = first_question_related_id 
      AND q.question_type = first_question_type;
  END IF;
  
  -- Jika user tidak menjawab apa-apa, tapi total soal ada
  IF question_count_submitted = 0 AND total_questions_in_quiz > 0 THEN
      RAISE EXCEPTION 'Anda harus menjawab setidaknya satu soal.';
  END IF;

  -- --- LOGIKA KELULUSAN ---

  -- 1. KUIS CHAPTER ('QUIZ')
  IF first_question_type = 'QUIZ' AND first_question_related_id IS NOT NULL THEN
    -- Syarat: jawaban benar HARUS SAMA DENGAN total soal di kuis
    IF total_questions_in_quiz > 0 AND correct_count = total_questions_in_quiz THEN
      INSERT INTO public.hicode_user_progress(user_id, chapter_id, is_completed, completed_at, has_reached_bottom)
      VALUES (p_user_id, first_question_related_id, true, now(), true)
      ON CONFLICT (user_id, chapter_id) DO UPDATE
      SET is_completed = true,
          completed_at = now(),
          has_reached_bottom = true;
    END IF;

  -- 2. LATIHAN FINAL ('FINAL_PRACTICE')
  ELSIF first_question_type = 'FINAL_PRACTICE' AND current_material_id IS NOT NULL THEN
    -- Syarat: persentase dihitung dari total_questions_in_quiz
    IF total_questions_in_quiz > 0 AND (correct_count::decimal / total_questions_in_quiz::decimal) >= 0.6 THEN
      passed_final_practice := TRUE;
      INSERT INTO public.hicode_material_progress (user_id, material_id, is_completed, completed_at)
      VALUES (p_user_id, current_material_id, true, now())
      ON CONFLICT (user_id, material_id) DO UPDATE
      SET is_completed = true, completed_at = now();
    END IF;

  -- 3. UJIAN AKHIR ('OVERALL_EXAM')
  ELSIF first_question_type = 'OVERALL_EXAM' THEN
    IF p_time_taken_seconds IS NULL OR p_time_taken_seconds <= 0 THEN
       RAISE EXCEPTION 'Waktu pengerjaan (p_time_taken_seconds) harus valid untuk Ujian Akhir.';
    END IF;
    
    SELECT * INTO existing_leaderboard FROM public.hicode_leaderboard WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        INSERT INTO public.hicode_leaderboard (user_id, highest_score, fastest_time_seconds, last_exam_timestamp)
        VALUES (p_user_id, total_score, p_time_taken_seconds, now());
    ELSE 
        IF total_score > existing_leaderboard.highest_score OR
           (total_score = existing_leaderboard.highest_score AND p_time_taken_seconds < existing_leaderboard.fastest_time_seconds)
        THEN
            UPDATE public.hicode_leaderboard
            SET highest_score = total_score,
                fastest_time_seconds = p_time_taken_seconds,
                last_exam_timestamp = now()
            WHERE user_id = p_user_id;
        ELSE
             UPDATE public.hicode_leaderboard
             SET last_exam_timestamp = now()
             WHERE user_id = p_user_id;
        END IF;
    END IF;
  END IF;

  -- Kembalikan hasil (gunakan total soal dari DB, bukan dari jawaban)
  RETURN jsonb_build_object(
    'score', total_score,
    'correct_count', correct_count,
    'total_questions', total_questions_in_quiz -- <-- Gunakan variabel yang benar
  );
END;
$$;


ALTER FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb", "p_time_taken_seconds" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_hicode_category"("p_id" "uuid", "p_name" "text", "p_icon_url" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE public.hicode_categories
  SET name = p_name, icon_url = p_icon_url
  WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_hicode_category"("p_id" "uuid", "p_name" "text", "p_icon_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE public.hicode_chapters
  SET
    title = p_title,
    content = p_content,
    estimated_read_time = p_estimated_read_time
  WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text" DEFAULT NULL::"text", "p_content" "jsonb" DEFAULT NULL::"jsonb", "p_estimated_read_time" integer DEFAULT NULL::integer, "p_order" smallint DEFAULT NULL::smallint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Validasi: Pastikan chapter ada
  IF NOT EXISTS (SELECT 1 FROM public.hicode_chapters WHERE id = p_id) THEN
      RAISE EXCEPTION 'Chapter dengan ID % tidak ditemukan.', p_id;
  END IF;

  -- Validasi tambahan (opsional tapi bagus)
  IF p_title IS NOT NULL AND trim(p_title) = '' THEN
      RAISE EXCEPTION 'Judul chapter tidak boleh kosong jika diubah.';
  END IF;
  IF p_content IS NOT NULL AND (jsonb_typeof(p_content) <> 'array' OR jsonb_array_length(p_content) = 0 OR (jsonb_array_length(p_content) = 1 AND p_content->0->>'insert' = E'\n')) THEN
      RAISE EXCEPTION 'Konten chapter tidak boleh kosong atau hanya berisi baris baru jika diubah.';
  END IF;


  -- Lakukan UPDATE menggunakan COALESCE
  UPDATE public.hicode_chapters
  SET
    title = COALESCE(p_title, title), -- Gunakan p_title jika tidak NULL, jika NULL gunakan nilai lama (title)
    content = COALESCE(p_content, content), -- Gunakan p_content jika tidak NULL
    estimated_read_time = COALESCE(p_estimated_read_time, estimated_read_time),
    "order" = COALESCE(p_order, "order") -- Gunakan p_order jika tidak NULL
  WHERE id = p_id;

END;
$$;


ALTER FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer, "p_order" smallint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_hicode_material"("p_id" "uuid", "p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE public.hicode_materials
  SET 
    category_id = p_category_id,
    title = p_title,
    description = p_description,
    image_url = COALESCE(p_image_url, image_url),
    border_color = p_border_color
  WHERE id = p_id;
END;
$$;


ALTER FUNCTION "public"."update_hicode_material"("p_id" "uuid", "p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_hicode_question_with_options"("p_question_id" "uuid", "p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  option_data jsonb;
BEGIN
  -- Validasi dasar (tetap sama) ...
  IF NOT EXISTS (SELECT 1 FROM public.hicode_questions WHERE id = p_question_id) THEN RAISE EXCEPTION '...'; END IF;
  -- ... (validasi lainnya) ...

  -- 1. Update data utama hicode_questions (tetap sama)
  UPDATE public.hicode_questions
  SET
    related_id = p_related_id,
    question_type = p_question_type,
    difficulty = p_difficulty,
    question_text = p_question_text,
    image_url = p_image_url
  WHERE id = p_question_id;

  -- 2. Hapus opsi lama (tetap sama)
  DELETE FROM public.hicode_options WHERE question_id = p_question_id;

  -- 3. Masukkan kembali opsi baru dari JSON (dengan image_url)
  FOR option_data IN SELECT * FROM jsonb_array_elements(p_options)
  LOOP
    INSERT INTO public.hicode_options (question_id, option_text, is_correct, image_url) -- Tambah image_url
    VALUES (
      p_question_id,
      option_data->>'option_text',
      (option_data->>'is_correct')::boolean,
      option_data->>'image_url' -- Ambil image_url dari JSON (bisa null)
    );
  END LOOP;

END;
$$;


ALTER FUNCTION "public"."update_hicode_question_with_options"("p_question_id" "uuid", "p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Gunakan UPSERT: Update jika sudah ada, Insert jika belum
  INSERT INTO public.hicode_user_progress (user_id, chapter_id, last_scroll_position)
  VALUES (p_user_id, p_chapter_id, p_position)
  ON CONFLICT (user_id, chapter_id) -- Constraint UNIQUE harus sudah ada
  DO UPDATE SET
    last_scroll_position = EXCLUDED.last_scroll_position,
    -- Jaga agar nilai is_completed tidak ter-reset saat update scroll
    is_completed = public.hicode_user_progress.is_completed
  WHERE public.hicode_user_progress.user_id = p_user_id
    AND public.hicode_user_progress.chapter_id = p_chapter_id;
END;
$$;


ALTER FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision, "p_has_reached_bottom" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_is_quizless BOOLEAN;
  v_should_be_completed BOOLEAN;
BEGIN
  -- 1. Cek apakah chapter ini "hanya-baca"
  SELECT is_quizless INTO v_is_quizless
  FROM public.hicode_chapters
  WHERE id = p_chapter_id;

  -- 2. Tentukan apakah chapter ini SEHARUSNYA selesai
  -- (Hanya jika user di bawah DAN chapter ini quiz-less)
  v_should_be_completed := (p_has_reached_bottom AND v_is_quizless = true);

  -- 3. Masukkan atau perbarui progres
  INSERT INTO public.hicode_user_progress (
    user_id, 
    chapter_id, 
    last_scroll_position, 
    has_reached_bottom, 
    is_completed,
    completed_at
  )
  VALUES (
    p_user_id, 
    p_chapter_id, 
    p_position, 
    p_has_reached_bottom,
    v_should_be_completed, -- Set status 'completed' berdasarkan logika di atas
    CASE WHEN v_should_be_completed THEN now() ELSE NULL END
  )
  ON CONFLICT (user_id, chapter_id)
  DO UPDATE SET
    last_scroll_position = EXCLUDED.last_scroll_position,
    
    -- Jaga agar 'has_reached_bottom' tidak pernah kembali ke 'false'
    has_reached_bottom = CASE
      WHEN public.hicode_user_progress.has_reached_bottom = TRUE THEN TRUE
      ELSE EXCLUDED.has_reached_bottom
    END,
    
    -- Jaga agar 'is_completed' tidak pernah kembali ke 'false'
    is_completed = CASE
      WHEN public.hicode_user_progress.is_completed = TRUE THEN TRUE
      ELSE EXCLUDED.is_completed -- EXCLUDED.is_completed = v_should_be_completed
    END,

    -- Set waktu selesai HANYA JIKA status berubah dari false -> true
    completed_at = CASE
      WHEN public.hicode_user_progress.is_completed = FALSE AND EXCLUDED.is_completed = TRUE THEN now()
      ELSE public.hicode_user_progress.completed_at
    END;
END;
$$;


ALTER FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision, "p_has_reached_bottom" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_pengurus_roles"("p_user_id" "uuid", "p_role_ids_to_assign" "uuid"[]) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    exclusive_role_name TEXT;
    exclusive_role_id UUID;
    existing_user_id UUID;
    role_id_to_check UUID;
BEGIN
    -- Validasi role eksklusif (tidak berubah, sudah benar)
    FOREACH exclusive_role_name IN ARRAY ARRAY['Ketua Himpunan', 'Wakil Ketua Himpunan', 'Sekretaris Umum', 'Wakil Sekretaris Umum', 'Bendahara Umum', 'Wakil Bendahara Umum']
    LOOP
        SELECT id INTO exclusive_role_id FROM public.roles WHERE name = exclusive_role_name;
        IF exclusive_role_id = ANY(p_role_ids_to_assign) THEN
            SELECT ur.user_id INTO existing_user_id
            FROM public.user_roles ur
            WHERE ur.role_id = exclusive_role_id AND ur.user_id <> p_user_id
            LIMIT 1;
            IF FOUND THEN
                RAISE EXCEPTION 'Role "%" sudah dipegang oleh pengguna lain.', exclusive_role_name;
            END IF;
        END IF;
    END LOOP;

    -- PERBAIKAN UTAMA: Hapus semua role PENGURUS yang ada pada pengguna ini
    DELETE FROM public.user_roles
    WHERE user_id = p_user_id
      AND role_id IN (SELECT id FROM public.roles WHERE group_name = 'Pengurus');

    -- Tambahkan kembali role yang dipilih dari daftar
    IF array_length(p_role_ids_to_assign, 1) > 0 THEN
        INSERT INTO public.user_roles(user_id, role_id)
        SELECT p_user_id, unnest(p_role_ids_to_assign)
        ON CONFLICT (user_id, role_id) DO NOTHING;
    END IF;

END;
$$;


ALTER FUNCTION "public"."update_user_pengurus_roles"("p_user_id" "uuid", "p_role_ids_to_assign" "uuid"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_workspace_member_role"("p_workspace_id" "uuid", "p_user_id_to_update" "uuid", "p_new_role" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  current_user_id UUID := (SELECT id FROM public.users WHERE auth_id = auth.uid());
  workspace_owner_id UUID;
BEGIN
  -- 1. Dapatkan ID owner workspace
  SELECT owner_id INTO workspace_owner_id
  FROM public.user_workspace
  WHERE id = p_workspace_id;

  -- 2. Keamanan: Pastikan yang memanggil adalah OWNER
  IF current_user_id <> workspace_owner_id THEN
    RAISE EXCEPTION 'Hanya owner yang dapat mengubah role anggota.';
  END IF;

  -- 3. Keamanan: Owner tidak bisa mengubah role-nya sendiri
  IF current_user_id = p_user_id_to_update THEN
    RAISE EXCEPTION 'Owner tidak dapat mengubah role diri sendiri.';
  END IF;

  -- 4. Validasi Role
  IF p_new_role <> 'editor' AND p_new_role <> 'viewer' THEN
    RAISE EXCEPTION 'Role tidak valid. Gunakan "editor" atau "viewer".';
  END IF;

  -- 5. Update role di tabel workspace_access
  UPDATE public.workspace_access
  SET role = p_new_role
  WHERE workspace_id = p_workspace_id AND user_id = p_user_id_to_update;

END;
$$;


ALTER FUNCTION "public"."update_workspace_member_role"("p_workspace_id" "uuid", "p_user_id_to_update" "uuid", "p_new_role" "text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."divisions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "logo_url" "text" NOT NULL,
    "order" smallint DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."divisions" OWNER TO "postgres";


COMMENT ON TABLE "public"."divisions" IS 'Menyimpan data divisi HIMFO.';



COMMENT ON COLUMN "public"."divisions"."order" IS 'Urutan tampil, angka lebih kecil tampil duluan.';



CREATE TABLE IF NOT EXISTS "public"."event_recurrence" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "frequency" "text" NOT NULL,
    "interval" integer DEFAULT 1 NOT NULL,
    "by_day" "text"[],
    "until_date" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."event_recurrence" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hicode_categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "icon_url" "text" NOT NULL,
    "order" smallint DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."hicode_categories" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_categories" IS 'Menyimpan kategori utama materi HiCode.';



CREATE TABLE IF NOT EXISTS "public"."hicode_chapters" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "material_id" "uuid",
    "title" "text" NOT NULL,
    "content" "jsonb",
    "estimated_read_time" integer,
    "order" smallint DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_quizless" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."hicode_chapters" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_chapters" IS 'Menyimpan konten setiap bab. Kolom content menggunakan JSONB.';



CREATE TABLE IF NOT EXISTS "public"."hicode_leaderboard" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "highest_score" integer DEFAULT 0,
    "last_exam_timestamp" timestamp with time zone,
    "fastest_time_seconds" integer
);


ALTER TABLE "public"."hicode_leaderboard" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_leaderboard" IS 'Menyimpan skor tertinggi Ujian Akhir untuk setiap pengguna.';



CREATE TABLE IF NOT EXISTS "public"."hicode_material_progress" (
    "user_id" "uuid" NOT NULL,
    "material_id" "uuid" NOT NULL,
    "is_completed" boolean DEFAULT false,
    "completed_at" timestamp with time zone
);


ALTER TABLE "public"."hicode_material_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hicode_materials" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" "uuid",
    "title" "text" NOT NULL,
    "description" "text",
    "image_url" "text",
    "border_color" "text",
    "order" smallint DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."hicode_materials" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_materials" IS 'Menyimpan materi pembelajaran utama yang berisi beberapa chapter.';



CREATE TABLE IF NOT EXISTS "public"."hicode_options" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "question_id" "uuid",
    "option_text" "text" NOT NULL,
    "is_correct" boolean NOT NULL,
    "image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."hicode_options" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_options" IS 'Menyimpan pilihan jawaban untuk setiap soal.';



CREATE TABLE IF NOT EXISTS "public"."hicode_questions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "related_id" "uuid" NOT NULL,
    "question_type" "text" NOT NULL,
    "difficulty" "text" NOT NULL,
    "question_text" "text" NOT NULL,
    "image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "hicode_questions_difficulty_check" CHECK (("difficulty" = ANY (ARRAY['Mudah'::"text", 'Menengah'::"text", 'Sulit'::"text"]))),
    CONSTRAINT "hicode_questions_question_type_check" CHECK (("question_type" = ANY (ARRAY['QUIZ'::"text", 'FINAL_PRACTICE'::"text", 'OVERALL_EXAM'::"text"])))
);


ALTER TABLE "public"."hicode_questions" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_questions" IS 'Bank soal untuk semua jenis ujian di HiCode.';



CREATE TABLE IF NOT EXISTS "public"."hicode_user_progress" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "chapter_id" "uuid" NOT NULL,
    "is_completed" boolean DEFAULT false,
    "last_scroll_position" double precision DEFAULT 0.0,
    "completed_at" timestamp with time zone,
    "has_reached_bottom" boolean DEFAULT false
);


ALTER TABLE "public"."hicode_user_progress" OWNER TO "postgres";


COMMENT ON TABLE "public"."hicode_user_progress" IS 'Melacak progres belajar setiap pengguna per chapter.';



CREATE TABLE IF NOT EXISTS "public"."home_banners" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "image_url" "text" NOT NULL,
    "order" smallint DEFAULT 0 NOT NULL,
    "subtitle" "text",
    "link_url" "text"
);


ALTER TABLE "public"."home_banners" OWNER TO "postgres";


COMMENT ON TABLE "public"."home_banners" IS 'Menyimpan data banner untuk halaman utama.';



COMMENT ON COLUMN "public"."home_banners"."order" IS 'Urutan tampil, angka lebih kecil tampil duluan.';



CREATE TABLE IF NOT EXISTS "public"."permissions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "feature_name" "text" NOT NULL,
    "action_name" "text" NOT NULL
);


ALTER TABLE "public"."permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."program_studi" (
    "kode_prodi" "text" NOT NULL,
    "nama_prodi" "text" NOT NULL,
    "nama_fakultas" "text" NOT NULL,
    "kode_kampus" "text" NOT NULL,
    "nama_kampus" "text" NOT NULL
);


ALTER TABLE "public"."program_studi" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_invitation_responses" (
    "invitation_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "responded_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."role_invitation_responses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_id" "uuid" NOT NULL
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" "text" NOT NULL,
    "group_name" "text" NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sent_notifications" (
    "event_id" "uuid" NOT NULL,
    "notification_time" timestamp with time zone NOT NULL,
    "sent_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sent_notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_workspace" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_id" "uuid",
    "title" "text",
    "description" "text",
    "content" "jsonb",
    "last_updated" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_workspace" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "auth_id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "full_name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone_number" "text",
    "date_of_birth" "date",
    "profile_url" "text",
    "npm" "text",
    "nomor_mahasiswa" "text",
    "is_email_verified" boolean DEFAULT false,
    "is_from_unsika" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "verified_at" timestamp with time zone,
    "fcm_token" "text"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workspace_access" (
    "workspace_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "can_edit" boolean DEFAULT false,
    "invited_at" timestamp with time zone DEFAULT "now"(),
    "role" "text" DEFAULT 'viewer'::"text" NOT NULL
);


ALTER TABLE "public"."workspace_access" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workspace_invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "workspace_id" "uuid" NOT NULL,
    "inviter_id" "uuid" NOT NULL,
    "invitee_id" "uuid",
    "target_role_ids" "uuid"[],
    "role_to_grant" "text" DEFAULT 'viewer'::"text" NOT NULL,
    "token" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "invitation_type" "text" DEFAULT 'personal'::"text" NOT NULL,
    "expires_at" timestamp with time zone
);


ALTER TABLE "public"."workspace_invitations" OWNER TO "postgres";


ALTER TABLE ONLY "public"."divisions"
    ADD CONSTRAINT "divisions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."event_recurrence"
    ADD CONSTRAINT "event_recurrence_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_categories"
    ADD CONSTRAINT "hicode_categories_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."hicode_categories"
    ADD CONSTRAINT "hicode_categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_chapters"
    ADD CONSTRAINT "hicode_chapters_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_leaderboard"
    ADD CONSTRAINT "hicode_leaderboard_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_leaderboard"
    ADD CONSTRAINT "hicode_leaderboard_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."hicode_material_progress"
    ADD CONSTRAINT "hicode_material_progress_pkey" PRIMARY KEY ("user_id", "material_id");



ALTER TABLE ONLY "public"."hicode_materials"
    ADD CONSTRAINT "hicode_materials_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_options"
    ADD CONSTRAINT "hicode_options_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_questions"
    ADD CONSTRAINT "hicode_questions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_user_progress"
    ADD CONSTRAINT "hicode_user_progress_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hicode_user_progress"
    ADD CONSTRAINT "hicode_user_progress_user_id_chapter_id_key" UNIQUE ("user_id", "chapter_id");



ALTER TABLE ONLY "public"."home_banners"
    ADD CONSTRAINT "home_banners_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."program_studi"
    ADD CONSTRAINT "program_studi_pkey" PRIMARY KEY ("kode_prodi");



ALTER TABLE ONLY "public"."role_invitation_responses"
    ADD CONSTRAINT "role_invitation_responses_pkey" PRIMARY KEY ("invitation_id", "user_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id", "permission_id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sent_notifications"
    ADD CONSTRAINT "sent_notifications_pkey" PRIMARY KEY ("event_id", "notification_time");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id", "role_id");



ALTER TABLE ONLY "public"."user_workspace"
    ADD CONSTRAINT "user_workspace_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_auth_id_key" UNIQUE ("auth_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_unique" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_phone_unique" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."workspace_access"
    ADD CONSTRAINT "workspace_access_pkey" PRIMARY KEY ("workspace_id", "user_id");



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_token_key" UNIQUE ("token");



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_workspace_id_invitee_id_key" UNIQUE ("workspace_id", "invitee_id");



CREATE INDEX "idx_chapters_is_quizless" ON "public"."hicode_chapters" USING "btree" ("is_quizless");



CREATE UNIQUE INDEX "users_username_unique_ci" ON "public"."users" USING "btree" ("lower"("username"));



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_recurrence_id_fkey" FOREIGN KEY ("recurrence_id") REFERENCES "public"."event_recurrence"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "public"."user_workspace"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_workspace"
    ADD CONSTRAINT "fk_owner" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "fk_user_roles_user_id" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."hicode_chapters"
    ADD CONSTRAINT "hicode_chapters_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "public"."hicode_materials"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_leaderboard"
    ADD CONSTRAINT "hicode_leaderboard_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_material_progress"
    ADD CONSTRAINT "hicode_material_progress_material_id_fkey" FOREIGN KEY ("material_id") REFERENCES "public"."hicode_materials"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_material_progress"
    ADD CONSTRAINT "hicode_material_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_materials"
    ADD CONSTRAINT "hicode_materials_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."hicode_categories"("id");



ALTER TABLE ONLY "public"."hicode_options"
    ADD CONSTRAINT "hicode_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."hicode_questions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_user_progress"
    ADD CONSTRAINT "hicode_user_progress_chapter_id_fkey" FOREIGN KEY ("chapter_id") REFERENCES "public"."hicode_chapters"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."hicode_user_progress"
    ADD CONSTRAINT "hicode_user_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_invitation_responses"
    ADD CONSTRAINT "role_invitation_responses_invitation_id_fkey" FOREIGN KEY ("invitation_id") REFERENCES "public"."workspace_invitations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_invitation_responses"
    ADD CONSTRAINT "role_invitation_responses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sent_notifications"
    ADD CONSTRAINT "sent_notifications_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_workspace"
    ADD CONSTRAINT "user_workspace_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."workspace_access"
    ADD CONSTRAINT "workspace_access_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."workspace_access"
    ADD CONSTRAINT "workspace_access_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "public"."user_workspace"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_invitee_id_fkey" FOREIGN KEY ("invitee_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_inviter_id_fkey" FOREIGN KEY ("inviter_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."workspace_invitations"
    ADD CONSTRAINT "workspace_invitations_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "public"."user_workspace"("id") ON DELETE CASCADE;



CREATE POLICY "Allow HiCode Admins to view all material progress" ON "public"."hicode_material_progress" FOR SELECT TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow authenticated read access" ON "public"."hicode_leaderboard" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access to divisions" ON "public"."divisions" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated read access to home banners" ON "public"."home_banners" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to create workspaces" ON "public"."user_workspace" FOR INSERT WITH CHECK (("owner_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow authenticated users to read options" ON "public"."hicode_options" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to read roles" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow authenticated users to see other users" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow full access for HiCode Admins" ON "public"."hicode_categories" TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"]))))) WITH CHECK ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow full access for HiCode Admins" ON "public"."hicode_chapters" TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"]))))) WITH CHECK ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow full access for HiCode Admins" ON "public"."hicode_materials" TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"]))))) WITH CHECK ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow full access for HiCode Admins" ON "public"."hicode_options" TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"]))))) WITH CHECK ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow full access for HiCode Admins" ON "public"."hicode_questions" TO "authenticated" USING ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"]))))) WITH CHECK ((( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())) IN ( SELECT "ur"."user_id"
   FROM ("public"."user_roles" "ur"
     JOIN "public"."roles" "r" ON (("ur"."role_id" = "r"."id")))
  WHERE ("r"."name" = ANY (ARRAY['Ketua Himpunan'::"text", 'Wakil Ketua Himpunan'::"text", 'Edukasi'::"text", 'RnD'::"text"])))));



CREATE POLICY "Allow managers to CUD events in Agenda Himtika" ON "public"."events" USING ((("workspace_id" <> ( SELECT "user_workspace"."id"
   FROM "public"."user_workspace"
  WHERE ("user_workspace"."title" = 'Agenda Himtika'::"text"))) OR (("workspace_id" = ( SELECT "user_workspace"."id"
   FROM "public"."user_workspace"
  WHERE ("user_workspace"."title" = 'Agenda Himtika'::"text"))) AND ("public"."is_agenda_manager"() = true))));



CREATE POLICY "Allow members and invitees to see workspaces" ON "public"."user_workspace" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM ("public"."workspace_access" "wa"
     JOIN "public"."users" "u" ON (("wa"."user_id" = "u"."id")))
  WHERE (("wa"."workspace_id" = "user_workspace"."id") AND ("u"."auth_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM ("public"."workspace_invitations" "wi"
     JOIN "public"."users" "u" ON (("wi"."invitee_id" = "u"."id")))
  WHERE (("wi"."workspace_id" = "user_workspace"."id") AND ("u"."auth_id" = "auth"."uid"()) AND ("wi"."status" = 'pending'::"text"))))));



CREATE POLICY "Allow members to see events in their workspaces" ON "public"."events" FOR SELECT USING (("workspace_id" IN ( SELECT "public"."get_my_workspace_ids"() AS "get_my_workspace_ids")));



CREATE POLICY "Allow members to see other members of the same workspace" ON "public"."workspace_access" FOR SELECT USING (("workspace_id" IN ( SELECT "public"."get_my_workspace_ids"() AS "get_my_workspace_ids")));



CREATE POLICY "Allow owners and editors to create events" ON "public"."events" FOR INSERT WITH CHECK ((( SELECT "workspace_access"."role"
   FROM "public"."workspace_access"
  WHERE (("workspace_access"."workspace_id" = "events"."workspace_id") AND ("workspace_access"."user_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_id" = "auth"."uid"()))))) = ANY (ARRAY['owner'::"text", 'editor'::"text"])));



CREATE POLICY "Allow owners and editors to delete events" ON "public"."events" FOR DELETE USING ((( SELECT "workspace_access"."role"
   FROM "public"."workspace_access"
  WHERE (("workspace_access"."workspace_id" = "events"."workspace_id") AND ("workspace_access"."user_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_id" = "auth"."uid"()))))) = ANY (ARRAY['owner'::"text", 'editor'::"text"])));



CREATE POLICY "Allow owners and editors to update events" ON "public"."events" FOR UPDATE USING ((( SELECT "workspace_access"."role"
   FROM "public"."workspace_access"
  WHERE (("workspace_access"."workspace_id" = "events"."workspace_id") AND ("workspace_access"."user_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_id" = "auth"."uid"()))))) = ANY (ARRAY['owner'::"text", 'editor'::"text"])));



CREATE POLICY "Allow owners to add new members" ON "public"."workspace_access" FOR INSERT WITH CHECK ((( SELECT "user_workspace"."owner_id"
   FROM "public"."user_workspace"
  WHERE ("user_workspace"."id" = "workspace_access"."workspace_id")) = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow owners to delete their workspaces" ON "public"."user_workspace" FOR DELETE USING (("owner_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow owners to remove members" ON "public"."workspace_access" FOR DELETE USING (((( SELECT "user_workspace"."owner_id"
   FROM "public"."user_workspace"
  WHERE ("user_workspace"."id" = "workspace_access"."workspace_id")) = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))) AND ("user_id" <> ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())))));



CREATE POLICY "Allow owners to update member roles" ON "public"."workspace_access" FOR UPDATE USING ((( SELECT "user_workspace"."owner_id"
   FROM "public"."user_workspace"
  WHERE ("user_workspace"."id" = "workspace_access"."workspace_id")) = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow owners to update their workspaces" ON "public"."user_workspace" FOR UPDATE USING (("owner_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow user to manage own material progress" ON "public"."hicode_material_progress" TO "authenticated" USING (("user_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"())))) WITH CHECK (("user_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Allow user to manage their own progress" ON "public"."hicode_user_progress" TO "authenticated" USING (("auth"."uid"() = ( SELECT "users"."auth_id"
   FROM "public"."users"
  WHERE ("users"."id" = "hicode_user_progress"."user_id")))) WITH CHECK (("auth"."uid"() = ( SELECT "users"."auth_id"
   FROM "public"."users"
  WHERE ("users"."id" = "hicode_user_progress"."user_id"))));



CREATE POLICY "Allow user to read own roles" ON "public"."user_roles" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_id" = "auth"."uid"()))));



CREATE POLICY "Prevent deletion of global Agenda Himtika" ON "public"."user_workspace" FOR DELETE USING (("title" <> 'Agenda Himtika'::"text"));



CREATE POLICY "Receiver can view access" ON "public"."workspace_access" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "User can see their own data" ON "public"."users" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update own data" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "auth_id"));



CREATE POLICY "Users can view own data" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "auth_id"));



CREATE POLICY "Workspace owner can insert" ON "public"."user_workspace" FOR INSERT WITH CHECK (("auth"."uid"() = "owner_id"));



CREATE POLICY "Workspace owner can read" ON "public"."user_workspace" FOR SELECT USING (("auth"."uid"() = "owner_id"));



CREATE POLICY "Workspace owner can update" ON "public"."user_workspace" FOR UPDATE USING (("auth"."uid"() = "owner_id"));



ALTER TABLE "public"."divisions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."events" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_chapters" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_leaderboard" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_material_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_materials" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_options" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_questions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hicode_user_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."home_banners" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."program_studi" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "public.users_select_own" ON "public"."users" FOR SELECT USING ((("auth"."uid"())::"text" = ("auth_id")::"text"));



CREATE POLICY "public.users_update_own" ON "public"."users" FOR UPDATE USING ((("auth"."uid"())::"text" = ("auth_id")::"text"));



ALTER TABLE "public"."role_invitation_responses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sent_notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_workspace" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_select_own" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "auth_id"));



CREATE POLICY "users_update_own" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "auth_id")) WITH CHECK (("auth"."uid"() = "auth_id"));



ALTER TABLE "public"."workspace_access" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";








GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";














































































































































































GRANT ALL ON FUNCTION "public"."accept_invitation_by_id"("p_invitation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."accept_invitation_by_id"("p_invitation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_invitation_by_id"("p_invitation_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_invitation_by_token"("p_invitation_token" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."accept_invitation_by_token"("p_invitation_token" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_invitation_by_token"("p_invitation_token" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."accept_link_invitation"("p_invitation_token" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."accept_link_invitation"("p_invitation_token" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_link_invitation"("p_invitation_token" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_overall_exam_availability"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."check_overall_exam_availability"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_overall_exam_availability"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_for_reset"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_for_reset"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_for_reset"("p_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_sent_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_sent_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_sent_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_hicode_category"("p_name" "text", "p_icon_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_hicode_category"("p_name" "text", "p_icon_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_hicode_category"("p_name" "text", "p_icon_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_hicode_chapter"("p_material_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."create_hicode_chapter"("p_material_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_hicode_chapter"("p_material_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_hicode_material"("p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_hicode_material"("p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_hicode_material"("p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_hicode_question_with_options"("p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_hicode_question_with_options"("p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_hicode_question_with_options"("p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_new_workspace"("p_title" "text", "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_new_workspace"("p_title" "text", "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_new_workspace"("p_title" "text", "p_description" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_recurring_event_transaction"("p_workspace_id" "uuid", "p_created_by" "uuid", "p_title" "text", "p_description" "text", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_by_day" "text"[], "p_until_date" timestamp with time zone, "p_reminder_minutes_before" integer[]) TO "anon";
GRANT ALL ON FUNCTION "public"."create_recurring_event_transaction"("p_workspace_id" "uuid", "p_created_by" "uuid", "p_title" "text", "p_description" "text", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_by_day" "text"[], "p_until_date" timestamp with time zone, "p_reminder_minutes_before" integer[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_recurring_event_transaction"("p_workspace_id" "uuid", "p_created_by" "uuid", "p_title" "text", "p_description" "text", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_by_day" "text"[], "p_until_date" timestamp with time zone, "p_reminder_minutes_before" integer[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_workspace_invitation_link"("p_workspace_id" "uuid", "p_role_to_grant" "text", "p_duration_minutes" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."create_workspace_invitation_link"("p_workspace_id" "uuid", "p_role_to_grant" "text", "p_duration_minutes" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_workspace_invitation_link"("p_workspace_id" "uuid", "p_role_to_grant" "text", "p_duration_minutes" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."decline_workspace_invitation"("p_invitation_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."decline_workspace_invitation"("p_invitation_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."decline_workspace_invitation"("p_invitation_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_hicode_category"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_hicode_category"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_hicode_category"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_hicode_chapter"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_hicode_chapter"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_hicode_chapter"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_hicode_material"("p_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_hicode_material"("p_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_hicode_material"("p_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_hicode_question"("p_question_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_hicode_question"("p_question_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_hicode_question"("p_question_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_unverified_users"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_unverified_users"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_unverified_users"() TO "service_role";



GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_dashboard_info"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_dashboard_info"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_dashboard_info"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_hicode_chapters"("p_material_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_hicode_chapters"("p_material_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_hicode_chapters"("p_material_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_hicode_materials"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_hicode_materials"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_hicode_materials"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_chapters_for_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_chapters_for_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_chapters_for_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_materials_for_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_materials_for_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_materials_for_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_roles_grouped"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_roles_grouped"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_roles_grouped"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_users_with_roles"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_users_with_roles"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_users_with_roles"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_assignable_roles"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_assignable_roles"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_assignable_roles"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_chapter_list"("p_user_id" "uuid", "p_material_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_chapter_list"("p_user_id" "uuid", "p_material_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_chapter_list"("p_user_id" "uuid", "p_material_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."events" TO "anon";
GRANT ALL ON TABLE "public"."events" TO "authenticated";
GRANT ALL ON TABLE "public"."events" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_events_in_range"("p_workspace_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_events_in_range"("p_workspace_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_events_in_range"("p_workspace_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_categories"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_categories"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_categories"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_chapter_content"("p_chapter_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_main_screen"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_main_screen"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_main_screen"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_questions"("p_related_id" "uuid", "p_question_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_questions"("p_related_id" "uuid", "p_question_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_questions"("p_related_id" "uuid", "p_question_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text", "p_related_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text", "p_related_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_hicode_questions_admin"("p_limit" integer, "p_offset" integer, "p_question_type" "text", "p_related_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_leaderboard"("p_filter" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_leaderboard"("p_filter" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_leaderboard"("p_filter" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_material_details"("p_material_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_material_details"("p_material_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_material_details"("p_material_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_workspace_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_workspace_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_workspace_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_workspaces_with_members"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_workspaces_with_members"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_workspaces_with_members"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_pending_notifications"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_pending_notifications"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_pending_notifications"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_question_details"("p_question_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_question_details"("p_question_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_question_details"("p_question_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_role_in_workspace"("p_workspace_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_role_in_workspace"("p_workspace_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_role_in_workspace"("p_workspace_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_auth_user"("user_id" "uuid", "user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"("user_id" "uuid", "user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_auth_user"("user_id" "uuid", "user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."invite_user_to_workspace"("p_workspace_id" "uuid", "p_invitee_email" "text", "p_role_to_grant" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."invite_user_to_workspace"("p_workspace_id" "uuid", "p_invitee_email" "text", "p_role_to_grant" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."invite_user_to_workspace"("p_workspace_id" "uuid", "p_invitee_email" "text", "p_role_to_grant" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."invite_users_by_roles"("p_workspace_id" "uuid", "p_target_role_ids" "uuid"[], "p_role_to_grant" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."invite_users_by_roles"("p_workspace_id" "uuid", "p_target_role_ids" "uuid"[], "p_role_to_grant" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."invite_users_by_roles"("p_workspace_id" "uuid", "p_target_role_ids" "uuid"[], "p_role_to_grant" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_agenda_manager"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_agenda_manager"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_agenda_manager"() TO "service_role";



GRANT ALL ON FUNCTION "public"."on_email_verified"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_email_verified"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_email_verified"() TO "service_role";



GRANT ALL ON FUNCTION "public"."search_admin_users"("p_query" "text", "p_scope" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."search_admin_users"("p_query" "text", "p_scope" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_admin_users"("p_query" "text", "p_scope" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."search_users"("p_query" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."search_users"("p_query" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."search_users"("p_query" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_email_verified"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."set_email_verified"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_email_verified"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb", "p_time_taken_seconds" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb", "p_time_taken_seconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_hicode_answers"("p_user_id" "uuid", "p_answers" "jsonb", "p_time_taken_seconds" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_hicode_category"("p_id" "uuid", "p_name" "text", "p_icon_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_hicode_category"("p_id" "uuid", "p_name" "text", "p_icon_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_hicode_category"("p_id" "uuid", "p_name" "text", "p_icon_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer, "p_order" smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer, "p_order" smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_hicode_chapter"("p_id" "uuid", "p_title" "text", "p_content" "jsonb", "p_estimated_read_time" integer, "p_order" smallint) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_hicode_material"("p_id" "uuid", "p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_hicode_material"("p_id" "uuid", "p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_hicode_material"("p_id" "uuid", "p_category_id" "uuid", "p_title" "text", "p_description" "text", "p_image_url" "text", "p_border_color" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_hicode_question_with_options"("p_question_id" "uuid", "p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_hicode_question_with_options"("p_question_id" "uuid", "p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_hicode_question_with_options"("p_question_id" "uuid", "p_related_id" "uuid", "p_question_type" "text", "p_difficulty" "text", "p_question_text" "text", "p_image_url" "text", "p_options" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision, "p_has_reached_bottom" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision, "p_has_reached_bottom" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_scroll_position"("p_user_id" "uuid", "p_chapter_id" "uuid", "p_position" double precision, "p_has_reached_bottom" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_pengurus_roles"("p_user_id" "uuid", "p_role_ids_to_assign" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_pengurus_roles"("p_user_id" "uuid", "p_role_ids_to_assign" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_pengurus_roles"("p_user_id" "uuid", "p_role_ids_to_assign" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."update_workspace_member_role"("p_workspace_id" "uuid", "p_user_id_to_update" "uuid", "p_new_role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_workspace_member_role"("p_workspace_id" "uuid", "p_user_id_to_update" "uuid", "p_new_role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_workspace_member_role"("p_workspace_id" "uuid", "p_user_id_to_update" "uuid", "p_new_role" "text") TO "service_role";
























GRANT ALL ON TABLE "public"."divisions" TO "anon";
GRANT ALL ON TABLE "public"."divisions" TO "authenticated";
GRANT ALL ON TABLE "public"."divisions" TO "service_role";



GRANT ALL ON TABLE "public"."event_recurrence" TO "anon";
GRANT ALL ON TABLE "public"."event_recurrence" TO "authenticated";
GRANT ALL ON TABLE "public"."event_recurrence" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_categories" TO "anon";
GRANT ALL ON TABLE "public"."hicode_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_categories" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_chapters" TO "anon";
GRANT ALL ON TABLE "public"."hicode_chapters" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_chapters" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_leaderboard" TO "anon";
GRANT ALL ON TABLE "public"."hicode_leaderboard" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_leaderboard" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_material_progress" TO "anon";
GRANT ALL ON TABLE "public"."hicode_material_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_material_progress" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_materials" TO "anon";
GRANT ALL ON TABLE "public"."hicode_materials" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_materials" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_options" TO "anon";
GRANT ALL ON TABLE "public"."hicode_options" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_options" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_questions" TO "anon";
GRANT ALL ON TABLE "public"."hicode_questions" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_questions" TO "service_role";



GRANT ALL ON TABLE "public"."hicode_user_progress" TO "anon";
GRANT ALL ON TABLE "public"."hicode_user_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."hicode_user_progress" TO "service_role";



GRANT ALL ON TABLE "public"."home_banners" TO "anon";
GRANT ALL ON TABLE "public"."home_banners" TO "authenticated";
GRANT ALL ON TABLE "public"."home_banners" TO "service_role";



GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";



GRANT ALL ON TABLE "public"."program_studi" TO "anon";
GRANT ALL ON TABLE "public"."program_studi" TO "authenticated";
GRANT ALL ON TABLE "public"."program_studi" TO "service_role";



GRANT ALL ON TABLE "public"."role_invitation_responses" TO "anon";
GRANT ALL ON TABLE "public"."role_invitation_responses" TO "authenticated";
GRANT ALL ON TABLE "public"."role_invitation_responses" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."sent_notifications" TO "anon";
GRANT ALL ON TABLE "public"."sent_notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."sent_notifications" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";



GRANT ALL ON TABLE "public"."user_workspace" TO "anon";
GRANT ALL ON TABLE "public"."user_workspace" TO "authenticated";
GRANT ALL ON TABLE "public"."user_workspace" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."workspace_access" TO "anon";
GRANT ALL ON TABLE "public"."workspace_access" TO "authenticated";
GRANT ALL ON TABLE "public"."workspace_access" TO "service_role";



GRANT ALL ON TABLE "public"."workspace_invitations" TO "anon";
GRANT ALL ON TABLE "public"."workspace_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."workspace_invitations" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER trg_on_email_verified AFTER UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION public.on_email_verified();


  create policy "Allow HiCode Admins to Upload"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'hicode_assets'::text) AND (( SELECT users.id
   FROM public.users
  WHERE (users.auth_id = auth.uid())) IN ( SELECT ur.user_id
   FROM (public.user_roles ur
     JOIN public.roles r ON ((ur.role_id = r.id)))
  WHERE (r.name = ANY (ARRAY['Ketua Himpunan'::text, 'Wakil Ketua Himpunan'::text, 'Edukasi'::text, 'RnD'::text]))))));



  create policy "Allow authenticated read access to material images"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'hicode_assets'::text) AND ((storage.foldername(name))[1] = 'images'::text)));



  create policy "Allow authenticated uploads to icon folder"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'hicode_assets'::text) AND ((storage.foldername(name))[1] = 'icon'::text)));



  create policy "Allow authenticated uploads to images folder"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'hicode_assets'::text) AND ((storage.foldername(name))[1] = 'images'::text)));



  create policy "Allow authenticated users to view their own icons"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'hicode_assets'::text) AND ((storage.foldername(name))[1] = 'icon'::text) AND (owner = auth.uid())));



  create policy "Users can upload their profile pic"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check ((bucket_id = 'profile-pictures'::text));



