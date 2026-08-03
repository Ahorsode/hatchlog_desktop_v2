import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OfflineCredentialIdentity {
  final String userId;
  final String displayName;
  final String role;
  final String? email;
  final String? phoneNumber;
  final String? farmId;
  final String? farmName;
  final String? provider;

  const OfflineCredentialIdentity({
    required this.userId,
    required this.displayName,
    required this.role,
    this.email,
    this.phoneNumber,
    this.farmId,
    this.farmName,
    this.provider,
  });
}

/// Secure storage for offline-capable mobile authentication
class SecureAuthStorage {
  static const _secureStorage = FlutterSecureStorage();
  static const String _workerNameKey = 'worker_name';
  static const String _workerFirstNameKey = 'worker_first_name';
  static const String _workerLastNameKey = 'worker_last_name';
  static const String _workerRoleKey = 'worker_role';
  static const String _workerUserIdKey = 'worker_user_id';
  static const String _workerPermissionsKey = 'worker_permissions_json';
  static const String _phoneNumberKey = 'phone_number';
  static const String _passwordHashKey = 'password_hash';
  static const String _setupCompleteKey = 'initial_setup_completed';
  static const String _offlineHashKey = 'desktop_offline_credential_hash';
  static const String _offlineUserIdKey = 'desktop_offline_user_id';
  static const String _offlineDisplayNameKey = 'desktop_offline_display_name';
  static const String _offlineRoleKey = 'desktop_offline_role';
  static const String _offlineEmailKey = 'desktop_offline_email';
  static const String _offlinePhoneKey = 'desktop_offline_phone';
  static const String _offlineFarmIdKey = 'desktop_offline_farm_id';
  static const String _offlineFarmNameKey = 'desktop_offline_farm_name';
  static const String _offlineProviderKey = 'desktop_offline_provider';
  static const String _newGoogleRegistrantKey = 'is_new_google_registrant';

  /// Save worker profile after first-time setup
  static Future<void> saveWorkerProfile({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
    required String userId,
    String? customPermissionsJson,
  }) async {
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    await Future.wait([
      _secureStorage.write(key: _phoneNumberKey, value: phoneNumber),
      _secureStorage.write(key: _workerFirstNameKey, value: firstName),
      _secureStorage.write(key: _workerLastNameKey, value: lastName),
      _secureStorage.write(key: _workerNameKey, value: '$firstName $lastName'),
      _secureStorage.write(key: _workerRoleKey, value: role),
      _secureStorage.write(key: _workerUserIdKey, value: userId),
      _secureStorage.write(
        key: _workerPermissionsKey,
        value: customPermissionsJson ?? '[]',
      ),
      _secureStorage.write(key: _passwordHashKey, value: passwordHash),
      _secureStorage.write(key: _setupCompleteKey, value: 'true'),
    ]);
  }

  /// Check if initial setup is complete
  static Future<bool> isSetupComplete() async {
    final value = await _secureStorage.read(key: _setupCompleteKey);
    return value == 'true';
  }

  /// Verify offline password against stored hash
  static Future<bool> verifyOfflinePassword(String password) async {
    final storedHash = await _secureStorage.read(key: _passwordHashKey);
    if (storedHash == null) return false;
    try {
      return BCrypt.checkpw(password, storedHash);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> verifyOfflineWorker({
    required String phoneNumber,
    required String password,
  }) async {
    final storedPhone = await getPhoneNumber();
    if (!_phonesMatch(storedPhone, phoneNumber)) return false;
    return verifyOfflinePassword(password);
  }

  static Future<void> saveOfflineCredential({
    required String userId,
    required String secret,
    required String displayName,
    String role = 'OWNER',
    String? email,
    String? phoneNumber,
    String? farmId,
    String? farmName,
    String? provider,
  }) async {
    final secretHash = BCrypt.hashpw(secret, BCrypt.gensalt());
    await Future.wait([
      _secureStorage.write(key: _offlineHashKey, value: secretHash),
      _secureStorage.write(key: _offlineUserIdKey, value: userId),
      _secureStorage.write(key: _offlineDisplayNameKey, value: displayName),
      _secureStorage.write(key: _offlineRoleKey, value: role),
      _writeOptional(_offlineEmailKey, email?.trim().toLowerCase()),
      _writeOptional(_offlinePhoneKey, phoneNumber?.trim()),
      _writeOptional(_offlineFarmIdKey, farmId?.trim()),
      _writeOptional(_offlineFarmNameKey, farmName?.trim()),
      _writeOptional(_offlineProviderKey, provider?.trim()),
    ]);
  }

  static Future<bool> hasOfflineCredential() async {
    return _secureStorage.containsKey(key: _offlineHashKey);
  }

  static Future<bool> verifyOfflineCredential({
    required String identifier,
    required String secret,
  }) async {
    final storedHash = await _secureStorage.read(key: _offlineHashKey);
    if (storedHash == null || storedHash.isEmpty) return false;
    if (!await _identifierMatches(identifier)) return false;

    try {
      return BCrypt.checkpw(secret, storedHash);
    } catch (_) {
      return false;
    }
  }

  static Future<OfflineCredentialIdentity?>
  getOfflineCredentialIdentity() async {
    final userId = await _secureStorage.read(key: _offlineUserIdKey);
    if (userId == null || userId.trim().isEmpty) return null;

    return OfflineCredentialIdentity(
      userId: userId.trim(),
      displayName:
          (await _secureStorage.read(key: _offlineDisplayNameKey))?.trim() ??
          userId.trim(),
      role:
          (await _secureStorage.read(key: _offlineRoleKey))?.trim() ?? 'OWNER',
      email: await _secureStorage.read(key: _offlineEmailKey),
      phoneNumber: await _secureStorage.read(key: _offlinePhoneKey),
      farmId: await _secureStorage.read(key: _offlineFarmIdKey),
      farmName: await _secureStorage.read(key: _offlineFarmNameKey),
      provider: await _secureStorage.read(key: _offlineProviderKey),
    );
  }

  static Future<void> setNewGoogleRegistrant(bool value) async {
    await _secureStorage.write(
      key: _newGoogleRegistrantKey,
      value: value ? 'true' : 'false',
    );
  }

  static Future<bool> isNewGoogleRegistrant() async {
    final value = await _secureStorage.read(key: _newGoogleRegistrantKey);
    return value == 'true';
  }

  /// Get stored worker name
  static Future<String?> getWorkerName() async {
    return await _secureStorage.read(key: _workerNameKey);
  }

  /// Get stored phone number
  static Future<String?> getPhoneNumber() async {
    return await _secureStorage.read(key: _phoneNumberKey);
  }

  static Future<String?> getWorkerRole() async {
    return await _secureStorage.read(key: _workerRoleKey);
  }

  static Future<String?> getWorkerUserId() async {
    return await _secureStorage.read(key: _workerUserIdKey);
  }

  static Future<String?> getWorkerPermissionsJson() async {
    return await _secureStorage.read(key: _workerPermissionsKey);
  }

  static bool _phonesMatch(String? stored, String input) {
    final a = (stored ?? '').replaceAll(RegExp(r'\D'), '');
    final b = input.replaceAll(RegExp(r'\D'), '');
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.endsWith(b) || b.endsWith(a);
  }

  static Future<bool> _identifierMatches(String identifier) async {
    final input = identifier.trim();
    if (input.isEmpty) return false;

    final storedEmail = await _secureStorage.read(key: _offlineEmailKey);
    final storedPhone = await _secureStorage.read(key: _offlinePhoneKey);
    final storedName = await _secureStorage.read(key: _offlineDisplayNameKey);
    final storedUserId = await _secureStorage.read(key: _offlineUserIdKey);

    if (_emailsMatch(storedEmail, input)) return true;
    if (_phonesMatch(storedPhone, input)) return true;
    if (_stringsMatch(storedName, input)) return true;
    if (_stringsMatch(storedUserId, input)) return true;
    return false;
  }

  static bool _emailsMatch(String? stored, String input) {
    final a = (stored ?? '').trim().toLowerCase();
    final b = input.trim().toLowerCase();
    return a.isNotEmpty && a == b;
  }

  static bool _stringsMatch(String? stored, String input) {
    final a = (stored ?? '').trim().toLowerCase();
    final b = input.trim().toLowerCase();
    return a.isNotEmpty && a == b;
  }

  static Future<void> _writeOptional(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _secureStorage.delete(key: key);
      return;
    }
    await _secureStorage.write(key: key, value: value.trim());
  }

  /// Clear all stored auth data (logout)
  static Future<void> clearAll() async {
    await Future.wait([
      _secureStorage.delete(key: _phoneNumberKey),
      _secureStorage.delete(key: _workerFirstNameKey),
      _secureStorage.delete(key: _workerLastNameKey),
      _secureStorage.delete(key: _workerNameKey),
      _secureStorage.delete(key: _workerRoleKey),
      _secureStorage.delete(key: _workerUserIdKey),
      _secureStorage.delete(key: _workerPermissionsKey),
      _secureStorage.delete(key: _passwordHashKey),
      _secureStorage.delete(key: _setupCompleteKey),
      _secureStorage.delete(key: _offlineHashKey),
      _secureStorage.delete(key: _offlineUserIdKey),
      _secureStorage.delete(key: _offlineDisplayNameKey),
      _secureStorage.delete(key: _offlineRoleKey),
      _secureStorage.delete(key: _offlineEmailKey),
      _secureStorage.delete(key: _offlinePhoneKey),
      _secureStorage.delete(key: _offlineFarmIdKey),
      _secureStorage.delete(key: _offlineFarmNameKey),
      _secureStorage.delete(key: _offlineProviderKey),
      _secureStorage.delete(key: _newGoogleRegistrantKey),
    ]);
  }
}
