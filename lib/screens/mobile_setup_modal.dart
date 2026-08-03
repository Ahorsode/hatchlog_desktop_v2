import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;

import '../data/local_db.dart';
import '../services/auth_service.dart';
import '../services/team_provisioning_service.dart';
import '../utils/secure_auth_storage.dart';
import 'role_dashboard_router.dart';

/// Un-dismissible account setup modal for first-time mobile workers
class MobileSetupModal extends StatefulWidget {
  final String phoneNumber;
  final String role;
  final String? customPermissionsJson;

  const MobileSetupModal({
    super.key,
    required this.phoneNumber,
    required this.role,
    this.customPermissionsJson,
  });

  @override
  State<MobileSetupModal> createState() => _MobileSetupModalState();
}

class _MobileSetupModalState extends State<MobileSetupModal> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty || password.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }

    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    if (password == workerPlaceholderPassword) {
      setState(() => _error = 'Choose a password different from 123456.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final db = context.read<AppDatabase>();
      final prefs = await SharedPreferences.getInstance();
      final authUser = supabase.auth.currentUser;
      final userId = authUser?.id ?? widget.phoneNumber;

      // 1. Replace the temporary Auth password while the online session exists.
      await supabase.auth.updateUser(
        UserAttributes(
          password: password,
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'onboarding_status': 'active',
          },
        ),
      );

      // 2. Activate the provisioned profile and create farm membership.
      try {
        await supabase.rpc(
          'complete_worker_activation',
          params: {
            'p_phone_number': widget.phoneNumber,
            'p_first_name': firstName,
            'p_last_name': lastName,
          },
        );
      } catch (e) {
        debugPrint('Activation RPC failed, falling back to profile patch: $e');
        await supabase
            .from('profiles')
            .update({
              'firstName': firstName,
              'lastName': lastName,
              'status': 'ACTIVE',
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('phoneNumber', widget.phoneNumber);
      }

      // 3. Save bcrypt-hashed offline credential in encrypted secure storage.
      await SecureAuthStorage.saveWorkerProfile(
        phoneNumber: widget.phoneNumber,
        firstName: firstName,
        lastName: lastName,
        password: password,
        role: widget.role,
        userId: userId,
        customPermissionsJson: widget.customPermissionsJson,
      );

      // 4. Update local records without storing the worker password in SQLite.
      try {
        final profile =
            await (db.select(db.profiles)
                  ..where((p) => p.phoneNumber.equals(widget.phoneNumber)))
                .getSingleOrNull();
        if (profile != null) {
          await (db.update(
            db.profiles,
          )..where((p) => p.id.equals(profile.id))).write(
            ProfilesCompanion(
              firstName: drift.Value(firstName),
              lastName: drift.Value(lastName),
              status: const drift.Value('ACTIVE'),
            ),
          );
        }

        await db
            .into(db.users)
            .insertOnConflictUpdate(
              UsersCompanion.insert(
                id: userId,
                firstname: drift.Value(firstName),
                surname: drift.Value(lastName),
                name: drift.Value('$firstName $lastName'),
                phoneNumber: drift.Value(widget.phoneNumber),
                role: drift.Value(widget.role),
                mustChangePassword: const drift.Value(false),
                synced: const drift.Value(true),
              ),
            );
      } catch (e) {
        debugPrint('Local profile update failed: $e');
      }

      // 5. Set session
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', '$firstName $lastName');
      await prefs.setString('user_phone', widget.phoneNumber);
      await prefs.setString('user_role', widget.role);
      await prefs.setBool('LOCAL_PROFILE_ESTABLISHED', true);
      await prefs.setBool('is_initial_setup_completed', true);
      UserSession().startSession(
        id: userId,
        name: '$firstName $lastName',
        role: widget.role,
      );

      if (!mounted) return;

      // 6. Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: widget.role),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent back button
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add_rounded,
                      color: Color(0xFF22C55E),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Account Setup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to HatchLog! Please complete your account profile by entering your name and creating a secure password to unlock your dashboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.32),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _firstNameCtrl,
                      enabled: !_isSubmitting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        hintText: 'First Name',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF22C55E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _lastNameCtrl,
                      enabled: !_isSubmitting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        hintText: 'Last Name',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF22C55E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordCtrl,
                      enabled: !_isSubmitting,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        hintText: 'Create New Password',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF22C55E),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmCtrl,
                      enabled: !_isSubmitting,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF22C55E),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _completeSetup,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF22C55E),
                        disabledBackgroundColor: const Color(
                          0xFF22C55E,
                        ).withValues(alpha: 0.5),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Complete Setup & Activate Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Note: This setup cannot be cancelled. Complete it near your farm office router for the best connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
