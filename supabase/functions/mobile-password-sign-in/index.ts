import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import bcrypt from 'https://esm.sh/bcryptjs@2.4.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type SignInPayload = {
  phoneNumber?: string;
  identifier?: string;
  password?: string;
};

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function extractErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  if (typeof error === 'object' && error !== null) {
    const record = error as Record<string, unknown>;
    if (typeof record.message === 'string' && record.message.trim()) {
      return record.message;
    }
    return JSON.stringify(error);
  }
  return String(error);
}

function phoneCandidates(raw: string): string[] {
  const candidates: string[] = [];
  const add = (value: string) => {
    const candidate = value.trim();
    if (candidate && !candidates.includes(candidate)) {
      candidates.push(candidate);
    }
  };

  const trimmed = raw.trim();
  add(trimmed);

  const digits = trimmed.replace(/[^\d]/g, '');
  add(digits);
  if (digits) {
    add(`+${digits}`);
  }
  if (digits.startsWith('0') && digits.length > 1) {
    const international = `233${digits.substring(1)}`;
    add(international);
    add(`+${international}`);
  }
  if (digits.startsWith('233') && digits.length > 3) {
    add(`0${digits.substring(3)}`);
  }
  return candidates;
}

function internalEmailForPhone(identifier: string): string {
  const digits = identifier.trim().replace(/[^\d]/g, '');
  if (!digits) {
    return '';
  }
  return `${digits}@hatchlog.internal`;
}

async function findAuthUserIdByPhone(
  adminClient: ReturnType<typeof createClient>,
  phone: string,
): Promise<string | null> {
  const normalized = phone.trim();
  for (let page = 1; page <= 10; page++) {
    const { data, error } = await adminClient.auth.admin.listUsers({
      page,
      perPage: 200,
    });
    if (error) {
      throw new Error(extractErrorMessage(error));
    }
    const users = data?.users ?? [];
    const match = users.find((user) => {
      const userPhone = user.phone?.trim() ?? '';
      return userPhone === normalized ||
        userPhone.replace(/[^\d]/g, '') === normalized.replace(/[^\d]/g, '');
    });
    if (match?.id) {
      return match.id;
    }
    if (users.length < 200) {
      break;
    }
  }
  return null;
}

async function signInWithPhoneCandidates(
  client: ReturnType<typeof createClient>,
  identifier: string,
  password: string,
) {
  for (const phone of phoneCandidates(identifier)) {
    const { data, error } = await client.auth.signInWithPassword({
      phone,
      password,
    });
    if (!error && data.session) {
      return data;
    }
  }

  const authEmail = internalEmailForPhone(identifier);
  if (authEmail) {
    const { data, error } = await client.auth.signInWithPassword({
      email: authEmail,
      password,
    });
    if (!error && data.session) {
      return data;
    }
  }

  return null;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse(405, { error: 'Method not allowed.' });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(500, {
      error: 'Mobile sign-in function is missing Supabase environment variables.',
    });
  }

  let payload: SignInPayload;
  try {
    payload = await req.json();
  } catch (_error) {
    return jsonResponse(400, { error: 'Invalid JSON payload.' });
  }

  const password = payload.password?.trim() ?? '';
  const identifier = (payload.identifier ?? payload.phoneNumber ?? '').trim();
  if (!identifier || !password) {
    return jsonResponse(400, { error: 'Phone number and password are required.' });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const anonClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    let profile: Record<string, unknown> | null = null;
    let resolvedPhone = '';
    for (const candidate of phoneCandidates(identifier)) {
      const { data, error } = await adminClient
        .from('users')
        .select('id, email, phone_number, password, must_change_password, firstname, surname, role')
        .eq('phone_number', candidate)
        .maybeSingle();
      if (error) {
        throw error;
      }
      if (data) {
        profile = data as Record<string, unknown>;
        resolvedPhone = String(data.phone_number ?? candidate);
        break;
      }
    }

    if (!profile?.password) {
      return jsonResponse(401, {
        error: 'Invalid phone number or master password combination.',
      });
    }

    const storedHash = String(profile.password);
    const passwordValid = bcrypt.compareSync(password, storedHash);
    if (!passwordValid) {
      return jsonResponse(401, {
        error: 'Invalid phone number or master password combination.',
      });
    }

    const legacyUserId = String(profile.id ?? '');
    const metadata = {
      legacy_user_id: legacyUserId,
      phone_number: profile.phone_number ?? resolvedPhone ?? identifier,
      role: profile.role ?? 'OWNER',
    };
    const authPhone = resolvedPhone.startsWith('+')
      ? resolvedPhone
      : phoneCandidates(identifier).find((value) => value.startsWith('+')) ??
        `+${identifier.replace(/[^\d]/g, '')}`;

    const existingSignIn = await signInWithPhoneCandidates(
      anonClient,
      authPhone,
      password,
    );
    if (existingSignIn?.session) {
      return jsonResponse(200, {
        access_token: existingSignIn.session.access_token,
        refresh_token: existingSignIn.session.refresh_token,
        expires_in: existingSignIn.session.expires_in,
        token_type: existingSignIn.session.token_type,
        user: existingSignIn.user,
        legacy_user_id: legacyUserId,
        must_change_password: profile.must_change_password === true,
      });
    }

    const { error: createError } = await adminClient.auth.admin.createUser({
      phone: authPhone,
      password,
      phone_confirm: true,
      user_metadata: metadata,
    });

    if (createError) {
      const createMessage = extractErrorMessage(createError).toLowerCase();
      const alreadyExists = createMessage.includes('already') ||
        createMessage.includes('registered') ||
        createMessage.includes('exists');
      if (!alreadyExists) {
        throw createError;
      }

      const authUserId = await findAuthUserIdByPhone(adminClient, authPhone);
      if (!authUserId) {
        throw new Error('Could not resolve existing auth account for this phone.');
      }

      const { error: updateError } = await adminClient.auth.admin.updateUserById(
        authUserId,
        {
          phone: authPhone,
          password,
          phone_confirm: true,
          user_metadata: metadata,
        },
      );
      if (updateError) {
        throw updateError;
      }
    }

    const signInData = await signInWithPhoneCandidates(
      anonClient,
      authPhone,
      password,
    );
    if (!signInData?.session) {
      throw new Error('Supabase did not return a session.');
    }

    return jsonResponse(200, {
      access_token: signInData.session.access_token,
      refresh_token: signInData.session.refresh_token,
      expires_in: signInData.session.expires_in,
      token_type: signInData.session.token_type,
      user: signInData.user,
      legacy_user_id: legacyUserId,
      must_change_password: profile.must_change_password === true,
    });
  } catch (error) {
    return jsonResponse(500, { error: extractErrorMessage(error) });
  }
});
