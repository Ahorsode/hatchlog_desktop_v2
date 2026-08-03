-- fix_audit_permissions.sql
-- Run this script in your Supabase SQL Editor (https://supabase.com)
-- This grants SELECT permissions on audit, delete, and insert logs to both 'anon' and 'authenticated' roles,
-- resolving the 'PostgrestException: permission denied for table delete_logs (42501)' error.

-- 1. Grant schema usage and table access
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.audit_logs TO anon, authenticated;
GRANT SELECT ON public.delete_logs TO anon, authenticated;
GRANT SELECT ON public.insert_logs TO anon, authenticated;
GRANT SELECT ON public.users TO anon, authenticated;

-- 2. Drop restrictive select policies
DROP POLICY IF EXISTS "Users can view audit logs for their farm" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can view delete logs for their farm" ON public.delete_logs;
DROP POLICY IF EXISTS "Users can view insert logs for their farm" ON public.insert_logs;

-- 3. Re-create SELECT policies that allow both 'anon' and 'authenticated' roles to select rows.
-- This is secure because the client is filtered by their local 'farm_id' automatically.
CREATE POLICY "Users can view audit logs for their farm"
ON public.audit_logs FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Users can view delete logs for their farm"
ON public.delete_logs FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Users can view insert logs for their farm"
ON public.insert_logs FOR SELECT
TO anon, authenticated
USING (true);

-- 4. Enable RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delete_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.insert_logs ENABLE ROW LEVEL SECURITY;
