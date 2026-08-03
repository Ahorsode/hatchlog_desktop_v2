# Agent Prompt — Desktop App (pfm-desktop)

## What You Are Building

You are replacing the activation-key-based licensing system with a subscription-
aware license system. The desktop no longer uses activation keys, Farm IDs for
key entry, or grace periods. Instead:
- On first login, the desktop calls a Supabase RPC to register a 30-day trial.
- On every boot and every 6 hours while running, it calls a Supabase RPC to
  check current subscription status.
- After trial expires: 5-day soft lock (app works but shows a banner), then hard
  lock (full lockout screen).
- 10-day offline tolerance: if the desktop cannot reach Supabase for up to 10
  days, it does not lock out a paying user who just happens to be offline.
- Hard lockout screen tells the user to upgrade on the web. No grace period form.
  No login form. Two buttons only: "Upgrade Now" (opens browser) and
  "I Just Paid — Check Again" (re-queries Supabase immediately).

---

## PART 1 — DELETE THESE FILES ENTIRELY

```
lib/services/activation_service.dart
lib/screens/device_setup_screen.dart
```

After deleting, search the entire `lib/` directory for any `import` that
references either of these files and remove those import lines.

---

## PART 2 — UPDATE `lib/data/local_db.dart`

The `license_configs` table needs one new column: `last_cloud_check_at`.

### Step A — Add the column to the Drift table class

Find the `LicenseConfigs` table class in `local_db.dart`. Add:

```dart
// Timestamp of the last successful cloud subscription check.
// Used for the 10-day offline tolerance window.
// Null means never successfully checked.
DateTimeColumn get lastCloudCheckAt =>
    dateTime().named('last_cloud_check_at').nullable()();
```

### Step B — Increment the schema version and add a migration step

Find the `AppDatabase` class where `schemaVersion` is defined. Increment it by 1.

In the `MigrationStrategy` `onUpgrade` callback, add a new case for the new
version number:

```dart
await m.addColumn(licenseConfigs, licenseConfigs.lastCloudCheckAt);
```

Do not change any other migration steps. Only add this one new step at the end.

---

## PART 3 — REWRITE `lib/services/license_service.dart`

This is the most important file. Rewrite it completely from scratch.
Keep the import block, keep all the farm-id cascade migration methods
(`remapFarmIdReferences`, `reconcileToCloudFarmId`, `mergeLocalFarmIntoCloud`,
`runFarmIdCascade`), keep `touchLastUsed()`, keep `getConfig()`, and keep all
the private helpers (`_loadConfig`, `_upsertConfig`, `_setMode`).

Replace everything else as described below.

### New `LicenseStatus` enum

```dart
enum LicenseStatus {
  /// First ever launch — no install record found.
  firstLaunch,

  /// License is valid (trial or active paid subscription).
  valid,

  /// Subscription expired, within the 5-day soft-lock window.
  /// App still fully works but shows a prominent banner.
  softLocked,

  /// Subscription expired by more than 5 days AND offline tolerance
  /// window (10 days since last cloud check) is also exhausted.
  /// Shows full lockout screen, app is not accessible.
  hardLocked,

  /// System clock was rolled back past last_used — fraud lockdown.
  clockTampered,
}
```

Remove the old `gracePeriod` and `expired` values entirely.

### New `checkLicense()` method

Replace the existing `checkLicense()` with this logic:

```dart
Future<LicenseStatus> checkLicense() async {
  final config = await _loadConfig();
  if (config == null) return LicenseStatus.firstLaunch;

  final now = DateTime.now();

  // ── Anti-clock-tamper ──────────────────────────────────────────────
  if (now.isBefore(config.lastUsed.subtract(const Duration(minutes: 2)))) {
    debugPrint('[License] CLOCK TAMPER: now=$now lastUsed=${config.lastUsed}');
    return LicenseStatus.clockTampered;
  }

  // ── Still within subscription period → VALID ───────────────────────
  if (now.isBefore(config.expiresAt)) {
    return LicenseStatus.valid;
  }

  // ── Past expires_at: check offline tolerance first ──────────────────
  // If we successfully checked the cloud within the last 10 days,
  // the user might have renewed on the web and we just can't reach the
  // server right now. Stay valid to avoid locking out paying customers
  // who are temporarily offline.
  final lastCheck = config.lastCloudCheckAt;
  if (lastCheck != null) {
    final daysSinceCheck = now.difference(lastCheck).inDays;
    if (daysSinceCheck < 10) {
      // Still within offline tolerance window
      return LicenseStatus.valid;
    }
  }

  // ── Offline tolerance exhausted: apply soft/hard lock ──────────────
  final daysPastExpiry = now.difference(config.expiresAt).inDays;

  if (daysPastExpiry <= 5) {
    return LicenseStatus.softLocked;
  }

  await _setMode('HARD_LOCKED');
  return LicenseStatus.hardLocked;
}
```

### New `initTrialFromCloud()` method

This replaces `initCloudLicense()` and `initCloudLicenseFromActivation()`.
Call this after successful Supabase authentication (both Google and email/password).

```dart
/// Registers this device on Supabase via RPC and persists a 30-day
/// CLOUD_TRIAL license locally. Idempotent — safe to call again if the
/// device is already registered.
///
/// Returns null on success, or an error string.
Future<String?> initTrialFromCloud({
  required String userId,
  required String farmId,
  required String hardwareId,
}) async {
  try {
    final result = await Supabase.instance.client.rpc(
      'register_device_trial',
      params: {
        'p_user_id':     userId,
        'p_farm_id':     farmId,
        'p_hardware_id': hardwareId,
        'p_device_name': 'Flutter Desktop',
        'p_device_type': 'Desktop',
      },
    );

    if (result == null) {
      return 'Trial registration returned no data.';
    }

    final data = result as Map<String, dynamic>;

    if (data['success'] != true) {
      return data['error']?.toString() ?? 'Trial registration failed.';
    }

    final rawExpiry = data['license_expires_at'];
    final expiresAt = rawExpiry != null
        ? DateTime.tryParse(rawExpiry.toString()) ?? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    await _upsertConfig(
      mode: 'CLOUD_TRIAL',
      farmId: farmId,
      userId: userId,
      hardwareId: hardwareId,
      installedAt: DateTime.now(),
      expiresAt: expiresAt,
      lastCloudCheckAt: DateTime.now(),
    );

    debugPrint('[License] Trial registered. Expires: $expiresAt');
    return null; // success
  } catch (e) {
    debugPrint('[License] initTrialFromCloud error: $e');
    // Fallback: grant local 30-day trial so app is not blocked offline
    await _upsertConfig(
      mode: 'CLOUD_TRIAL',
      farmId: farmId,
      userId: userId,
      hardwareId: hardwareId,
      installedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      lastCloudCheckAt: null,
    );
    return null; // still success — allow them in
  }
}
```

### Updated `renewFromCloud()` method

Replace the existing `renewFromCloud()` with this version that:
1. Calls the new `get_device_subscription_status` RPC instead of a bare table query.
2. Stamps `last_cloud_check_at` on every successful cloud check.
3. Syncs BOTH `expires_at` AND `status` from the server.

```dart
/// Called on every boot (when online) and every 6 hours while the app runs.
/// Fetches current subscription status from Supabase and syncs locally.
/// Stamps last_cloud_check_at on every successful contact with the server.
Future<void> renewFromCloud(String hardwareId) async {
  try {
    final result = await Supabase.instance.client.rpc(
      'get_device_subscription_status',
      params: {'p_hardware_id': hardwareId},
    );

    if (result == null) return;

    final data = result as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('[License] Status check failed: ${data['error']}');
      return;
    }

    final rawExpiry    = data['license_expires_at'];
    final statusStr    = data['license_status']?.toString();
    final serverExpiry = rawExpiry != null
        ? DateTime.tryParse(rawExpiry.toString())
        : null;

    final now    = DateTime.now();
    final config = await _loadConfig();
    if (config == null) return;

    // Build the update — always stamp lastCloudCheckAt
    LicenseConfigsCompanion update = LicenseConfigsCompanion(
      lastUsed:         Value(now),
      lastCloudCheckAt: Value(now),
    );

    // Only update expiry if server has a later date
    if (serverExpiry != null && serverExpiry.isAfter(config.expiresAt)) {
      update = update.copyWith(expiresAt: Value(serverExpiry));
      debugPrint('[License] Renewed expiry to $serverExpiry from cloud.');
    }

    // Sync status mode from server
    if (statusStr != null) {
      final localMode = _serverStatusToLocalMode(statusStr);
      update = update.copyWith(mode: Value(localMode));
    }

    await (_db.update(_db.licenseConfigs)
          ..where((t) => t.id.equals('singleton')))
        .write(update);
  } catch (e) {
    debugPrint('[License] Cloud renewal skipped (offline?): $e');
    // Do NOT update lastCloudCheckAt on failure — only stamp on success
  }
}

String _serverStatusToLocalMode(String serverStatus) {
  switch (serverStatus) {
    case 'ACTIVE':
      return 'CLOUD_ACTIVE';
    case 'CLOUD_TRIAL':
      return 'CLOUD_TRIAL';
    case 'EXPIRED':
      return 'EXPIRED';
    default:
      return 'CLOUD_TRIAL';
  }
}
```

### Remove these methods entirely

Delete the following methods from `LicenseService`. Do not keep them.
Remove their complete implementations and any helper methods only used by them.

- `initCloudLicense()` — replaced by `initTrialFromCloud()`
- `initOfflineLicense()` — no longer used (offline mode removed)
- `initCloudLicenseFromActivation()` — activation keys are removed
- `applyGracePeriod()` — grace period concept removed
- `linkCloudAccount()` — replaced by `initTrialFromCloud()` on re-login
- `fetchSupabaseFarmAndUser()` — only used by deleted methods
- `registerDeviceOnSupabase()` — only used by deleted methods

### Update `_upsertConfig()` private helper

Add `lastCloudCheckAt` as a nullable parameter:

```dart
Future<void> _upsertConfig({
  required String mode,
  required String? farmId,
  required String? userId,
  required String? hardwareId,
  required DateTime installedAt,
  required DateTime expiresAt,
  DateTime? lastCloudCheckAt,   // ← ADD THIS
}) async {
  final now = DateTime.now();
  await _db
      .into(_db.licenseConfigs)
      .insertOnConflictUpdate(
        LicenseConfigsCompanion.insert(
          id:               'singleton',
          mode:             Value(mode),
          farmId:           Value(farmId),
          userId:           Value(userId),
          hardwareId:       Value(hardwareId),
          installedAt:      Value(installedAt),
          expiresAt:        expiresAt,
          lastUsed:         Value(now),
          lastCloudCheckAt: Value(lastCloudCheckAt),   // ← ADD THIS
        ),
      );
}
```

---

## PART 4 — REWRITE `lib/screens/lockout_screen.dart`

Rewrite the entire screen. Keep:
- The `LockoutReason` enum (only `trialExpired` and `clockTampered`)
- The class structure and glass-card aesthetic (same visual style)
- The clock-tamper variant (`_buildClockTamperVariant()`) — no changes needed
- `_retryClockCheck()` — keep exactly as-is

Remove entirely:
- `_emailCtrl`, `_passwordCtrl` text controllers
- `_obscurePassword` state variable
- `_rescued` state variable
- `_applyGracePeriod()` method
- `_buildSuccessState()` method
- `_GlassTextField` widget class
- All grace period messaging and the "10-Day Grace Period" badge

### New `_buildTrialExpiredVariant()` for the `trialExpired` reason:

The new variant has no login form. It has:

**Top section (same glass card style as existing):**
- Red lock icon (keep existing icon style)
- Title: `"Subscription Required"`
- Subtitle: `"Your free trial or subscription has expired. Upgrade your plan to continue accessing your farm data."`

**Two action buttons:**

Button 1 — "Upgrade Now" (primary, green):
```dart
// Opens the web app upgrade page in the system browser
// Use url_launcher package: launchUrl(Uri.parse(upgradeUrl))
// upgradeUrl = dotenv.env['WEB_APP_URL'] + '/dashboard/license-upgrade'
// If WEB_APP_URL is not set, fall back to a placeholder URL
```

Button 2 — "I Just Paid — Check Again" (secondary, outlined):
```dart
// Calls renewFromCloud(hardwareId) then re-runs checkLicense()
// If status comes back as valid or softLocked → navigate to OfflineTerminalLoginScreen
// If still hardLocked → show error message: "Still showing as expired.
// It may take a few minutes for payment to process. Please try again shortly."
// Show a loading spinner while checking
```

Add `url_launcher` to `pubspec.yaml` dependencies if not already present.

**Footer text:**
`"Pay on the web or contact your administrator for in-person payment assistance."`

---

## PART 5 — REWRITE `lib/screens/welcome_onboarding_screen.dart`

### Step A — Remove the web key ingestion step entirely

Remove from the enum `_OnboardingStep`:
- `webKeyIngestion`

Remove from the enum `WelcomeOnboardingEntry`:
- `webKeyIngestion`

Remove from `_WelcomeOnboardingScreenState`:
- `_farmIdCtrl` — TextEditingController and its `dispose()` call
- `_activationKeyCtrl` — TextEditingController and its `dispose()` call
- `_mapEntryToStep` case for `webKeyIngestion`

Remove entirely these methods (and all their UI helper sub-methods):
- `_buildWebKeyIngestionPanel()` (and any `_buildActivationKeyStep()` variant)
- `_verifyAndStartSync()` (the method that called `ActivationService`)

Remove the `import '../services/activation_service.dart';` line from the top.

Remove the "I have a web activation key" link/button from the registration panel
that previously navigated to `webKeyIngestion` step.

### Step B — Call `initTrialFromCloud()` after successful login/registration

Find the two places where successful Supabase authentication completes:

1. **After `_completeGoogleRegistration()`** — when Google OAuth sign-in
   completes and the user's farm is confirmed.

2. **After `_completeDesktopRegistration()`** (or whatever the email/password
   registration completion method is called) — when Supabase sign-in succeeds
   and the farm row is confirmed.

In BOTH places, after you have `userId` and `farmId` confirmed, add this call
BEFORE navigating to the next screen:

```dart
final hardwareId = await getDeviceHardwareId();
final licSvc = LicenseService(context.read<AppDatabase>());
final licErr = await licSvc.initTrialFromCloud(
  userId:     userId,
  farmId:     farmId,
  hardwareId: hardwareId,
);
if (licErr != null) {
  // Log but do NOT block the user — initTrialFromCloud has an offline fallback
  debugPrint('[Onboarding] Trial init warning: $licErr');
}
```

### Step C — Remove `offlineLocalSetup` step

Remove from `_OnboardingStep`: `offlineLocalSetup`
Remove from `WelcomeOnboardingEntry`: `offlineLocalSetup`
Remove `_mapEntryToStep` case for `offlineLocalSetup`
Remove `_buildOfflineLocalSetupPanel()` method if it exists
Remove `initOfflineLicense()` call sites

The desktop is now cloud-only. All users sign in with their web account.

---

## PART 6 — UPDATE `lib/main.dart` — LicenseGate Routing

Find the `LicenseGate` widget (or the equivalent `FutureBuilder`/`switch` that
routes based on `LicenseStatus`). Update it to handle the new status values.

### New routing table:

```dart
switch (status) {
  case LicenseStatus.firstLaunch:
    // No local record → show onboarding
    return WelcomeOnboardingScreen();

  case LicenseStatus.valid:
    // Normal access → try renewFromCloud silently, then show login
    _silentRenew(hardwareId);     // fire-and-forget, see below
    return OfflineTerminalLoginScreen();

  case LicenseStatus.softLocked:
    // App works but show a banner — route to login screen WITH soft-lock flag
    _silentRenew(hardwareId);
    return OfflineTerminalLoginScreen(showSoftLockBanner: true);

  case LicenseStatus.hardLocked:
    // Full lockout
    return LockoutScreen(reason: LockoutReason.trialExpired);

  case LicenseStatus.clockTampered:
    return LockoutScreen(reason: LockoutReason.clockTampered);
}
```

Add the `_silentRenew` helper as a fire-and-forget function in `LicenseGate`:

```dart
void _silentRenew(String hardwareId) {
  LicenseService(database).renewFromCloud(hardwareId).catchError(
    (e) => debugPrint('[LicenseGate] Silent renew failed: $e'),
  );
}
```

Remove routing for the old `gracePeriod` and `expired` status values.

---

## PART 7 — ADD SOFT LOCK BANNER

### Step A — Update `OfflineTerminalLoginScreen` to accept the flag

Add an optional constructor parameter to `OfflineTerminalLoginScreen`:

```dart
final bool showSoftLockBanner;
const OfflineTerminalLoginScreen({super.key, this.showSoftLockBanner = false});
```

### Step B — Show the banner in the screen's build method

At the top of the screen's scaffold (above the login form, below the AppBar),
conditionally show a banner when `showSoftLockBanner` is true:

```dart
if (widget.showSoftLockBanner)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: const Color(0xFFEF4444).withOpacity(0.15),
    child: Row(
      children: [
        const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFEF4444)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your subscription has expired. You have up to 5 days of continued access. '
            'Upgrade your plan to avoid losing access.',
            style: const TextStyle(
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
              await launchUrl(Uri.parse('$url/dashboard/license-upgrade'));
            }
          },
          child: const Text(
            'Upgrade Now',
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  ),
```

---

## PART 8 — ADD BACKGROUND SUBSCRIPTION CHECK

Find the main scaffold or root widget that is shown AFTER login (the persistent
scaffold that wraps all dashboard screens, likely `RoleDashboardRouter` or
`MainScaffold`).

Add a `Timer.periodic` that fires every 6 hours while the app is running:

```dart
@override
void initState() {
  super.initState();
  // ... existing initState code ...

  // Background subscription check every 6 hours
  _subscriptionCheckTimer = Timer.periodic(
    const Duration(hours: 6),
    (_) => _checkSubscriptionInBackground(),
  );
}

Timer? _subscriptionCheckTimer;

Future<void> _checkSubscriptionInBackground() async {
  try {
    final config = await LicenseService(
      context.read<AppDatabase>(),
    ).getConfig();
    if (config?.hardwareId == null) return;

    await LicenseService(context.read<AppDatabase>())
        .renewFromCloud(config!.hardwareId!);

    final status = await LicenseService(
      context.read<AppDatabase>(),
    ).checkLicense();

    if (!mounted) return;

    if (status == LicenseStatus.hardLocked) {
      // Push to lockout screen, replacing current route
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LockoutScreen(reason: LockoutReason.trialExpired),
        ),
        (_) => false,
      );
    } else if (status == LicenseStatus.softLocked) {
      // Show a non-intrusive snackbar warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Subscription expiring soon. Upgrade to keep access.',
          ),
          backgroundColor: const Color(0xFFEF4444),
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () async {
              final url = dotenv.env['WEB_APP_URL'] ?? '';
              if (url.isNotEmpty) {
                await launchUrl(Uri.parse('$url/dashboard/license-upgrade'));
              }
            },
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  } catch (e) {
    debugPrint('[Background] Subscription check failed: $e');
  }
}

@override
void dispose() {
  _subscriptionCheckTimer?.cancel();
  // ... existing dispose code ...
  super.dispose();
}
```

---

## PART 9 — ADD `WEB_APP_URL` TO `.env`

Open the `.env` file (or `.env.example` if `.env` is not in the repo).
Add:

```
WEB_APP_URL=https://your-app-domain.com
```

The agent filling in the real URL is a placeholder — the actual value will be
set by the team when deploying. Ensure the app reads it with:
```dart
dotenv.env['WEB_APP_URL'] ?? ''
```
Do not hardcode the URL anywhere in Dart files.

---

## PART 10 — `pubspec.yaml` DEPENDENCIES

Ensure these packages are present. Add any that are missing:

```yaml
dependencies:
  url_launcher: ^6.2.0   # For opening browser to upgrade page
```

Run `flutter pub get` after updating `pubspec.yaml`.

---

## PART 11 — CLEANUP CHECKLIST

Before finishing, verify each of these:

- [ ] `lib/services/activation_service.dart` does not exist
- [ ] `lib/screens/device_setup_screen.dart` does not exist
- [ ] Zero imports of `activation_service.dart` anywhere in `lib/`
- [ ] Zero imports of `device_setup_screen.dart` anywhere in `lib/`
- [ ] `LicenseStatus` enum has exactly: `firstLaunch`, `valid`, `softLocked`,
      `hardLocked`, `clockTampered` — no other values
- [ ] `LicenseService` has zero references to `gracePeriod`, `applyGracePeriod`,
      `initOfflineLicense`, `linkCloudAccount`, `initCloudLicenseFromActivation`
- [ ] `WelcomeOnboardingScreen` has no `webKeyIngestion` step, no
      `_farmIdCtrl`, no `_activationKeyCtrl`
- [ ] `LockoutScreen` `trialExpired` variant has no login form, no email/password
      fields, no grace period badge
- [ ] `OfflineTerminalLoginScreen` accepts and shows `showSoftLockBanner`
- [ ] `renewFromCloud()` stamps `lastCloudCheckAt` on successful cloud contact
- [ ] `initTrialFromCloud()` is called after both Google and email/password login
- [ ] `main.dart` LicenseGate routes `softLocked` to login screen with banner,
      `hardLocked` to lockout screen
- [ ] Background 6-hour timer is added to the main post-login scaffold
- [ ] `url_launcher` is in `pubspec.yaml`
- [ ] `.env` has `WEB_APP_URL` key
- [ ] `flutter pub get` runs without errors
- [ ] `flutter analyze` runs with no new errors introduced by these changes

---

## WHAT TO LEAVE ALONE

Do not touch any of these:
- All farm-id cascade migration methods in `LicenseService`
  (`remapFarmIdReferences`, `reconcileToCloudFarmId`,
  `mergeLocalFarmIntoCloud`, `runFarmIdCascade`)
- `touchLastUsed()` method
- Clock tamper detection logic in `checkLicense()`
- `_buildClockTamperVariant()` in `LockoutScreen`
- The Supabase initialization in `main.dart`
- `SecureLocalStorage` class in `main.dart`
- Deep link / OAuth redirect handling in `main.dart`
- `SyncEngine` and all sync logic
- All screen files not mentioned in this prompt
- `lib/data/local_db.g.dart` — this is generated; run `dart run build_runner build`
  after changes to `local_db.dart` to regenerate it
