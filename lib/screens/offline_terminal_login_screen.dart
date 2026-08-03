import 'dart:async';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/auth_service.dart';
import '../services/desktop_registration_service.dart';
import '../services/session_mode_service.dart';
import '../services/team_provisioning_service.dart';
import '../utils/farm_utils.dart';
import '../utils/login_identifier_utils.dart';
import '../utils/secure_auth_storage.dart';
import 'change_password_screen.dart';
import 'role_dashboard_router.dart';
import 'mobile_setup_modal.dart';

const localProfileEstablishedKey = 'LOCAL_PROFILE_ESTABLISHED';

class OfflineTerminalLoginScreen extends StatefulWidget {
  final bool showSoftLockBanner;

  const OfflineTerminalLoginScreen({
    super.key,
    this.showSoftLockBanner = false,
  });

  @override
  State<OfflineTerminalLoginScreen> createState() =>
      _OfflineTerminalLoginScreenState();
}

class _OfflineTerminalLoginScreenState
    extends State<OfflineTerminalLoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _desktopRegistrationService = DesktopRegistrationService();
  bool _isLoading = false;
  bool _googleAuthPending = false;
  bool _handlingGoogleLogin = false;
  bool _obscurePassword = true;
  String? _error;
  String? _message;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!_googleAuthPending) return;
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          unawaited(_completeGoogleLogin());
        }
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(
          () => _error = 'Google sign-in interrupted. Please try again.',
        );
      },
    );

    if (_isGoogleAuthUser(Supabase.instance.client.auth.currentUser)) {
      _googleAuthPending = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _completeGoogleLogin(),
      );
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  bool _isGoogleAuthUser(dynamic user) {
    if (user == null) return false;
    final metadata = user.appMetadata;
    if (metadata is! Map) return false;
    return metadata['provider']?.toString().toLowerCase() == 'google';
  }

  Future<bool> _checkInternetConnection() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final uri = Uri.tryParse(supabaseUrl ?? '');
    try {
      final result = await http
          .head(
            uri != null && uri.host.isNotEmpty
                ? uri
                : Uri.parse('https://www.google.com'),
          )
          .timeout(const Duration(seconds: 3));
      return result.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<void> _signIn() async {
    final identifier = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = 'Account and password are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final db = context.read<AppDatabase>();
      final syncEngine = context.read<SyncEngine>();
      final prefs = await SharedPreferences.getInstance();
      final hasSupabaseConnection = await _checkInternetConnection();

      if (password == workerPlaceholderPassword && looksLikePhone(identifier)) {
        if (!hasSupabaseConnection) {
          _showFirstTimeOfflinePrompt();
          return;
        }
        await _startOnlineFirstTimeActivation(identifier);
        return;
      }

      if (!hasSupabaseConnection &&
          await _trySecureOfflineCredentialLogin(
            identifier: identifier,
            password: password,
            prefs: prefs,
            db: db,
          )) {
        return;
      }

      if (hasSupabaseConnection &&
          await _tryCloudPasswordLogin(
            identifier: identifier,
            password: password,
            db: db,
            syncEngine: syncEngine,
          )) {
        return;
      }

      if (await _trySecureOfflineWorkerLogin(
        identifier: identifier,
        password: password,
        prefs: prefs,
      )) {
        return;
      }

      if (await _trySecureOfflineCredentialLogin(
        identifier: identifier,
        password: password,
        prefs: prefs,
        db: db,
      )) {
        return;
      }

      var cachedUsers = await db.select(db.users).get();
      var user = findCachedUserByIdentifier(cachedUsers, identifier);

      if (user == null) {
        try {
          await syncEngine.performSync();
          if (!mounted) return;
          cachedUsers = await db.select(db.users).get();
          user = findCachedUserByIdentifier(cachedUsers, identifier);
        } catch (_) {}
      }

      if (user == null) {
        throw Exception(
          'Account not found on this device. Use your email, phone number, or owner username.',
        );
      }

      final storedName = (user.name ?? '').trim();
      final storedUsername = storedName.isNotEmpty
          ? storedName
          : (user.email ?? user.phoneNumber ?? '').trim();

      var forceChange = user.mustChangePassword;
      var passwordValid = false;

      if (user.password == null || user.password!.isEmpty) {
        if (password == workerPlaceholderPassword) {
          // First-time login with default password
          // Check for internet connection
          if (!hasSupabaseConnection) {
            _showFirstTimeOfflinePrompt();
            return;
          }

          // Fetch profile to route to setup modal
          final profile = await (db.select(
            db.profiles,
          )..where((p) => p.phoneNumber.equals(identifier))).getSingleOrNull();

          if (profile != null && profile.status == 'PENDING') {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MobileSetupModal(
                  phoneNumber: profile.phoneNumber,
                  role: profile.role,
                  customPermissionsJson: profile.customPermissionsJson,
                ),
              ),
            );
            return;
          }

          passwordValid = true;
          forceChange = true;
        } else {
          throw Exception(
            'Invalid password. First-time users should use 123456.',
          );
        }
      } else {
        try {
          passwordValid = BCrypt.checkpw(password, user.password!);
        } catch (_) {
          throw Exception('Invalid credentials.');
        }
        if (!passwordValid) {
          throw Exception('Invalid password.');
        }
      }

      if (user.role.toUpperCase() == 'OWNER') {
        await FarmUtils.ensureLocalGenesisFarm(db, ownerId: user.id);
      }

      await prefs.setString('user_id', user.id);
      await prefs.setString('user_name', storedUsername);
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_role', user.role);
      UserSession().startSession(
        id: user.id,
        name: storedUsername,
        role: user.role,
      );
      if (hasSupabaseConnection) {
        await SessionModeService.markCloudSync();
      } else {
        await SessionModeService.markSecureOffline();
      }

      if (!mounted) return;

      if (forceChange) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(userId: user!.id),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RoleDashboardRouter(role: user!.role),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _googleAuthPending = true;
      _error = null;
      _message = null;
    });

    try {
      final hasSupabaseConnection = await _checkInternetConnection();
      if (!hasSupabaseConnection) {
        throw Exception('Google sign-in requires internet access.');
      }

      await _desktopRegistrationService.startGoogleRegistration();
      if (!mounted) return;
      setState(
        () => _message =
            'Complete Google sign-in in your browser, then return to HatchLog.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _googleAuthPending = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeGoogleLogin() async {
    if (_handlingGoogleLogin || !mounted) return;
    _handlingGoogleLogin = true;
    setState(() {
      _isLoading = true;
      _error = null;
      _message = 'Finalizing Google sign-in...';
    });

    try {
      final db = context.read<AppDatabase>();
      final syncEngine = context.read<SyncEngine>();
      final result = await _desktopRegistrationService
          .completeGoogleRegistration(db: db);
      if (!mounted) return;
      syncEngine.startPeriodicSync();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: result.role),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      _googleAuthPending = false;
      _handlingGoogleLogin = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _trySecureOfflineWorkerLogin({
    required String identifier,
    required String password,
    required SharedPreferences prefs,
  }) async {
    final setupComplete = await SecureAuthStorage.isSetupComplete();
    if (!setupComplete || !looksLikePhone(identifier)) return false;

    final verified = await SecureAuthStorage.verifyOfflineWorker(
      phoneNumber: identifier,
      password: password,
    );
    if (!verified) return false;

    final userId = (await SecureAuthStorage.getWorkerUserId()) ?? identifier;
    final workerName = (await SecureAuthStorage.getWorkerName()) ?? identifier;
    final role = (await SecureAuthStorage.getWorkerRole()) ?? 'WORKER';
    final storedPhone =
        (await SecureAuthStorage.getPhoneNumber()) ?? identifier;

    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', workerName);
    await prefs.setString('user_phone', storedPhone);
    await prefs.setString('user_role', role);
    await prefs.setBool(localProfileEstablishedKey, true);
    await prefs.setBool('is_initial_setup_completed', true);
    await SessionModeService.markSecureOffline();
    UserSession().startSession(id: userId, name: workerName, role: role);

    if (!mounted) return true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RoleDashboardRouter(role: role)),
    );
    return true;
  }

  Future<bool> _tryCloudPasswordLogin({
    required String identifier,
    required String password,
    required AppDatabase db,
    required SyncEngine syncEngine,
  }) async {
    if (!looksLikeEmail(identifier)) return false;

    try {
      final result = await DesktopRegistrationService().signInWithCloudPassword(
        db: db,
        email: identifier,
        password: password,
      );
      syncEngine.startPeriodicSync();
      if (!mounted) return true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: result.role),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[Login] Cloud password sign-in failed: $e');
      return false;
    }
  }

  Future<bool> _trySecureOfflineCredentialLogin({
    required String identifier,
    required String password,
    required SharedPreferences prefs,
    required AppDatabase db,
  }) async {
    final verified = await SecureAuthStorage.verifyOfflineCredential(
      identifier: identifier,
      secret: password,
    );
    if (!verified) return false;

    final identity = await SecureAuthStorage.getOfflineCredentialIdentity();
    if (identity == null) return false;

    final farmId = (identity.farmId?.trim().isNotEmpty ?? false)
        ? identity.farmId!.trim()
        : FarmUtils.localGenesisFarmId;
    final farmName = (identity.farmName?.trim().isNotEmpty ?? false)
        ? identity.farmName!.trim()
        : FarmUtils.localGenesisFarmName;

    await db.transaction(() async {
      await db
          .into(db.users)
          .insertOnConflictUpdate(
            UsersCompanion.insert(
              id: identity.userId,
              name: Value(identity.displayName),
              email: Value(identity.email),
              phoneNumber: Value(identity.phoneNumber),
              password: const Value(null),
              role: Value(identity.role),
              mustChangePassword: const Value(false),
              synced: const Value(false),
            ),
          );

      await db
          .into(db.farms)
          .insertOnConflictUpdate(
            FarmsCompanion.insert(
              id: farmId,
              name: farmName,
              capacity: 0,
              userId: identity.userId,
              subscriptionTier: const Value(FarmUtils.localOnlySyncStatus),
              syncStatus: const Value(FarmUtils.localOnlySyncStatus),
            ),
          );

      await db
          .into(db.farmMembers)
          .insertOnConflictUpdate(
            FarmMembersCompanion.insert(
              id: 'member_${farmId}_${identity.userId}',
              farmId: farmId,
              userId: identity.userId,
              role: Value(identity.role),
              synced: const Value(false),
            ),
          );
    });

    await prefs.setString('user_id', identity.userId);
    await prefs.setString('user_name', identity.displayName);
    await prefs.setString('user_email', identity.email ?? '');
    await prefs.setString('user_phone', identity.phoneNumber ?? '');
    await prefs.setString('user_role', identity.role);
    await prefs.setString('owner_id', identity.userId);
    await prefs.setBool(localProfileEstablishedKey, true);
    await prefs.setBool('is_bound', true);
    await prefs.setBool('is_initial_setup_completed', true);
    await FarmUtils.setBoundFarmId(farmId);
    await SessionModeService.markSecureOffline();
    UserSession().startSession(
      id: identity.userId,
      name: identity.displayName,
      role: identity.role,
    );

    if (!mounted) return true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoleDashboardRouter(role: identity.role),
      ),
    );
    return true;
  }

  Future<void> _startOnlineFirstTimeActivation(String phoneNumber) async {
    final supabase = Supabase.instance.client;
    final authResponse = await supabase.auth.signInWithPassword(
      phone: phoneNumber,
      password: workerPlaceholderPassword,
    );
    final authUser = authResponse.user;
    if (authUser == null) {
      throw Exception('Online activation sign-in failed.');
    }

    final profile = await _fetchProvisionedProfile(
      supabase: supabase,
      authUserId: authUser.id,
      phoneNumber: phoneNumber,
    );
    if (profile == null) {
      throw Exception(
        'No pending HatchLog profile was found for this phone number.',
      );
    }

    final status = (profile['status'] ?? 'PENDING').toString().toUpperCase();
    if (status != 'PENDING') {
      throw Exception(
        'This account is already active. Sign in with your secure password.',
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MobileSetupModal(
          phoneNumber:
              (profile['phoneNumber'] ?? profile['phone_number'] ?? phoneNumber)
                  .toString(),
          role: (profile['role'] ?? 'WORKER').toString(),
          customPermissionsJson: _jsonText(
            profile['customPermissionsJson'] ??
                profile['custom_permissions_json'],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchProvisionedProfile({
    required SupabaseClient supabase,
    required String authUserId,
    required String phoneNumber,
  }) async {
    try {
      final byAuth = await supabase
          .from('profiles')
          .select()
          .eq('authUserId', authUserId)
          .maybeSingle();
      if (byAuth != null) return Map<String, dynamic>.from(byAuth);
    } catch (error) {
      debugPrint('Profile lookup by auth user failed: $error');
    }

    final byPhone = await supabase
        .from('profiles')
        .select()
        .eq('phoneNumber', phoneNumber)
        .maybeSingle();
    if (byPhone == null) return null;
    return Map<String, dynamic>.from(byPhone);
  }

  String? _jsonText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List || value is Map) return jsonEncode(value);
    return value.toString();
  }

  void _showFirstTimeOfflinePrompt() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _FirstTimeActivationOfflinePrompt(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Column(
          children: [
            if (widget.showSoftLockBanner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: const Color(0xFFEF4444).withOpacity(0.15),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.alertTriangle,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your subscription has expired. You have up to 5 days of continued access. Upgrade your plan to avoid losing access.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final url = dotenv.env['WEB_APP_URL'] ?? '';
                        if (url.isNotEmpty) {
                          await launchUrl(
                            Uri.parse('$url/dashboard/license-upgrade'),
                          );
                        }
                      },
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: Center(child: _buildLoginCard())),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF22C55E),
              size: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Sign In to Terminal Dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.32)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.32),
                  ),
                ),
                child: Text(
                  _message!,
                  style: const TextStyle(
                    color: Color(0xFFBAE6FD),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _usernameCtrl,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                labelText: 'Email, phone, or username',
                hintText: 'Owner username, phone, or email',
                labelStyle: const TextStyle(color: Color(0xFF22C55E)),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Color(0xFF22C55E), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: Colors.white,
              onSubmitted: (_) => _signIn(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Color(0xFF22C55E), width: 2),
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _startGoogleLogin,
                icon: _isLoading && _googleAuthPending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.chrome, size: 18),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstTimeActivationOfflinePrompt extends StatelessWidget {
  const _FirstTimeActivationOfflinePrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFFF59E0B),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'First-time account activation requires internet access. Please complete your setup near the farm office router.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Sign In'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
