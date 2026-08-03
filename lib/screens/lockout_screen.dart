import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../services/license_service.dart';
import '../utils/id_utils.dart';
import 'offline_terminal_login_screen.dart';

/// The reason the lockout screen is shown – controls which variant is rendered.
enum LockoutReason {
  /// The 30-day offline trial (or any license period) has expired.
  trialExpired,

  /// System clock was rolled back past the last recorded write time.
  clockTampered,
}

/// Full-screen lockout wall shown when a license expires or the system clock
/// is tampered with.
///
/// **Trial-expired variant**: links the user to the web upgrade flow and lets
/// them re-check subscription status after paying.
///
/// **Clock-tampered variant**: instructs the user to fix the system clock.
class LockoutScreen extends StatefulWidget {
  final LockoutReason reason;
  const LockoutScreen({super.key, required this.reason});

  @override
  State<LockoutScreen> createState() => _LockoutScreenState();
}

class _LockoutScreenState extends State<LockoutScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _error;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Clock-tamper: retry check ─────────────────────────────────────────────
  Future<void> _retryClockCheck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final db = context.read<AppDatabase>();
      final svc = LicenseService(db);
      final status = await svc.checkLicense();
      if (!mounted) return;
      if (status == LicenseStatus.valid || status == LicenseStatus.softLocked) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
        );
      } else {
        setState(
          () => _error =
              'Clock issue still detected. Please correct your system time and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openUpgradePage() async {
    final baseUrl = dotenv.env['WEB_APP_URL']?.trim();
    final upgradeUrl = (baseUrl == null || baseUrl.isEmpty)
        ? 'https://your-app-domain.com/dashboard/license-upgrade'
        : '$baseUrl/dashboard/license-upgrade';
    await launchUrl(Uri.parse(upgradeUrl));
  }

  Future<void> _checkAgain() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = context.read<AppDatabase>();
      final svc = LicenseService(db);
      final config = await svc.getConfig();
      final hardwareId = config?.hardwareId ?? await getDeviceHardwareId();
      await svc.renewFromCloud(hardwareId);
      final status = await svc.checkLicense();

      if (!mounted) return;

      if (status == LicenseStatus.valid || status == LicenseStatus.softLocked) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OfflineTerminalLoginScreen(
              showSoftLockBanner: status == LicenseStatus.softLocked,
            ),
          ),
        );
        return;
      }

      setState(
        () => _error =
            'Still showing as expired. It may take a few minutes for payment to process. Please try again shortly.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Subscription check failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A0A0F), Color(0xFF120A1E)],
                ),
              ),
            ),
          ),
          // Pulsing glow behind lock icon
          Center(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.reason == LockoutReason.clockTampered
                            ? const Color(0xFFF59E0B).withOpacity(0.14)
                            : const Color(0xFFEF4444).withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: widget.reason == LockoutReason.clockTampered
                  ? _buildClockTamperVariant()
                  : _buildTrialExpiredVariant(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Clock-tamper variant ──────────────────────────────────────────────────
  Widget _buildClockTamperVariant() {
    return _GlassCard(
      width: 500,
      borderColor: const Color(0xFFF59E0B),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.15),
            ),
            child: Icon(
              LucideIcons.clock,
              size: 40,
              color: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'System Clock Anomaly Detected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your system clock appears to have been set to a time in the past. '
            'This security measure prevents license tampering.\n\n'
            'Please correct your system time in Windows Settings, then click '
            '"Retry" below.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _retryClockCheck,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFF59E0B),
                          ),
                        )
                      : const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Retry Clock Check'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'HatchLog Security — Anti-Clock-Tamper Protection',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.25),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Trial-expired variant ─────────────────────────────────────────────────
  Widget _buildTrialExpiredVariant() {
    return _GlassCard(
      width: 500,
      borderColor: const Color(0xFFEF4444),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lock icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.15),
              ),
              child: Icon(
                LucideIcons.keyRound,
                size: 40,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Subscription Required',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Your farm\'s free trial has ended or your subscription has expired. '
            'Upgrade to Standard or Premium to restore access for all devices on your farm.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _openUpgradePage,
              icon: const Icon(LucideIcons.externalLink, size: 18),
              label: const Text(
                'Upgrade Now',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _checkAgain,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF22C55E),
                      ),
                    )
                  : const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(
                _isLoading ? 'Checking...' : 'I Just Paid - Check Again',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF22C55E),
                side: BorderSide(
                  color: const Color(0xFF22C55E).withOpacity(0.7),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Pay on the web or contact your administrator for in-person payment assistance.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.42),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets (mirrors welcome_onboarding_screen.dart style)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final Color? borderColor;

  const _GlassCard({required this.child, this.width = 480, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color:
                  borderColor?.withOpacity(0.35) ??
                  Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
