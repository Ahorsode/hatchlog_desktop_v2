-- Worker phone provisioning and mobile self-activation.

CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY,
  "farmId" TEXT NOT NULL,
  "authUserId" UUID UNIQUE,
  "phoneNumber" TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'WORKER',
  "firstName" TEXT,
  "lastName" TEXT,
  status TEXT NOT NULL DEFAULT 'PENDING',
  "customPermissionsJson" JSONB NOT NULL DEFAULT '[]'::jsonb,
  "permissionsCustomized" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT profiles_status_check CHECK (status IN ('PENDING', 'ACTIVE', 'INACTIVE')),
  CONSTRAINT profiles_role_check CHECK (role IN ('WORKER', 'MANAGER', 'ACCOUNTANT', 'OWNER')),
  CONSTRAINT profiles_farm_phone_unique UNIQUE ("farmId", "phoneNumber")
);

CREATE INDEX IF NOT EXISTS profiles_farm_status_idx
  ON public.profiles ("farmId", status);

CREATE INDEX IF NOT EXISTS profiles_phone_idx
  ON public.profiles ("phoneNumber");

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Provisioned workers can read their profile" ON public.profiles;
CREATE POLICY "Provisioned workers can read their profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  "authUserId" = auth.uid()
  OR "phoneNumber" = COALESCE(auth.jwt() ->> 'phone', '')
);

DROP POLICY IF EXISTS "Farm owners and managers can read profiles" ON public.profiles;
CREATE POLICY "Farm owners and managers can read profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u.email = auth.jwt() ->> 'email'
      AND (
        EXISTS (
          SELECT 1 FROM public.farms f
          WHERE f.id = profiles."farmId"
            AND f."userId" = u.id
        )
        OR EXISTS (
          SELECT 1 FROM public.farm_members fm
          WHERE fm."farmId" = profiles."farmId"
            AND fm."userId" = u.id
            AND fm.role IN ('OWNER', 'MANAGER')
        )
      )
  )
);

GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime'
  ) AND NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;
END
$$;

CREATE OR REPLACE FUNCTION public.complete_worker_activation(
  p_phone_number TEXT,
  p_first_name TEXT,
  p_last_name TEXT
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile public.profiles;
  v_auth_uid UUID := auth.uid();
  v_jwt_phone TEXT := auth.jwt() ->> 'phone';
  v_member_id TEXT;
  v_now TIMESTAMP := NOW();
  v_has_member_timestamps BOOLEAN;
BEGIN
  IF v_auth_uid IS NULL THEN
    RAISE EXCEPTION 'Authentication is required for worker activation.';
  END IF;

  IF NULLIF(BTRIM(p_first_name), '') IS NULL
      OR NULLIF(BTRIM(p_last_name), '') IS NULL THEN
    RAISE EXCEPTION 'First name and last name are required.';
  END IF;

  SELECT *
  INTO v_profile
  FROM public.profiles
  WHERE "authUserId" = v_auth_uid
     OR "phoneNumber" = p_phone_number
     OR (v_jwt_phone IS NOT NULL AND "phoneNumber" = v_jwt_phone)
  ORDER BY
    CASE WHEN "authUserId" = v_auth_uid THEN 0 ELSE 1 END,
    "createdAt" DESC
  LIMIT 1
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Provisioned profile was not found for this phone number.';
  END IF;

  IF v_profile."authUserId" IS NOT NULL
      AND v_profile."authUserId" <> v_auth_uid THEN
    RAISE EXCEPTION 'This profile belongs to a different authenticated user.';
  END IF;

  IF v_jwt_phone IS NOT NULL
      AND v_profile."phoneNumber" <> v_jwt_phone
      AND v_profile."phoneNumber" <> p_phone_number THEN
    RAISE EXCEPTION 'Authenticated phone does not match this profile.';
  END IF;

  UPDATE public.profiles
  SET
    "authUserId" = v_auth_uid,
    "firstName" = BTRIM(p_first_name),
    "lastName" = BTRIM(p_last_name),
    status = 'ACTIVE',
    "updatedAt" = v_now
  WHERE id = v_profile.id
  RETURNING * INTO v_profile;

  INSERT INTO public.users (
    id,
    firstname,
    surname,
    name,
    phone_number,
    role,
    created_at,
    updated_at,
    must_change_password
  )
  VALUES (
    v_auth_uid::TEXT,
    v_profile."firstName",
    v_profile."lastName",
    v_profile."firstName" || ' ' || v_profile."lastName",
    v_profile."phoneNumber",
    v_profile.role,
    v_now,
    v_now,
    FALSE
  )
  ON CONFLICT (id) DO UPDATE SET
    firstname = EXCLUDED.firstname,
    surname = EXCLUDED.surname,
    name = EXCLUDED.name,
    phone_number = EXCLUDED.phone_number,
    role = EXCLUDED.role,
    updated_at = EXCLUDED.updated_at,
    must_change_password = FALSE;

  v_member_id := 'member_' || v_profile.id;

  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'farm_members'
      AND column_name = 'createdAt'
  ) INTO v_has_member_timestamps;

  IF v_has_member_timestamps THEN
    EXECUTE '
      INSERT INTO public.farm_members ("id", "farmId", "userId", role, "createdAt", "updatedAt")
      VALUES ($1, $2, $3, $4, $5, $5)
      ON CONFLICT ("id") DO UPDATE SET
        "farmId" = EXCLUDED."farmId",
        "userId" = EXCLUDED."userId",
        role = EXCLUDED.role,
        "updatedAt" = EXCLUDED."updatedAt"
    '
    USING v_member_id, v_profile."farmId", v_auth_uid::TEXT, v_profile.role, v_now;
  ELSE
    EXECUTE '
      INSERT INTO public.farm_members ("id", "farmId", "userId", role)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT ("id") DO UPDATE SET
        "farmId" = EXCLUDED."farmId",
        "userId" = EXCLUDED."userId",
        role = EXCLUDED.role
    '
    USING v_member_id, v_profile."farmId", v_auth_uid::TEXT, v_profile.role;
  END IF;

  RETURN v_profile;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_worker_activation(TEXT, TEXT, TEXT)
TO authenticated;
