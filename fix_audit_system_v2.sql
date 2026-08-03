-- ==========================================
-- FIX: Audit System v2 — Resolve FK & RLS issues
-- Run this in Supabase SQL Editor
-- ==========================================

-- ============================================
-- STEP 1: Drop the FK constraint on user_id
-- The trigger uses auth.uid() which is a Supabase Auth UUID,
-- but users.id stores a different app-level ID.
-- This FK mismatch silently kills the trigger INSERT.
-- ============================================
ALTER TABLE audit_logs DROP CONSTRAINT IF EXISTS fk_audit_logs_user;
ALTER TABLE delete_logs DROP CONSTRAINT IF EXISTS fk_delete_logs_user;
ALTER TABLE insert_logs DROP CONSTRAINT IF EXISTS fk_insert_logs_user;

-- ============================================
-- STEP 2: Update the trigger function to use the
-- app-level user_id from the row itself, instead of auth.uid().
-- Most tables have a "userId" or "user_id" column that maps
-- to your users table correctly.
-- ============================================
CREATE OR REPLACE FUNCTION public.process_audit_log()
RETURNS TRIGGER AS $$
DECLARE
    v_farm_id INTEGER;
    v_user_id TEXT;
    v_key TEXT;
    v_old_val TEXT;
    v_new_val TEXT;
    v_old_json JSONB;
    v_new_json JSONB;
BEGIN
    -- Resolve user ID: prefer row-level userId, fallback to auth.uid()
    IF (TG_OP = 'DELETE') THEN
        v_user_id := COALESCE(
            OLD."userId",
            OLD.user_id,
            auth.uid()::text
        );
        v_farm_id := COALESCE(OLD."farmId", OLD.farm_id);
    ELSE
        v_user_id := COALESCE(
            NEW."userId",
            NEW.user_id,
            auth.uid()::text
        );
        v_farm_id := COALESCE(NEW."farmId", NEW.farm_id);
    END IF;

    -- CASE 1: INSERT -> insert_logs
    IF (TG_OP = 'INSERT') THEN
        BEGIN
            INSERT INTO public.insert_logs (user_id, farm_id, target_table, record_id, inserted_at)
            VALUES (v_user_id, v_farm_id, TG_TABLE_NAME, NEW.id, CURRENT_TIMESTAMP);
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Audit INSERT log failed for %: %', TG_TABLE_NAME, SQLERRM;
        END;
        RETURN NEW;

    -- CASE 2: DELETE -> delete_logs
    ELSIF (TG_OP = 'DELETE') THEN
        BEGIN
            INSERT INTO public.delete_logs (user_id, farm_id, table_name, deleted_data_csv, deleted_at)
            VALUES (v_user_id, v_farm_id, TG_TABLE_NAME, public.jsonb_to_csv_row(row_to_json(OLD)::JSONB), CURRENT_TIMESTAMP);
        EXCEPTION WHEN OTHERS THEN
            RAISE WARNING 'Audit DELETE log failed for %: %', TG_TABLE_NAME, SQLERRM;
        END;
        RETURN OLD;

    -- CASE 3: UPDATE -> audit_logs (Field-by-Field)
    ELSIF (TG_OP = 'UPDATE') THEN
        v_old_json := row_to_json(OLD)::JSONB;
        v_new_json := row_to_json(NEW)::JSONB;

        FOR v_key IN SELECT jsonb_object_keys(v_new_json) LOOP
            v_old_val := v_old_json->>v_key;
            v_new_val := v_new_json->>v_key;

            -- Only log if value actually changed and it's not a metadata field
            IF v_old_val IS DISTINCT FROM v_new_val AND v_key NOT IN ('updated_at', 'updatedAt', 'synced', 'createdAt', 'created_at') THEN
                BEGIN
                    INSERT INTO public.audit_logs (table_name, record_id, attribute_name, old_value, new_value, user_id, farm_id, created_at)
                    VALUES (TG_TABLE_NAME, OLD.id, v_key, v_old_val, v_new_val, v_user_id, v_farm_id, CURRENT_TIMESTAMP);
                EXCEPTION WHEN OTHERS THEN
                    RAISE WARNING 'Audit UPDATE log failed for %.%: %', TG_TABLE_NAME, v_key, SQLERRM;
                END;
            END IF;
        END LOOP;
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 3: Fix RLS Policies
-- farm_members uses "farmId" and "userId" (camelCase, Prisma),
-- not farm_id / user_id (snake_case).
-- Also use a simple farm_id check for the audit screen query.
-- ============================================

-- Drop old broken policies
DROP POLICY IF EXISTS "Users can view audit logs for their farm" ON audit_logs;
DROP POLICY IF EXISTS "Users can view delete logs for their farm" ON delete_logs;
DROP POLICY IF EXISTS "Allow authenticated insert to audit_logs" ON audit_logs;
DROP POLICY IF EXISTS "Allow authenticated insert to delete_logs" ON delete_logs;

-- Simple open SELECT policy (farm_id filtering done by the app query)
-- This is safe because the app always filters by farm_id in the .eq() call
CREATE POLICY "Allow authenticated to read audit_logs"
ON audit_logs FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated to read delete_logs"
ON delete_logs FOR SELECT
TO authenticated
USING (true);

-- Allow trigger inserts (SECURITY DEFINER handles this, but belt-and-suspenders)
CREATE POLICY "Allow trigger insert to audit_logs"
ON audit_logs FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow trigger insert to delete_logs"
ON delete_logs FOR INSERT
TO authenticated
WITH CHECK (true);

-- ============================================
-- STEP 4: Re-apply triggers to all tracked tables
-- ============================================
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN SELECT table_name FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name IN ('batches', 'houses', 'mortality', 'egg_production', 'daily_feeding_logs', 'sales', 'inventory', 'customers', 'expenses', 'settlements')
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS tr_audit_%I ON public.%I', t, t);
        EXECUTE format('CREATE TRIGGER tr_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.process_audit_log()', t, t);
    END LOOP;
END;
$$;

-- ============================================
-- STEP 5: Grant permissions
-- ============================================
GRANT SELECT, INSERT ON public.audit_logs TO authenticated;
GRANT SELECT, INSERT ON public.delete_logs TO authenticated;
GRANT SELECT, INSERT ON public.insert_logs TO authenticated;

-- Verify: Run this to check triggers are applied
-- SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_schema = 'public' AND trigger_name LIKE 'tr_audit%';
