import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';

import 'data/local_db.dart';
import 'data/sync_engine.dart';
import 'screens/lockout_screen.dart';
import 'screens/offline_terminal_login_screen.dart';
import 'screens/welcome_onboarding_screen.dart';
import 'theme/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/hatchlog_api_client.dart';
import 'services/license_service.dart';

/// Secure storage implementation for Supabase Auth.
class SecureLocalStorage extends LocalStorage {
  final storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async =>
      await storage.read(key: 'supabase_access_token');

  @override
  Future<bool> hasAccessToken() async =>
      await storage.containsKey(key: 'supabase_access_token');

  @override
  Future<void> persistSession(String persistSessionString) async {
    await storage.write(
      key: 'supabase_access_token',
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await storage.delete(key: 'supabase_access_token');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register deep link protocol for Windows (poultry-pms://)
  if (Platform.isWindows) {
    _registerProtocol('poultry-pms');
  }

  // Handle deep links (OAuth redirects)
  final appLinks = AppLinks();

  // Desktop Window config
  await windowManager.ensureInitialized();
  const WindowOptions windowOptions = WindowOptions(
    size: Size(1280, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Agri-ERP Desktop',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(800, 600));
    await windowManager.show();
    await windowManager.focus();
  });

  // DB init
  final database = AppDatabase();

  // Load env
  try {
    await dotenv.load(fileName: '.env');
    debugPrint(
      'dotenv loaded. SUPABASE_URL=${dotenv.env['SUPABASE_URL'] != null}',
    );
  } catch (e) {
    debugPrint('No .env found, proceeding with defaults or placeholders. $e');
  }

  // Supabase Init with Secure Storage
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://PLACEHOLDER.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'PLACEHOLDER',
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );

  // 1. Handle OAuth links when app is already running.
  appLinks.uriLinkStream.listen(
    (uri) async {
      debugPrint('Received deep link (stream): $uri');
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('Session successfully retrieved from URL');
      } catch (e) {
        debugPrint('Error getting session from URL: $e');
      }
    },
    onError: (error, stackTrace) {
      debugPrint('Deep link stream error: $error');
    },
  );

  // 2. Handle the OAuth link that opened the app.
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    debugPrint('Received initial deep link: $initialUri');
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
    } catch (e) {
      debugPrint('Error getting session from initial URL: $e');
    }
  }

  final syncEngine = SyncEngine(database, hatchlogApi: HatchlogApiClient());
  await UserSession().hydrateFromPrefs();

  // Start handoff watcher for Windows
  if (Platform.isWindows) {
    _startHandoffWatcher();
  }

  final themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider<SyncEngine>.value(value: syncEngine),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Poultry PMS Desktop',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      // LicenseGate routes all boot states, including wiped/empty DB.
      home: const LicenseGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// License Gate – boot-time router
// ─────────────────────────────────────────────────────────────────────────────

/// Runs [LicenseService.checkLicense] once on startup and directs the user
/// to the correct screen:
///
/// - [LicenseStatus.firstLaunch]   → [WelcomeOnboardingScreen]
/// - [LicenseStatus.valid]         → [OfflineTerminalLoginScreen]
/// - [LicenseStatus.softLocked]    → [OfflineTerminalLoginScreen] with banner
/// - [LicenseStatus.hardLocked]    → [LockoutScreen] (trial-expired variant)
/// - [LicenseStatus.clockTampered] → [LockoutScreen] (clock-tamper variant)
class LicenseGate extends StatefulWidget {
  const LicenseGate({super.key});

  @override
  State<LicenseGate> createState() => _LicenseGateState();
}

class _LicenseGateState extends State<LicenseGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    if (!mounted) return;

    final db = context.read<AppDatabase>();
    final svc = LicenseService(db);

    LicenseStatus status;
    try {
      status = await svc.checkLicense();
    } catch (e) {
      debugPrint('[LicenseGate] checkLicense error: $e');
      // Fail-open: route to onboarding so the user can establish a clean slate.
      status = LicenseStatus.firstLaunch;
    }

    if (!mounted) return;

    switch (status) {
      case LicenseStatus.firstLaunch:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeOnboardingScreen()),
        );

      case LicenseStatus.valid:
        final hardwareId = await _hardwareIdForRenewal(svc);
        if (!mounted) return;
        if (hardwareId != null) _silentRenew(hardwareId);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
        );

      case LicenseStatus.softLocked:
        final hardwareId = await _hardwareIdForRenewal(svc);
        if (!mounted) return;
        if (hardwareId != null) _silentRenew(hardwareId);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const OfflineTerminalLoginScreen(showSoftLockBanner: true),
          ),
        );

      case LicenseStatus.hardLocked:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const LockoutScreen(reason: LockoutReason.trialExpired),
          ),
        );

      case LicenseStatus.clockTampered:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                const LockoutScreen(reason: LockoutReason.clockTampered),
          ),
        );
    }
  }

  Future<String?> _hardwareIdForRenewal(LicenseService svc) async {
    try {
      final config = await svc.getConfig();
      final hw = config?.hardwareId;
      return hw != null && hw.isNotEmpty ? hw : null;
    } catch (_) {
      return null;
    }
  }

  void _silentRenew(String hardwareId) {
    LicenseService(context.read<AppDatabase>())
        .renewFromCloud(hardwareId)
        .catchError((e) => debugPrint('[LicenseGate] Silent renew failed: $e'));
  }

  @override
  Widget build(BuildContext context) {
    // Minimal branded splash while async check runs
    return const Scaffold(
      backgroundColor: Color(0xFF0A1628),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 56, color: Color(0xFF22C55E)),
            SizedBox(height: 20),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Watches for a handoff file written by another app instance (Windows only).
void _startHandoffWatcher() {
  final localAppData = Platform.environment['LOCALAPPDATA'];
  if (localAppData == null) return;

  final handoffFile = File('$localAppData\\poultry_pms_handoff.txt');

  Stream.periodic(const Duration(milliseconds: 500)).listen((_) async {
    if (await handoffFile.exists()) {
      try {
        final content = await handoffFile.readAsString();
        debugPrint('Handoff received: $content');
        await handoffFile.delete();
        final uri = Uri.parse(content.trim());
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('Session successfully retrieved via handoff');
      } catch (e) {
        debugPrint('Error processing handoff: $e');
      }
    }
  });
}

/// Registers a custom URI scheme on Windows via reg.exe.
void _registerProtocol(String scheme) {
  final String path = Platform.resolvedExecutable;
  try {
    Process.runSync('reg', [
      'add',
      'HKCU\\Software\\Classes\\$scheme',
      '/ve',
      '/t',
      'REG_SZ',
      '/d',
      'URL:$scheme Protocol',
      '/f',
    ]);
    Process.runSync('reg', [
      'add',
      'HKCU\\Software\\Classes\\$scheme',
      '/v',
      'URL Protocol',
      '/t',
      'REG_SZ',
      '/d',
      '',
      '/f',
    ]);
    Process.runSync('reg', [
      'add',
      'HKCU\\Software\\Classes\\$scheme\\shell\\open\\command',
      '/ve',
      '/t',
      'REG_SZ',
      '/d',
      '"$path" "%1"',
      '/f',
    ]);
    debugPrint('Successfully registered $scheme:// protocol via reg.exe');
  } catch (e) {
    debugPrint('Failed to register protocol: $e');
  }
}
