-- 1. Pastikan ekstensi aktif
create extension if not exists pg_cron;

-- 2. Bersihkan job lama DENGAN AMAN (Safe Unschedule)
-- Teknik ini hanya akan menjalankan unschedule JIKA jobname ditemukan di tabel cron.job
-- Jadi tidak akan error kalau job-nya belum ada.
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'daily-unverified-user-cleanup';
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'check-event-reminders';
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'daily-notification-cleanup';

-- 3. Jadwalkan Ulang (Re-Schedule)

-- Job A: Hapus User Unverified (Tiap jam 12 malam)
select cron.schedule(
    'daily-unverified-user-cleanup',
    '0 0 * * *',
    $$ SELECT public.delete_unverified_users() $$
);

-- Job B: Notification Cleanup (Tiap jam 12 malam)
select cron.schedule(
    'daily-notification-cleanup',
    '0 0 * * *',
    $$ SELECT public.cleanup_sent_notifications() $$
);

-- Job C: Event Reminder (Tiap 5 menit)
-- Karena Anda menghapus Bearer (Auth), pastikan Function di Dev nanti
-- diatur untuk membolehkan Anon atau Service Role, atau Anda update tokennya nanti via Dashboard.
select cron.schedule(
    'check-event-reminders',
    '*/5 * * * *',
    $$
    SELECT
      net.http_post(
          url:='https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/event-reminder', -- Gunakan URL DEV Anda
          headers:=jsonb_build_object(
              'Content-Type', 'application/json',
              'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc' 
          )
      );
    $$
);