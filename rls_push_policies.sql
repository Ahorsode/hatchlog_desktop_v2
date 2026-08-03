-- rls_push_policies.sql
-- This script adds the missing RLS policies to allow the desktop app 
-- to INSERT and UPDATE records directly to the cloud database.
-- Run this script in your Supabase SQL Editor.

-- IMPORTANT: Restore Postgres-level grants (Prisma migrations can wipe these)
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Helper function (kept for RPC diagnostics, but policies no longer depend on it)
CREATE OR REPLACE FUNCTION get_legacy_user_id()
RETURNS TEXT AS $$
DECLARE
    v_legacy_user_id TEXT;
BEGIN
    SELECT id INTO v_legacy_user_id 
    FROM public.users 
    WHERE email = (auth.jwt() ->> 'email') 
    LIMIT 1;
    RETURN v_legacy_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
GRANT EXECUTE ON FUNCTION get_legacy_user_id() TO authenticated;

-- Inline helper expression (used directly in every policy below)
-- (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)

-- =============================================================
-- 1. Policies for houses
-- =============================================================
ALTER TABLE houses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON houses;
CREATE POLICY "Enable insert for authenticated users" ON houses
    FOR INSERT TO authenticated
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
    );

DROP POLICY IF EXISTS "Enable update for authenticated users" ON houses;
CREATE POLICY "Enable update for authenticated users" ON houses
    FOR UPDATE TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = houses."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    )
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = houses."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

DROP POLICY IF EXISTS "Enable select for authenticated users" ON houses;
CREATE POLICY "Enable select for authenticated users" ON houses
    FOR SELECT TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = houses."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

-- =============================================================
-- 2. Policies for batches
-- =============================================================
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON batches;
CREATE POLICY "Enable insert for authenticated users" ON batches
    FOR INSERT TO authenticated
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
    );

DROP POLICY IF EXISTS "Enable update for authenticated users" ON batches;
CREATE POLICY "Enable update for authenticated users" ON batches
    FOR UPDATE TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = batches."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    )
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = batches."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

DROP POLICY IF EXISTS "Enable select for authenticated users" ON batches;
CREATE POLICY "Enable select for authenticated users" ON batches
    FOR SELECT TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = batches."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

-- =============================================================
-- 3. Policies for mortality
-- =============================================================
ALTER TABLE mortality ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON mortality;
CREATE POLICY "Enable insert for authenticated users" ON mortality
    FOR INSERT TO authenticated
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
    );

DROP POLICY IF EXISTS "Enable update for authenticated users" ON mortality;
CREATE POLICY "Enable update for authenticated users" ON mortality
    FOR UPDATE TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = mortality."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    )
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = mortality."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

DROP POLICY IF EXISTS "Enable select for authenticated users" ON mortality;
CREATE POLICY "Enable select for authenticated users" ON mortality
    FOR SELECT TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = mortality."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

-- =============================================================
-- 4. Policies for egg_production
-- =============================================================
ALTER TABLE egg_production ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON egg_production;
CREATE POLICY "Enable insert for authenticated users" ON egg_production
    FOR INSERT TO authenticated
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
    );

DROP POLICY IF EXISTS "Enable update for authenticated users" ON egg_production;
CREATE POLICY "Enable update for authenticated users" ON egg_production
    FOR UPDATE TO authenticated
    USING (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = egg_production."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    )
    WITH CHECK (
        "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = egg_production."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );

-- =============================================================
-- 5. Policies for daily_feeding_logs
-- =============================================================
ALTER TABLE daily_feeding_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON daily_feeding_logs;
CREATE POLICY "Enable insert for authenticated users" ON daily_feeding_logs
    FOR INSERT TO authenticated
    WITH CHECK (
        user_id = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
    );

DROP POLICY IF EXISTS "Enable update for authenticated users" ON daily_feeding_logs;
CREATE POLICY "Enable update for authenticated users" ON daily_feeding_logs
    FOR UPDATE TO authenticated
    USING (
        user_id = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = daily_feeding_logs."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    )
    WITH CHECK (
        user_id = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        OR EXISTS (
            SELECT 1 FROM farm_members
            WHERE "farmId" = daily_feeding_logs."farmId"
            AND "userId" = (SELECT id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1)
        )
    );
