-- ==========================================
-- Poultry Management Audit System Alignment
-- Matches Prisma Web Schema: insert_logs, delete_logs, audit_logs
-- ==========================================

-- 1. Helper function to generate CSV for delete_logs
CREATE OR REPLACE FUNCTION public.jsonb_to_csv_row(p_data JSONB) 
RETURNS TEXT AS $$
DECLARE
    v_headers TEXT := '';
    v_values TEXT := '';
    v_key TEXT;
    v_val TEXT;
BEGIN
    FOR v_key IN SELECT jsonb_object_keys(p_data) LOOP
        v_headers := v_headers || v_key || '|';
        v_val := p_data->>v_key;
        v_values := v_values || COALESCE(v_val, 'NULL') || '|';
    END LOOP;
    -- Remove trailing pipes and combine
    RETURN rtrim(v_headers, '|') || chr(10) || rtrim(v_values, '|');
END;
$$ LANGUAGE plpgsql;

-- 2. Refined Audit Trigger Function
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
    -- Resolve user ID
    v_user_id := auth.uid()::text;
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM public.users WHERE email = (auth.jwt() ->> 'email') LIMIT 1;
    END IF;

    -- Resolve farm_id (robust lookup)
    IF (TG_OP = 'DELETE') THEN
        v_farm_id := COALESCE(OLD.farm_id, OLD."farmId");
    ELSE
        v_farm_id := COALESCE(NEW.farm_id, NEW."farmId");
    END IF;

    -- CASE 1: INSERT -> insert_logs
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO public.insert_logs (user_id, farm_id, target_table, record_id, inserted_at)
        VALUES (v_user_id, v_farm_id, TG_TABLE_NAME, NEW.id, CURRENT_TIMESTAMP);
        RETURN NEW;

    -- CASE 2: DELETE -> delete_logs
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO public.delete_logs (user_id, farm_id, table_name, deleted_data_csv, deleted_at)
        VALUES (v_user_id, v_farm_id, TG_TABLE_NAME, public.jsonb_to_csv_row(row_to_json(OLD)::JSONB), CURRENT_TIMESTAMP);
        RETURN OLD;

    -- CASE 3: UPDATE -> audit_logs (Field-by-Field)
    ELSIF (TG_OP = 'UPDATE') THEN
        v_old_json := row_to_json(OLD)::JSONB;
        v_new_json := row_to_json(NEW)::JSONB;

        FOR v_key IN SELECT jsonb_object_keys(v_new_json) LOOP
            v_old_val := v_old_json->>v_key;
            v_new_val := v_new_json->>v_key;

            -- Only log if value actually changed and it's not a metadata field
            IF v_old_val IS DISTINCT FROM v_new_val AND v_key NOT IN ('updated_at', 'updatedAt', 'synced') THEN
                INSERT INTO public.audit_logs (table_name, record_id, attribute_name, old_value, new_value, user_id, farm_id, created_at)
                VALUES (TG_TABLE_NAME, OLD.id, v_key, v_old_val, v_new_val, v_user_id, v_farm_id, CURRENT_TIMESTAMP);
            END IF;
        END LOOP;
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Re-apply triggers to all tables
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN SELECT table_name FROM information_schema.tables 
             WHERE table_schema = 'public' 
             AND table_name IN ('batches', 'houses', 'mortality', 'egg_production', 'daily_feeding_logs', 'sales', 'inventory', 'customers')
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS tr_audit_%I ON public.%I', t, t);
        EXECUTE format('CREATE TRIGGER tr_audit_%I AFTER INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.process_audit_log()', t, t);
    END LOOP;
END;
$$;
