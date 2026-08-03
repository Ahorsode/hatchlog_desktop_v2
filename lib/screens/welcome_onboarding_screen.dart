import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/desktop_registration_service.dart';
import '../services/license_service.dart';
import '../utils/id_utils.dart';
import 'lockout_screen.dart';
import 'role_dashboard_router.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  final WelcomeOnboardingEntry entry;

  const WelcomeOnboardingScreen({
    super.key,
    this.entry = WelcomeOnboardingEntry.choice,
  });

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

enum _OnboardingStep { desktopRegistration, choice }

enum WelcomeOnboardingEntry { choice }

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late _OnboardingStep _step;

  final _regFarmNameCtrl = TextEditingController();
  final _regOwnerPhoneCtrl = TextEditingController();
  final _regAdminEmailCtrl = TextEditingController();
  final _regMasterPasswordCtrl = TextEditingController();

  bool _obscureMasterPassword = true;
  bool _isLoading = false;
  bool _googleAuthPending = false;
  bool _handlingGoogleRegistration = false;
  String? _error;
  String? _message;
  late final DesktopRegistrationService _desktopRegistrationService;
  StreamSubscription<AuthState>? _authSubscription;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _step = _mapEntryToStep(widget.entry);
    _desktopRegistrationService = DesktopRegistrationService();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!_googleAuthPending) return;
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          unawaited(_completeGoogleRegistration());
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
        (_) => _completeGoogleRegistration(),
      );
    }
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  _OnboardingStep _mapEntryToStep(WelcomeOnboardingEntry entry) {
    switch (entry) {
      case WelcomeOnboardingEntry.choice:
        return _OnboardingStep.desktopRegistration;
    }
  }

  bool _isGoogleAuthUser(dynamic user) {
    if (user == null) return false;
    final metadata = user.appMetadata;
    if (metadata is! Map) return false;
    return metadata['provider']?.toString().toLowerCase() == 'google';
  }

  @override
  void dispose() {
    _regFarmNameCtrl.dispose();
    _regOwnerPhoneCtrl.dispose();
    _regAdminEmailCtrl.dispose();
    _regMasterPasswordCtrl.dispose();
    _authSubscription?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _navigate(_OnboardingStep next, {String? message}) {
    setState(() {
      _step = next;
      _error = null;
      _message = message;
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }

  Future<void> _startGoogleRegistration() async {
    setState(() {
      _isLoading = true;
      _googleAuthPending = true;
      _error = null;
      _message = null;
    });

    try {
      await _desktopRegistrationService.startGoogleRegistration();
      if (!mounted) return;
      setState(
        () => _message =
            'Complete Google sign-in in your browser, then return to HatchLog.',
      );
    } catch (e) {
      setState(() {
        _googleAuthPending = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeGoogleRegistration() async {
    if (_handlingGoogleRegistration || !mounted) return;
    _handlingGoogleRegistration = true;
    setState(() {
      _isLoading = true;
      _error = null;
      _message = 'Finalizing Google registration...';
    });

    try {
      final db = context.read<AppDatabase>();
      final syncEngine = context.read<SyncEngine>();
      final result = await _desktopRegistrationService
          .completeGoogleRegistration(db: db);
      final licenseReady = await _initTrialForRegistration(
        userId: result.userId,
        farmId: result.farmId,
        db: db,
      );
      if (!licenseReady) return;
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
      _handlingGoogleRegistration = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitTraditionalRegistration() async {
    final farmName = _regFarmNameCtrl.text.trim();
    final phone = _regOwnerPhoneCtrl.text.trim();
    final email = _regAdminEmailCtrl.text.trim();
    final password = _regMasterPasswordCtrl.text;

    if (farmName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setState(() => _error = 'All registration fields are required.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid admin email address.');
      return;
    }
    if (password.length < 8) {
      setState(
        () => _error = 'Create a master password with at least 8 characters.',
      );
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
      final result = await _desktopRegistrationService.registerTraditional(
        db: db,
        farmName: farmName,
        ownerPhoneNumber: phone,
        adminEmail: email,
        masterPassword: password,
      );
      final licenseReady = await _initTrialForRegistration(
        userId: result.userId,
        farmId: result.farmId,
        db: db,
      );
      if (!licenseReady) return;
      if (!mounted) return;
      syncEngine.startPeriodicSync();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoleDashboardRouter(role: result.role),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _initTrialForRegistration({
    required String userId,
    required String farmId,
    required AppDatabase db,
  }) async {
    final hardwareId = await getDeviceHardwareId();
    final licSvc = LicenseService(db);
    final licErr = await licSvc.initTrialFromCloud(
      userId: userId,
      farmId: farmId,
      hardwareId: hardwareId,
    );

    if (licErr == 'TRIAL_EXHAUSTED') {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                const LockoutScreen(reason: LockoutReason.trialExpired),
          ),
          (_) => false,
        );
      }
      return false;
    }

    if (licErr != null) {
      debugPrint('[Onboarding] Trial init warning: $licErr');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A1628), Color(0xFF0D2137)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF16A34A).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(opacity: _fade, child: _buildStep()),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      _OnboardingStep.desktopRegistration => _buildDesktopRegistrationPanel(),
      _OnboardingStep.choice => _buildChoicePanel(),
    };
  }

  Widget _buildDesktopRegistrationPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: _GlassCard(
        width: 1040,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.agriculture, size: 42, color: Color(0xFF22C55E)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register HatchLog Desktop',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose Google sign-up or create native farm credentials.',
                        style: TextStyle(color: Color(0xFFB6C2D1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (_message != null) ...[
              _InfoBanner(message: _message!),
              const SizedBox(height: 14),
            ],
            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              const SizedBox(height: 14),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 860;
                final googlePanel = _RegistrationRoutePanel(
                  icon: LucideIcons.chrome,
                  title: 'Continue with Google',
                  subtitle:
                      'Use Google OAuth for cloud identity, then set a local fallback credential if this is a new HatchLog account.',
                  accent: const Color(0xFF38BDF8),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _startGoogleRegistration,
                        icon: _isLoading && _googleAuthPending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.chrome, size: 18),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                final traditionalPanel = _RegistrationRoutePanel(
                  icon: LucideIcons.keyRound,
                  title: 'Traditional Registration',
                  subtitle:
                      'Create a Supabase account and use this exact password as the workstation master key for offline access.',
                  accent: const Color(0xFF22C55E),
                  children: [
                    _GlassTextField(
                      controller: _regFarmNameCtrl,
                      label: 'Farm Name',
                      hint: 'e.g. Sunrise Layers Farm',
                      icon: LucideIcons.warehouse,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regOwnerPhoneCtrl,
                      label: 'Owner Phone Number',
                      hint: '+233 ...',
                      icon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regAdminEmailCtrl,
                      label: 'Admin Email',
                      hint: 'owner@example.com',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _GlassTextField(
                      controller: _regMasterPasswordCtrl,
                      label: 'Create Master Password',
                      hint: 'At least 8 characters',
                      icon: LucideIcons.lock,
                      obscureText: _obscureMasterPassword,
                      onSubmitted: (_) => _submitTraditionalRegistration(),
                      suffix: IconButton(
                        tooltip: _obscureMasterPassword ? 'Show' : 'Hide',
                        icon: Icon(
                          _obscureMasterPassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 18,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => setState(
                          () =>
                              _obscureMasterPassword = !_obscureMasterPassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PrimaryButton(
                      label: 'Register Account',
                      icon: LucideIcons.userPlus,
                      color: const Color(0xFF22C55E),
                      isLoading: _isLoading && !_googleAuthPending,
                      onPressed: _submitTraditionalRegistration,
                    ),
                  ],
                );

                if (narrow) {
                  return Column(
                    children: [
                      googlePanel,
                      const SizedBox(height: 16),
                      traditionalPanel,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: googlePanel),
                    const SizedBox(width: 18),
                    Expanded(child: traditionalPanel),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicePanel() {
    return SizedBox(
      width: 860,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.agriculture, size: 56, color: Color(0xFF22C55E)),
          const SizedBox(height: 16),
          const Text(
            'Welcome to HatchLog Desktop',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the path that matches your setup.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 42),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.cloud,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Use Web Account',
                  subtitle:
                      'Sign in or register with your HatchLog cloud account to start your desktop trial.',
                  badge: 'CLOUD ACCOUNT',
                  badgeColor: const Color(0xFF38BDF8),
                  buttonLabel: 'Continue',
                  buttonColor: const Color(0xFF38BDF8),
                  onPressed: () =>
                      _navigate(_OnboardingStep.desktopRegistration),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _OptionCard(
                  icon: LucideIcons.userPlus,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Create Account',
                  subtitle:
                      'Create your farm account on the cloud, then continue into HatchLog Desktop.',
                  badge: 'NEW ACCOUNT',
                  badgeColor: const Color(0xFF22C55E),
                  buttonLabel: 'Register',
                  buttonColor: const Color(0xFF22C55E),
                  onPressed: () =>
                      _navigate(_OnboardingStep.desktopRegistration),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered
              ? Colors.white.withOpacity(0.09)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? widget.iconColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, size: 32, color: widget.iconColor),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.badgeColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: widget.badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.55),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget.buttonLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationRoutePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;

  const _RegistrationRoutePanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.66),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double width;

  const _GlassCard({required this.child, this.width = 480});

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
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onSubmitted,
  });

  static final _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          cursorColor: const Color(0xFF22C55E),
          style: const TextStyle(
            color: Color(0xFFFFFFFD),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, size: 16, color: const Color(0xFFA8B7C8)),
            suffixIcon: suffix,
            border: _fieldBorder,
            enabledBorder: _fieldBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF22C55E),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          isLoading ? 'Please wait...' : label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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

class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.38)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            size: 16,
            color: Color(0xFF38BDF8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
