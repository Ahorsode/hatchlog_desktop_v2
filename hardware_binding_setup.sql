-- 1. Create Device Registrations table for Hardware Binding
CREATE TABLE IF NOT EXISTS public.device_registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "farmId" INTEGER NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
    "userId" TEXT NOT NULL,
    "deviceIdentifier" TEXT NOT NULL,
    "deviceName" TEXT,
    "registeredAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE("farmId", "deviceIdentifier")
);

-- 2. Enable RLS
ALTER TABLE device_registrations ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policy: Users can only see/register their own devices (using Email bridge)
DROP POLICY IF EXISTS "Users can manage their own devices" ON device_registrations;
CREATE POLICY "Users can manage their own devices" ON device_registrations
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.email = (auth.jwt() ->> 'email')
            AND users.id = device_registrations."userId"
        )
    );

-- 4. RPC function to verify farm ownership/membership using Email as a bridge
CREATE OR REPLACE FUNCTION verify_farm_binding(p_farm_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_email TEXT;
    v_legacy_user_id TEXT;
BEGIN
    -- 1. Get the verified email from the current Supabase Auth JWT
    v_email := auth.jwt() ->> 'email';
    
    IF v_email IS NULL THEN
        RETURN FALSE;
    END IF;

    -- 2. Look up the legacy text ID associated with this email
    SELECT id INTO v_legacy_user_id 
    FROM users 
    WHERE email = v_email 
    LIMIT 1;

    IF v_legacy_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- 3. Check if that legacy ID is the owner or a member of the farm
    RETURN EXISTS (
        SELECT 1 FROM farms 
        WHERE id = p_farm_id 
        AND "userId" = v_legacy_user_id
    ) OR EXISTS (
        SELECT 1 FROM farm_members
        WHERE "farmId" = p_farm_id
        AND "userId" = v_legacy_user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure the authenticated role can execute this
GRANT EXECUTE ON FUNCTION verify_farm_binding(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION verify_farm_binding(INTEGER) TO service_role;

-- 5. Helper function to register a hardware device (using Email bridge)
CREATE OR REPLACE FUNCTION register_hardware_device(p_farm_id INTEGER, p_device_id TEXT, p_device_name TEXT)
RETURNS VOID AS $$
DECLARE
    v_email TEXT;
    v_legacy_user_id TEXT;
BEGIN
    v_email := auth.jwt() ->> 'email';
    
    SELECT id INTO v_legacy_user_id 
    FROM users 
    WHERE email = v_email 
    LIMIT 1;

    IF v_legacy_user_id IS NOT NULL THEN
        INSERT INTO device_registrations ("farmId", "userId", "deviceIdentifier", "deviceName", "registeredAt")
        VALUES (p_farm_id, v_legacy_user_id, p_device_id, p_device_name, NOW())
        ON CONFLICT ("farmId", "deviceIdentifier") 
        DO UPDATE SET "registeredAt" = NOW(), "deviceName" = p_device_name;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION register_hardware_device(INTEGER, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION register_hardware_device(INTEGER, TEXT, TEXT) TO service_role;

-- 6. RPC function to fetch all farm data using Email bridge
CREATE OR REPLACE FUNCTION get_farm_sync_data(p_farm_id INTEGER)
RETURNS JSONB AS $$
DECLARE
    v_email TEXT;
    v_legacy_user_id TEXT;
    v_is_authorized BOOLEAN;
    result JSONB;
BEGIN
    -- 1. Get verified email
    v_email := auth.jwt() ->> 'email';
    
    IF v_email IS NULL THEN
        RETURN NULL;
    END IF;

    -- 2. Lookup legacy ID
    SELECT id INTO v_legacy_user_id 
    FROM users 
    WHERE email = v_email 
    LIMIT 1;

    IF v_legacy_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- 3. Security check: Is this legacy user the owner or a member?
    SELECT (
        EXISTS (SELECT 1 FROM farms WHERE id = p_farm_id AND "userId" = v_legacy_user_id)
        OR EXISTS (SELECT 1 FROM farm_members WHERE "farmId" = p_farm_id AND "userId" = v_legacy_user_id)
    ) INTO v_is_authorized;

    IF NOT v_is_authorized THEN
        RETURN NULL;
    END IF;

    -- 4. Build and return the consolidated JSON
    SELECT jsonb_build_object(
        'farm', (SELECT row_to_json(f) FROM farms f WHERE id = p_farm_id),
        'farm_settings', (SELECT row_to_json(fs) FROM farm_settings fs WHERE "farmId" = p_farm_id LIMIT 1),
        'users', COALESCE((
            SELECT jsonb_agg(u) FROM users u 
            WHERE id IN (SELECT "userId" FROM farm_members WHERE "farmId" = p_farm_id)
            OR id = v_legacy_user_id
        ), '[]'::jsonb),
        'houses', COALESCE((SELECT jsonb_agg(h) FROM houses h WHERE "farmId" = p_farm_id), '[]'::jsonb),
        'inventory', COALESCE((SELECT jsonb_agg(i) FROM inventory i WHERE "farmId" = p_farm_id), '[]'::jsonb),
        'batches', COALESCE((SELECT jsonb_agg(b) FROM batches b WHERE "farmId" = p_farm_id), '[]'::jsonb),
        'customers', COALESCE((SELECT jsonb_agg(c) FROM customers c WHERE "farmId" = p_farm_id), '[]'::jsonb)
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_farm_sync_data(INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION get_farm_sync_data(INTEGER) TO service_role;
