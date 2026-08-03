-- Desktop multi-route registration onboarding.
-- Mirrors Auth sign-ups into public owner/farm/profile tables without relying
-- on a client-side session immediately after email confirmation sign-up.

CREATE SCHEMA IF NOT EXISTS private;

CREATE OR REPLACE FUNCTION private.handle_desktop_registration_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_route TEXT := NEW.raw_user_meta_data ->> 'registration_route';
  v_farm_id TEXT := NULLIF(BTRIM(NEW.raw_user_meta_data ->> 'farm_id'), '');
  v_farm_name TEXT := COALESCE(
    NULLIF(BTRIM(NEW.raw_user_meta_data ->> 'farm_name'), ''),
    'HatchLog Farm'
  );
  v_owner_phone TEXT := NULLIF(
    BTRIM(NEW.raw_user_meta_data ->> 'owner_phone_number'),
    ''
  );
  v_now TIMESTAMP := NOW();
BEGIN
  IF v_route IS DISTINCT FROM 'traditional_desktop' THEN
    RETURN NEW;
  END IF;

  IF v_farm_id IS NULL THEN
    v_farm_id := 'farm_' || REPLACE(NEW.id::TEXT, '-', '');
  END IF;

  INSERT INTO public.users (
    id,
    email,
    phone_number,
    name,
    role,
    created_at,
    updated_at,
    must_change_password
  )
  VALUES (
    NEW.id::TEXT,
    LOWER(NEW.email),
    v_owner_phone,
    LOWER(NEW.email),
    'OWNER',
    v_now,
    v_now,
    FALSE
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    name = EXCLUDED.name,
    role = EXCLUDED.role,
    updated_at = EXCLUDED.updated_at,
    must_change_password = FALSE;

  INSERT INTO public.farms (
    id,
    name,
    capacity,
    "userId",
    "subscriptionTier",
    "createdAt",
    "updatedAt"
  )
  VALUES (
    v_farm_id,
    v_farm_name,
    0,
    NEW.id::TEXT,
    'FREE',
    v_now,
    v_now
  )
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    "userId" = EXCLUDED."userId",
    "updatedAt" = EXCLUDED."updatedAt";

  INSERT INTO public.farm_members (
    id,
    "farmId",
    "userId",
    role,
    "createdAt",
    "updatedAt"
  )
  VALUES (
    'member_' || v_farm_id || '_' || NEW.id::TEXT,
    v_farm_id,
    NEW.id::TEXT,
    'OWNER',
    v_now,
    v_now
  )
  ON CONFLICT (id) DO UPDATE SET
    "farmId" = EXCLUDED."farmId",
    "userId" = EXCLUDED."userId",
    role = EXCLUDED.role,
    "updatedAt" = EXCLUDED."updatedAt";

  IF v_owner_phone IS NOT NULL THEN
    INSERT INTO public.profiles (
      id,
      "farmId",
      "authUserId",
      "phoneNumber",
      role,
      status,
      "createdAt",
      "updatedAt"
    )
    VALUES (
      'owner_' || NEW.id::TEXT,
      v_farm_id,
      NEW.id,
      v_owner_phone,
      'OWNER',
      'ACTIVE',
      v_now,
      v_now
    )
    ON CONFLICT (id) DO UPDATE SET
      "farmId" = EXCLUDED."farmId",
      "authUserId" = EXCLUDED."authUserId",
      "phoneNumber" = EXCLUDED."phoneNumber",
      role = EXCLUDED.role,
      status = EXCLUDED.status,
      "updatedAt" = EXCLUDED."updatedAt";
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_desktop_registration_auth_user_created
ON auth.users;

CREATE TRIGGER on_desktop_registration_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION private.handle_desktop_registration_user();
