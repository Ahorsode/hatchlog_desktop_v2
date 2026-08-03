-- Mobile phone auth: resolve legacy Prisma user id for RLS (workers have no JWT email).

CREATE OR REPLACE FUNCTION public.get_legacy_user_id()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_legacy_user_id TEXT;
  v_jwt JSONB := auth.jwt();
  v_email TEXT;
  v_phone TEXT;
  v_phone_digits TEXT;
BEGIN
  v_legacy_user_id := NULLIF(BTRIM(v_jwt -> 'user_metadata' ->> 'legacy_user_id'), '');
  IF v_legacy_user_id IS NOT NULL THEN
    RETURN v_legacy_user_id;
  END IF;

  v_email := NULLIF(BTRIM(v_jwt ->> 'email'), '');
  IF v_email IS NOT NULL AND v_email NOT LIKE '%@hatchlog.internal' THEN
    SELECT id INTO v_legacy_user_id
    FROM public.users
    WHERE lower(email) = lower(v_email)
    LIMIT 1;
    IF v_legacy_user_id IS NOT NULL THEN
      RETURN v_legacy_user_id;
    END IF;
  END IF;

  v_phone := COALESCE(
    NULLIF(BTRIM(v_jwt ->> 'phone'), ''),
    NULLIF(BTRIM(v_jwt -> 'user_metadata' ->> 'phone_number'), '')
  );
  IF v_phone IS NOT NULL THEN
    v_phone_digits := regexp_replace(v_phone, '[^\d]', '', 'g');
    SELECT u.id INTO v_legacy_user_id
    FROM public.users u
    WHERE u.phone_number = v_phone
       OR u.phone_number = '+' || v_phone_digits
       OR u.phone_number = v_phone_digits
       OR (
         v_phone_digits LIKE '233%'
         AND u.phone_number = '0' || substring(v_phone_digits from 4)
       )
    ORDER BY u.updated_at DESC NULLS LAST
    LIMIT 1;
    IF v_legacy_user_id IS NOT NULL THEN
      RETURN v_legacy_user_id;
    END IF;
  END IF;

  IF v_email LIKE '%@hatchlog.internal' THEN
    v_phone_digits := split_part(v_email, '@', 1);
    SELECT u.id INTO v_legacy_user_id
    FROM public.users u
    WHERE u.phone_number = '+' || v_phone_digits
       OR u.phone_number = v_phone_digits
       OR (
         v_phone_digits LIKE '233%'
         AND u.phone_number = '0' || substring(v_phone_digits from 4)
       )
    ORDER BY u.updated_at DESC NULLS LAST
    LIMIT 1;
  END IF;

  RETURN v_legacy_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.current_app_user()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    NULLIF(BTRIM(current_setting('app.current_user_id', true)), ''),
    public.get_legacy_user_id()
  );
$$;

GRANT EXECUTE ON FUNCTION public.get_legacy_user_id() TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.current_app_user() TO authenticated, service_role;
