-- Accept pending team invitations on mobile login (mirrors web acceptInvitation).

CREATE OR REPLACE FUNCTION public.accept_pending_invitation(
  p_user_id TEXT,
  p_phone_number TEXT DEFAULT NULL,
  p_email TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_invitation public.invitations%ROWTYPE;
  v_member_id TEXT;
  v_perm_id TEXT;
  v_role TEXT;
  v_phone TEXT := NULLIF(BTRIM(p_phone_number), '');
  v_email TEXT := NULLIF(BTRIM(p_email), '');
  v_digits TEXT;
BEGIN
  IF NULLIF(BTRIM(p_user_id), '') IS NULL THEN
    RETURN NULL;
  END IF;

  IF v_phone IS NOT NULL THEN
    v_digits := regexp_replace(v_phone, '[^\d]', '', 'g');
  END IF;

  SELECT *
  INTO v_invitation
  FROM public.invitations i
  WHERE upper(i.status) = 'PENDING'
    AND (
      (v_email IS NOT NULL AND lower(i.email) = lower(v_email))
      OR (v_phone IS NOT NULL AND i.phone_number = v_phone)
      OR (v_digits IS NOT NULL AND i.phone_number = v_digits)
      OR (v_digits IS NOT NULL AND i.phone_number = '+' || v_digits)
      OR (
        v_digits IS NOT NULL
        AND v_digits LIKE '233%'
        AND i.phone_number = '0' || substring(v_digits from 4)
      )
    )
  ORDER BY i.updated_at DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  v_role := upper(COALESCE(v_invitation.role::text, 'WORKER'));
  v_member_id := 'member_' || regexp_replace(
    v_invitation.farm_id || '_' || p_user_id,
    '[^a-zA-Z0-9]',
    '',
    'g'
  );
  v_perm_id := 'perm_' || regexp_replace(
    v_invitation.farm_id || '_' || p_user_id,
    '[^a-zA-Z0-9]',
    '',
    'g'
  );

  IF NOT EXISTS (
    SELECT 1
    FROM public.farm_members fm
    WHERE fm."farmId" = v_invitation.farm_id
      AND fm."userId" = p_user_id
  ) THEN
    INSERT INTO public.farm_members (
      id,
      "farmId",
      "userId",
      role,
      "createdAt",
      "updatedAt"
    )
    VALUES (
      v_member_id,
      v_invitation.farm_id,
      p_user_id,
      v_role::"Role",
      NOW(),
      NOW()
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.user_permissions up
    WHERE up.farm_id = v_invitation.farm_id
      AND up.user_id = p_user_id
  ) THEN
    INSERT INTO public.user_permissions (
      id,
      user_id,
      farm_id,
      can_view_finance,
      can_edit_finance,
      can_view_inventory,
      can_edit_inventory,
      can_view_batches,
      can_edit_batches,
      can_view_sales,
      can_edit_sales,
      can_view_eggs,
      can_edit_eggs,
      can_view_feeding,
      can_edit_feeding,
      can_view_houses,
      can_edit_houses,
      can_view_mortality,
      can_edit_mortality,
      can_view_customers,
      can_edit_customers,
      can_view_team,
      can_edit_team,
      can_view_health,
      can_edit_health
    ) VALUES (
      v_perm_id,
      p_user_id,
      v_invitation.farm_id,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      true,
      true,
      true,
      true,
      false,
      false,
      true,
      true,
      false,
      false,
      false,
      false,
      true,
      true
    );
  END IF;

  UPDATE public.users
  SET
    role = v_role::"Role",
    updated_at = NOW()
  WHERE id = p_user_id;

  UPDATE public.invitations
  SET
    status = 'ACCEPTED',
    updated_at = NOW()
  WHERE id = v_invitation.id;

  RETURN jsonb_build_object(
    'farm_id', v_invitation.farm_id,
    'role', v_role,
    'invitation_id', v_invitation.id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_pending_invitation(TEXT, TEXT, TEXT)
TO authenticated, service_role;
