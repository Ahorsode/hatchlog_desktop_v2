-- SQL Script to fix "PostgrestException: Could not find the function public.verify_farm_binding"
-- Run this script in your Supabase SQL Editor: https://supabase.com/dashboard/project/_/sql

-- 1. Function to verify if a Farm ID belongs to an Owner ID
-- This bypasses RLS to allow the desktop app to verify credentials using the anon key.
CREATE OR REPLACE FUNCTION verify_farm_binding(p_farm_id INTEGER, p_owner_id TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM farms
    WHERE id = p_farm_id AND "userId" = p_owner_id
  );
END;
$$;

-- 2. Function to fetch all farm data for initial synchronization
-- Returns a consolidated JSON object of all farm records.
CREATE OR REPLACE FUNCTION get_farm_sync_data(p_farm_id INTEGER, p_owner_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSONB;
BEGIN
  -- Security check: Verify ownership before returning sensitive data
  IF NOT EXISTS (SELECT 1 FROM farms WHERE id = p_farm_id AND "userId" = p_owner_id) THEN
    RETURN NULL;
  END IF;

  SELECT jsonb_build_object(
    'farm', (SELECT row_to_json(f) FROM farms f WHERE id = p_farm_id),
    'farm_settings', (SELECT row_to_json(fs) FROM farm_settings fs WHERE "farmId" = p_farm_id LIMIT 1),
    'users', COALESCE((
        SELECT jsonb_agg(u) FROM users u 
        WHERE id IN (SELECT "userId" FROM farm_members WHERE "farmId" = p_farm_id)
        OR id = p_owner_id
    ), '[]'::jsonb),
    'houses', COALESCE((SELECT jsonb_agg(h) FROM houses h WHERE "farmId" = p_farm_id), '[]'::jsonb),
    'inventory', COALESCE((SELECT jsonb_agg(i) FROM inventory i WHERE "farmId" = p_farm_id), '[]'::jsonb),
    'batches', COALESCE((SELECT jsonb_agg(b) FROM batches b WHERE "farmId" = p_farm_id), '[]'::jsonb),
    'customers', COALESCE((SELECT jsonb_agg(c) FROM customers c WHERE "farmId" = p_farm_id), '[]'::jsonb)
  ) INTO result;

  RETURN result;
END;
$$;

-- 3. Grant permissions to allow the app to call these functions
-- This fixes the "permission denied for schema public" error.
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;
