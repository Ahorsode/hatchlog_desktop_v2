import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../services/session_mode_service.dart';
import '../utils/farm_utils.dart';
import '../utils/secure_auth_storage.dart';

class OfflineSecuritySetupGate extends StatefulWidget {
  final Widget child;

  const OfflineSecuritySetupGate({super.key, required this.child});

  @override
  State<OfflineSecuritySetupGate> createState() =>
      _OfflineSecuritySetupGateState();
}

class _OfflineSecuritySetupGateState extends State<OfflineSecuritySetupGate> {
  bool _checking = true;
  bool _showingModal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkGate());
  }

  Future<void> _checkGate() async {
    final needsSetup = await SecureAuthStorage.isNewGoogleRegistrant();
    if (!mounted) return;
    setState(() => _checking = false);
    if (needsSetup) {
      await _showOfflineSetupModal();
    }
  }

  Future<void> _showOfflineSetupModal() async {
    if (_showingModal || !mounted) return;
    _showingModal = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const _OfflineSecuritySetupDialog(),
    );
    _showingModal = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}

class _OfflineSecuritySetupDialog extends StatefulWidget {
  const _OfflineSecuritySetupDialog();

  @override
  State<_OfflineSecuritySetupDialog> createState() =>
      _OfflineSecuritySetupDialogState();
}

class _OfflineSecuritySetupDialogState
    extends State<_OfflineSecuritySetupDialog> {
  final _secretCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureSecret = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _secretCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final secret = _secretCtrl.text;
    final confirm = _confirmCtrl.text;
    final isSixDigitPin = RegExp(r'^\d{6}$').hasMatch(secret);
    final isStrongPassword = secret.length >= 8;

    if (secret.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Enter and confirm your offline credential.');
      return;
    }
    if (secret != confirm) {
      setState(() => _error = 'The offline credentials do not match.');
      return;
    }
    if (!isSixDigitPin && !isStrongPassword) {
      setState(
        () => _error =
            'Use a 6-digit PIN or an offline password with at least 8 characters.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final authUser = supa.Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        throw Exception('Google session expired. Sign in again to continue.');
      }
      final email = authUser.email?.trim().toLowerCase();
      final displayName = _displayNameFor(authUser, email ?? authUser.id);
      final prefs = await SharedPreferences.getInstance();
      final farmId = await FarmUtils.getBoundFarmId();
      final farmName = prefs.getString('farm_name');

      await SecureAuthStorage.saveOfflineCredential(
        userId: authUser.id,
        secret: secret,
        displayName: displayName,
        email: email,
        farmId: farmId,
        farmName: farmName,
        role: 'OWNER',
        provider: 'google',
      );
      await SecureAuthStorage.setNewGoogleRegistrant(false);
      await SessionModeService.markCloudSync();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _displayNameFor(supa.User authUser, String fallback) {
    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final value =
        metadata['full_name'] ??
        metadata['name'] ??
        metadata['preferred_username'];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
        contentPadding: const EdgeInsets.fromLTRB(26, 18, 26, 8),
        actionsPadding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
        title: const Row(
          children: [
            Icon(Icons.enhanced_encryption_rounded, color: Color(0xFF16A34A)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline Security Setup',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text(
                  'Welcome to HatchLog! Since you signed up via Google, please configure a secondary offline password or 6-digit PIN. This ensures you can access your workstation database even when the farm completely loses internet connectivity.',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: _secretCtrl,
                obscureText: _obscureSecret,
                decoration: InputDecoration(
                  labelText: 'Create Offline Password/PIN',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscureSecret ? 'Show' : 'Hide',
                    onPressed: () =>
                        setState(() => _obscureSecret = !_obscureSecret),
                    icon: Icon(
                      _obscureSecret
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureSecret,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'Confirm Offline Password/PIN',
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(_saving ? 'Saving...' : 'Save & Unlock Dashboard'),
            ),
          ),
        ],
      ),
    );
  }
}
