import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../screens/offline_terminal_login_screen.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/secure_auth_storage.dart';
import 'auth_service.dart';
import 'session_mode_service.dart';

class DesktopRegistrationResult {
  final String userId;
  final String role;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String farmId;
  final String farmName;
  final bool isNewGoogleRegistrant;

  const DesktopRegistrationResult({
    required this.userId,
    required this.role,
    required this.displayName,
    required this.farmId,
    required this.farmName,
    this.email,
    this.phoneNumber,
    this.isNewGoogleRegistrant = false,
  });
}

class DesktopRegistrationService {
  supa.SupabaseClient get _supabase => supa.Supabase.instance.client;

  Future<void> startGoogleRegistration() async {
    await _supabase.auth.signInWithOAuth(
      supa.OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'poultry-pms://login-callback/',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<DesktopRegistrationResult> completeGoogleRegistration({
    required AppDatabase db,
  }) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      throw Exception('Google authentication did not return a user session.');
    }

    final email = authUser.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw Exception('Google did not return a verified email address.');
    }

    final existingCloudUser = await _findCloudUserByEmail(email);
    final isNewRegistrant = existingCloudUser == null;
    final displayName = _displayNameForAuthUser(authUser, email);
    final userId = (existingCloudUser?['id'] ?? authUser.id).toString();
    final farmId = await _resolveOrCreateFarmId(
      ownerId: userId,
      fallbackName: '$displayName Farm',
    );
    final farmName = await _resolveFarmName(farmId) ?? '$displayName Farm';

    if (isNewRegistrant) {
      await _upsertCloudOwnerRows(
        userId: userId,
        email: email,
        phoneNumber: null,
        displayName: displayName,
        farmId: farmId,
        farmName: farmName,
      );
    }

    await _upsertLocalOwner(
      db: db,
      userId: userId,
      email: email,
      phoneNumber: null,
      displayName: displayName,
      farmId: farmId,
      farmName: farmName,
      cloudSynced: true,
    );
    await _persistSession(
      userId: userId,
      displayName: displayName,
      email: email,
      phoneNumber: null,
      role: 'OWNER',
      farmId: farmId,
      farmName: farmName,
    );

    await SecureAuthStorage.setNewGoogleRegistrant(isNewRegistrant);
    await SessionModeService.markCloudSync();

    return DesktopRegistrationResult(
      userId: userId,
      role: 'OWNER',
      displayName: displayName,
      email: email,
      farmId: farmId,
      farmName: farmName,
      isNewGoogleRegistrant: isNewRegistrant,
    );
  }

  Future<DesktopRegistrationResult> registerTraditional({
    required AppDatabase db,
    required String farmName,
    required String ownerPhoneNumber,
    required String adminEmail,
    required String masterPassword,
  }) async {
    final normalizedEmail = adminEmail.trim().toLowerCase();
    final normalizedPhone = ownerPhoneNumber.trim();
    final normalizedFarmName = farmName.trim();
    final farmId = newLocalId();

    final authResponse = await _supabase.auth.signUp(
      email: normalizedEmail,
      password: masterPassword,
      data: {
        'registration_route': 'traditional_desktop',
        'farm_id': farmId,
        'farm_name': normalizedFarmName,
        'owner_phone_number': normalizedPhone,
        'role': 'OWNER',
      },
    );

    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('Supabase sign-up did not return a user profile.');
    }

    final displayName = normalizedEmail;
    await SecureAuthStorage.saveOfflineCredential(
      userId: authUser.id,
      secret: masterPassword,
      displayName: displayName,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      farmId: farmId,
      farmName: normalizedFarmName,
      provider: 'password',
    );
    await SecureAuthStorage.setNewGoogleRegistrant(false);

    await _upsertCloudOwnerRows(
      userId: authUser.id,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      displayName: displayName,
      farmId: farmId,
      farmName: normalizedFarmName,
    );
    await _upsertLocalOwner(
      db: db,
      userId: authUser.id,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      displayName: displayName,
      farmId: farmId,
      farmName: normalizedFarmName,
      cloudSynced: authResponse.session != null,
    );
    await _persistSession(
      userId: authUser.id,
      displayName: displayName,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      role: 'OWNER',
      farmId: farmId,
      farmName: normalizedFarmName,
    );
    await SessionModeService.markCloudSync();

    return DesktopRegistrationResult(
      userId: authUser.id,
      role: 'OWNER',
      displayName: displayName,
      email: normalizedEmail,
      phoneNumber: normalizedPhone,
      farmId: farmId,
      farmName: normalizedFarmName,
    );
  }

  Future<DesktopRegistrationResult> signInWithCloudPassword({
    required AppDatabase db,
    required String email,
    required String password,
  }) async {
    final authResponse = await _supabase.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('Cloud authentication failed.');
    }

    final normalizedEmail =
        authUser.email?.trim().toLowerCase() ?? email.trim().toLowerCase();
    final cloudUser = await _findCloudUserByEmail(normalizedEmail);
    final userId = (cloudUser?['id'] ?? authUser.id).toString();
    final displayName =
        _safeText(cloudUser?['name']) ??
        _displayNameForAuthUser(authUser, normalizedEmail);
    final role = _safeText(cloudUser?['role']) ?? 'OWNER';
    final phone = _safeText(
      cloudUser?['phone_number'] ?? cloudUser?['phoneNumber'],
    );
    final farmId = await _resolveOrCreateFarmId(
      ownerId: userId,
      fallbackName: '$displayName Farm',
    );
    final farmName = await _resolveFarmName(farmId) ?? '$displayName Farm';

    await _upsertLocalOwner(
      db: db,
      userId: userId,
      email: normalizedEmail,
      phoneNumber: phone,
      displayName: displayName,
      role: role,
      farmId: farmId,
      farmName: farmName,
      cloudSynced: true,
    );
    await _persistSession(
      userId: userId,
      displayName: displayName,
      email: normalizedEmail,
      phoneNumber: phone,
      role: role,
      farmId: farmId,
      farmName: farmName,
    );
    await SessionModeService.markCloudSync();

    return DesktopRegistrationResult(
      userId: userId,
      role: role,
      displayName: displayName,
      email: normalizedEmail,
      phoneNumber: phone,
      farmId: farmId,
      farmName: farmName,
    );
  }

  Future<Map<String, dynamic>?> _findCloudUserByEmail(String email) async {
    try {
      final row = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (row == null) return null;
      return Map<String, dynamic>.from(row);
    } catch (error) {
      debugPrint('[DesktopRegistration] User lookup failed: $error');
      return null;
    }
  }

  Future<String> _resolveOrCreateFarmId({
    required String ownerId,
    required String fallbackName,
  }) async {
    final existing = await _findCloudFarmForUser(ownerId);
    final id = _safeText(existing?['id']);
    if (id != null) return id;

    final farmId = newLocalId();
    try {
      await _supabase.from('farms').upsert({
        'id': farmId,
        'name': fallbackName,
        'capacity': 0,
        'userId': ownerId,
        'subscriptionTier': 'FREE',
      }, onConflict: 'id');
    } catch (error) {
      debugPrint('[DesktopRegistration] Cloud farm upsert skipped: $error');
    }
    return farmId;
  }

  Future<String?> _resolveFarmName(String farmId) async {
    try {
      final row = await _supabase
          .from('farms')
          .select('name')
          .eq('id', farmId)
          .maybeSingle();
      return _safeText(row?['name']);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _findCloudFarmForUser(String ownerId) async {
    try {
      final row = await _supabase
          .from('farms')
          .select()
          .eq('userId', ownerId)
          .maybeSingle();
      if (row != null) return Map<String, dynamic>.from(row);
    } catch (_) {}

    try {
      final row = await _supabase
          .from('farms')
          .select()
          .eq('user_id', ownerId)
          .maybeSingle();
      if (row != null) return Map<String, dynamic>.from(row);
    } catch (_) {}

    return null;
  }

  Future<void> _upsertCloudOwnerRows({
    required String userId,
    required String email,
    required String? phoneNumber,
    required String displayName,
    required String farmId,
    required String farmName,
  }) async {
    try {
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'phone_number': phoneNumber,
        'name': displayName,
        'role': 'OWNER',
        'must_change_password': false,
      }, onConflict: 'id');
    } catch (error) {
      debugPrint('[DesktopRegistration] Cloud user upsert skipped: $error');
    }

    try {
      await _supabase.from('farms').upsert({
        'id': farmId,
        'name': farmName,
        'capacity': 0,
        'userId': userId,
        'subscriptionTier': 'FREE',
      }, onConflict: 'id');
    } catch (error) {
      debugPrint('[DesktopRegistration] Cloud farm upsert skipped: $error');
    }

    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    try {
      await _supabase.from('profiles').upsert({
        'id': 'owner_$userId',
        'farmId': farmId,
        'authUserId': userId,
        'phoneNumber': phoneNumber.trim(),
        'role': 'OWNER',
        'status': 'ACTIVE',
      }, onConflict: 'id');
    } catch (error) {
      debugPrint('[DesktopRegistration] Cloud profile upsert skipped: $error');
    }
  }

  Future<void> _upsertLocalOwner({
    required AppDatabase db,
    required String userId,
    required String? email,
    required String? phoneNumber,
    required String displayName,
    required String farmId,
    required String farmName,
    String role = 'OWNER',
    required bool cloudSynced,
  }) async {
    await db.transaction(() async {
      await db
          .into(db.users)
          .insertOnConflictUpdate(
            UsersCompanion.insert(
              id: userId,
              email: Value(email),
              phoneNumber: Value(phoneNumber),
              name: Value(displayName),
              role: Value(role),
              password: const Value(null),
              mustChangePassword: const Value(false),
              synced: Value(cloudSynced),
            ),
          );

      await db
          .into(db.farms)
          .insertOnConflictUpdate(
            FarmsCompanion.insert(
              id: farmId,
              name: farmName,
              capacity: 0,
              userId: userId,
              subscriptionTier: const Value('FREE'),
              syncStatus: Value(
                cloudSynced ? 'CLOUD_SYNCED' : FarmUtils.localOnlySyncStatus,
              ),
            ),
          );

      await db
          .into(db.farmMembers)
          .insertOnConflictUpdate(
            FarmMembersCompanion.insert(
              id: 'member_${farmId}_$userId',
              farmId: farmId,
              userId: userId,
              role: Value(role),
              synced: Value(cloudSynced),
            ),
          );
    });
  }

  Future<void> _persistSession({
    required String userId,
    required String displayName,
    required String? email,
    required String? phoneNumber,
    required String role,
    required String farmId,
    required String farmName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(localProfileEstablishedKey, true);
    await prefs.setBool('is_bound', true);
    await prefs.setBool('is_initial_setup_completed', true);
    await prefs.setString('owner_id', userId);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', displayName);
    await prefs.setString('user_email', email ?? '');
    await prefs.setString('user_phone', phoneNumber ?? '');
    await prefs.setString('user_role', role);
    await prefs.setString('farm_name', farmName);
    await FarmUtils.setBoundFarmId(farmId);
    UserSession().startSession(id: userId, name: displayName, role: role);
  }

  String _displayNameForAuthUser(supa.User authUser, String fallbackEmail) {
    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    return _safeText(
          metadata['full_name'] ??
              metadata['name'] ??
              metadata['preferred_username'],
        ) ??
        fallbackEmail;
  }

  String? _safeText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
