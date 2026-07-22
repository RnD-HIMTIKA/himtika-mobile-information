-- A. Pastikan kolom 'name' di tabel roles bersifat UNIQUE
-- (Hanya akan dijalankan jika constrain unique belum ada)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'roles_name_key'
    ) THEN
        ALTER TABLE public.roles ADD CONSTRAINT roles_name_key UNIQUE (name);
    END IF;
END $$;


-- 1. Buat Role 'Developers' di Group 'System'
-- Sekarang ON CONFLICT (name) akan berhasil karena kolom 'name' sudah Unique.
INSERT INTO public.roles (name, group_name)
VALUES ('Developers', 'System')
ON CONFLICT (name) DO NOTHING;


-- 2. Update RPC Search User
CREATE OR REPLACE FUNCTION public.search_admin_users(
    p_query text,
    p_scope text DEFAULT 'HIMA'::text
)
RETURNS TABLE(user_id uuid, username text, full_name text, roles jsonb) 
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_caller_role_names text[];
BEGIN
    -- Ambil semua role milik si pemanggil (Caller)
    SELECT array_agg(r.name) INTO v_caller_role_names
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid());

    -- VALIDASI AKSES:
    -- Jika scope GENERAL, hanya boleh diakses oleh Developers atau RnD
    IF p_scope = 'GENERAL' THEN
        IF NOT ('Developers' = ANY(v_caller_role_names) OR 'RnD' = ANY(v_caller_role_names)) THEN
             RAISE EXCEPTION 'Access Denied: Hanya Developers dan RnD yang bisa akses General Roles.';
        END IF;
    END IF;

    -- QUERY UTAMA
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
            WHERE ur.user_id = u.id
        ) as roles
    FROM public.users u
    WHERE
        (p_query IS NULL OR p_query = '' OR
         u.full_name ILIKE '%' || p_query || '%' OR
         u.username ILIKE '%' || p_query || '%' OR
         u.npm ILIKE '%' || p_query || '%')
    ORDER BY u.created_at DESC
    LIMIT 100;
END;
$$;


-- 3. LOGIC "SERAH TERIMA JABATAN" (RPC AMAN)
CREATE OR REPLACE FUNCTION public.assign_exclusive_role(
    p_target_user_id uuid,
    p_role_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id uuid;
    v_caller_role_names text[];
    v_current_holder_id uuid;
BEGIN
    -- A. Cari ID Role target
    SELECT id INTO v_role_id FROM public.roles WHERE name = p_role_name;
    IF v_role_id IS NULL THEN
        RAISE EXCEPTION 'Role % tidak ditemukan', p_role_name;
    END IF;

    -- B. Cek Siapa Caller-nya?
    SELECT array_agg(r.name) INTO v_caller_role_names
    FROM public.user_roles ur
    JOIN public.roles r ON ur.role_id = r.id
    WHERE ur.user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid());

    -- Logika Izin
    IF 'Developers' = ANY(v_caller_role_names) THEN
        NULL; -- Developer boleh bypass
    ELSIF p_role_name = ANY(v_caller_role_names) THEN
        NULL; -- Ketua Lama boleh oper jabatan
    ELSE
        RAISE EXCEPTION 'Anda tidak memiliki hak untuk memindahkan jabatan %', p_role_name;
    END IF;

    -- C. SERAH TERIMA
    SELECT user_id INTO v_current_holder_id 
    FROM public.user_roles 
    WHERE role_id = v_role_id 
    LIMIT 1;

    IF v_current_holder_id IS NOT NULL THEN
        IF v_current_holder_id = p_target_user_id THEN
            RETURN;
        END IF;
        DELETE FROM public.user_roles WHERE role_id = v_role_id AND user_id = v_current_holder_id;
    END IF;

    INSERT INTO public.user_roles (user_id, role_id)
    VALUES (p_target_user_id, v_role_id);
END;
$$;