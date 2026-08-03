import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type ProvisionPayload = {
  profileId?: string;
  farmId?: string;
  phoneNumber?: string;
  role?: string;
  permissions?: string[];
  permissionsCustomized?: boolean;
  placeholderPassword?: string;
};

const allowedRoles = new Set(['WORKER', 'MANAGER', 'ACCOUNTANT']);

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function cleanRole(role?: string) {
  const normalized = (role ?? 'WORKER').trim().toUpperCase();
  return allowedRoles.has(normalized) ? normalized : 'WORKER';
}

function requiredString(value: unknown, label: string) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${label} is required.`);
  }
  return value.trim();
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse(405, { error: 'Method not allowed.' });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return jsonResponse(500, {
      error: 'Provisioning function is missing Supabase environment variables.',
    });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace(/^Bearer\s+/i, '').trim();
  if (!token) {
    return jsonResponse(401, { error: 'Owner authentication is required.' });
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { data: authData, error: authError } = await userClient.auth.getUser();
  if (authError || !authData.user) {
    return jsonResponse(401, { error: 'Invalid owner session.' });
  }

  let payload: ProvisionPayload;
  try {
    payload = await req.json();
  } catch (_error) {
    return jsonResponse(400, { error: 'Invalid JSON payload.' });
  }

  try {
    const farmId = requiredString(payload.farmId, 'farmId');
    const phoneNumber = requiredString(payload.phoneNumber, 'phoneNumber');
    const profileId = requiredString(payload.profileId, 'profileId');
    const role = cleanRole(payload.role);
    const permissions = Array.isArray(payload.permissions)
      ? [...new Set(payload.permissions.map((it) => String(it).trim()).filter(Boolean))].sort()
      : [];

    const ownerEmail = authData.user.email;
    const ownerPhone = authData.user.phone;

    const ownerQuery = adminClient
      .from('users')
      .select('id,email,phone_number,role')
      .limit(1);

    const ownerLookup = ownerEmail
      ? ownerQuery.eq('email', ownerEmail)
      : ownerQuery.eq('phone_number', ownerPhone ?? '');

    const { data: ownerRows, error: ownerError } = await ownerLookup;
    if (ownerError) throw ownerError;

    const appOwner = ownerRows?.[0];
    if (!appOwner?.id) {
      return jsonResponse(403, {
        error: 'Authenticated owner is not linked to a HatchLog user record.',
      });
    }

    const [{ data: ownedFarm }, { data: managedMembership }] = await Promise.all([
      adminClient
        .from('farms')
        .select('id')
        .eq('id', farmId)
        .eq('userId', appOwner.id)
        .maybeSingle(),
      adminClient
        .from('farm_members')
        .select('id,role')
        .eq('farmId', farmId)
        .eq('userId', appOwner.id)
        .in('role', ['OWNER', 'MANAGER'])
        .maybeSingle(),
    ]);

    if (!ownedFarm && !managedMembership) {
      return jsonResponse(403, {
        error: 'Only farm owners and managers can provision team members.',
      });
    }

    const password = payload.placeholderPassword === '123456'
      ? payload.placeholderPassword
      : '123456';

    const { data: createdUser, error: createUserError } =
      await adminClient.auth.admin.createUser({
        phone: phoneNumber,
        password,
        phone_confirm: true,
        user_metadata: {
          farm_id: farmId,
          profile_id: profileId,
          role,
          onboarding_status: 'pending',
        },
      });

    if (createUserError) {
      return jsonResponse(409, {
        error: createUserError.message,
      });
    }

    const authUserId = createdUser.user?.id;
    if (!authUserId) {
      return jsonResponse(500, {
        error: 'Supabase Auth did not return a created user id.',
      });
    }

    const profilePayload = {
      id: profileId,
      farmId,
      authUserId,
      phoneNumber,
      role,
      status: 'PENDING',
      customPermissionsJson: permissions,
      permissionsCustomized: payload.permissionsCustomized === true,
      updatedAt: new Date().toISOString(),
    };

    const { data: profile, error: profileError } = await adminClient
      .from('profiles')
      .upsert(profilePayload, { onConflict: 'id' })
      .select()
      .single();

    if (profileError) throw profileError;

    return jsonResponse(200, { profile });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonResponse(400, { error: message });
  }
});
