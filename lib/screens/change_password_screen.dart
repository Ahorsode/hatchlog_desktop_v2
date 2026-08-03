import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:provider/provider.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart' as drift;
import 'role_dashboard_router.dart';
import '../data/local_db.dart';
import '../theme/theme_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmController.text;

    if (newPw.isEmpty || confirmPw.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
      return;
    }
    if (newPw.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }
    if (newPw == '123456') {
      setState(() => _errorMessage = 'Please choose a different password from the default.');
      return;
    }
    if (newPw != confirmPw) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final supabase = Supabase.instance.client;

      // 1. Hash locally first
      final String salt = BCrypt.gensalt();
      final String hashedPw = BCrypt.hashpw(newPw, salt);

      // 2. Try to update remote (if possible)
      try {
        await supabase.rpc('change_user_password', params: {
          'p_user_id': widget.userId,
          'p_new_password': newPw, // The RPC handles hashing on the server for the remote DB
        });
      } catch (e) {
        // Log warning but continue — it will sync later if we implement a sync queue
        debugPrint('Remote password update failed: $e');
      }

      // 3. Update local DB so offline login works immediately
      await (db.update(db.users)..where((t) => t.id.equals(widget.userId)))
          .write(UsersCompanion(
        password: drift.Value(hashedPw),
        mustChangePassword: const drift.Value(false),
      ));

      if (!mounted) return;
      // Show success snack then navigate to the main app
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: 'OWNER'),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Card is always light; global theme may be dark (white-on-white title bug).
    final lightTheme = context.watch<ThemeProvider>().lightTheme;
    final onSurface = lightTheme.colorScheme.onSurface;
    final onSurfaceVariant = lightTheme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Theme(
          data: lightTheme,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: lightTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lightTheme.colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon + heading
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.keyRound, color: Color(0xFF16A34A), size: 28),
                ),
                const SizedBox(height: 20),
                Text(
                  'Set Your Password',
                  style: lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re using a default password. Please create a new secure password to continue.',
                  style: TextStyle(
                    fontSize: 14,
                    color: onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              const SizedBox(height: 28),

              // Error banner
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // New password
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  labelText: 'New password',
                  hintText: 'At least 8 characters',
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                ),
              ),
              const SizedBox(height: 14),

              // Confirm password
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: TextStyle(color: onSurface),
                onSubmitted: (_) => _isLoading ? null : _changePassword(),
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: const Icon(LucideIcons.shieldCheck, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                ),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Password & Continue',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
