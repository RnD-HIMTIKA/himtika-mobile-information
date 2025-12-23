CREATE OR REPLACE TRIGGER "on-new-invitation" AFTER INSERT ON "public"."workspace_invitations" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/invitation-notifier', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_category_delete_cleanup" AFTER DELETE ON "public"."hicode_categories" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_category_update_cleanup" AFTER UPDATE ON "public"."hicode_categories" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_chapter_delete_cleanup" AFTER DELETE ON "public"."hicode_chapters" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_chapter_update_cleanup" AFTER UPDATE ON "public"."hicode_chapters" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_material_delete_cleanup" AFTER DELETE ON "public"."hicode_materials" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_material_update_cleanup" AFTER UPDATE ON "public"."hicode_materials" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_option_delete_cleanup" AFTER DELETE ON "public"."hicode_options" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_option_update_cleanup" AFTER UPDATE ON "public"."hicode_options" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_question_delete_cleanup" AFTER DELETE ON "public"."hicode_questions" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "on_question_update_cleanup" AFTER UPDATE ON "public"."hicode_questions" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://pjbbhwdznqubtskdxdgu.supabase.co/functions/v1/cleanup-storage', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqYmJod2R6bnF1YnRza2R4ZGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MTE1NDQsImV4cCI6MjA4MTk4NzU0NH0.5GdNuepwrF9PfqhgQLMYAyp6eqEEfrAN8cFF_C6TuKc"}', '{}', '5000');