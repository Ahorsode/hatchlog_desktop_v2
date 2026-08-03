# PROMPT 4 — Desktop App (pfm-desktop) — License System Fix

Paste this whole prompt into Claude Code inside the **pfm-desktop** Flutter repo.

---

```
You are fixing two gaps in the desktop app's licensing system that only become
real problems after the shared backend SQL migration (PROMPT 1) is applied.

CONTEXT YOU MUST READ FIRST:
──────────────────────────────────────────────────────────────────────────────
The backend RPC `register_device_trial` now returns a new error code:
  { "success": false, "error_code": "TRIAL_EXHAUSTED", "error": "..." }

This happens when a NEW device tries to register on a farm that has already
burned its free 30-day trial without paying. The current desktop code in
`lib/services/license_service.dart` handles `success != true` by returning
the error string to the caller. The caller in
`lib/screens/welcome_onboarding_screen.dart` logs it with debugPrint and
DOES NOTHING — no license_configs row is written. This means:

  1. The user finishes onboarding and uses the app for the rest of that session.
  2. On next boot, checkLicense() finds no license_configs row, returns
     LicenseStatus.firstLaunch, and routes to WelcomeOnboardingScreen AGAIN.
  3. The cycle repeats indefinitely — the farm gets unlimited free access.

Additionally, the `_serverStatusToLocalMode` method does not handle the new
status values the backend now returns: 'PAID_STANDARD', 'PAID_PREMIUM',
'REVOKED'. Any of these fall through to the default case, which incorrectly
maps them to 'CLOUD_TRIAL'.

AFFECTED FILES (read each one before editing):
  lib/services/license_service.dart
  lib/screens/welcome_onboarding_screen.dart
  lib/screens/lockout_screen.dart       (copy update only)
  lib/screens/main_scaffold.dart        (renewFromCloud handling)
──────────────────────────────────────────────────────────────────────────────

═══════════════════════════════════════════════════════════════════
FIX 1 — Handle TRIAL_EXHAUSTED in initTrialFromCloud
═══════════════════════════════════════════════════════════════════

FILE: lib/services/license_service.dart

Locate the block at lines 136–138:

  if (data['success'] != true) {
    return data['error']?.toString() ?? 'Trial registration failed.';
  }

Replace it with:

  if (data['success'] != true) {
    final errorCode = data['error_code']?.toString() ?? '';

    if (errorCode == 'TRIAL_EXHAUSTED') {
      // Write a hard-locked row immediately so the boot gate catches it
      // on every subsequent launch, not just the current session.
      // expiresAt 36 days in the past guarantees hardLocked (>5 day threshold)
      // even with the offline tolerance window applied.
      await _upsertConfig(
        mode: 'HARD_LOCKED',
        farmId: farmId,
        userId: userId,
        hardwareId: hardwareId,
        installedAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(days: 36)),
        lastCloudCheckAt: DateTime.now(),
      );
      debugPrint('[License] TRIAL_EXHAUSTED — farm has no remaining trial.');
      return 'TRIAL_EXHAUSTED';
    }

    // All other non-success responses: return the error but do NOT
    // hard-lock locally — these may be transient (network, server error).
    return data['error']?.toString() ?? 'Trial registration failed.';
  }

═══════════════════════════════════════════════════════════════════
FIX 2 — Fix _serverStatusToLocalMode to cover all new status values
═══════════════════════════════════════════════════════════════════

FILE: lib/services/license_service.dart

Locate the `_serverStatusToLocalMode` method (currently lines 228–239).
Replace the entire method body with:

  String _serverStatusToLocalMode(String serverStatus) {
    switch (serverStatus) {
      // Paid tiers — map to CLOUD_ACTIVE so checkLicense() passes
      case 'ACTIVE':
      case 'PAID_STANDARD':
      case 'PAID_PREMIUM':
        return 'CLOUD_ACTIVE';

      case 'CLOUD_TRIAL':
        return 'CLOUD_TRIAL';

      case 'EXPIRED':
      case 'TRIAL_EXPIRED':
        return 'EXPIRED';

      // Revoked by admin — treat same as hard-locked so the gate fires
      case 'REVOKED':
        return 'HARD_LOCKED';

      default:
        // Unknown future status: preserve what we have locally rather
        // than downgrading to CLOUD_TRIAL. Log it so you notice it.
        debugPrint('[License] Unrecognised server status: $serverStatus');
        return 'CLOUD_TRIAL';
    }
  }

═══════════════════════════════════════════════════════════════════
FIX 3 — Handle the TRIAL_EXHAUSTED return in WelcomeOnboardingScreen
═══════════════════════════════════════════════════════════════════

FILE: lib/screens/welcome_onboarding_screen.dart

Locate `_initTrialForRegistration` (currently lines 247–262).
Change the error handling block from:

  if (licErr != null) {
    debugPrint('[Onboarding] Trial init warning: $licErr');
  }

To:

  if (licErr == 'TRIAL_EXHAUSTED') {
    // Do not let the user into the app.
    // Navigate to the lockout screen immediately, replacing onboarding.
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LockoutScreen(reason: LockoutReason.trialExpired),
        ),
        (_) => false,  // clear the whole stack
      );
    }
    return;
  }

  if (licErr != null) {
    debugPrint('[Onboarding] Trial init warning: $licErr');
    // Non-EXHAUSTED errors (transient network issues) — let the user in
    // with a degraded local config. renewFromCloud will fix this later.
  }

Make sure `LockoutScreen` and `LockoutReason` are imported at the top of the file
(add the import if it isn't already there):
  import 'lockout_screen.dart';

═══════════════════════════════════════════════════════════════════
FIX 4 — Handle trial_exhausted flag returned by renewFromCloud
═══════════════════════════════════════════════════════════════════

FILE: lib/services/license_service.dart

The updated `get_device_subscription_status` RPC now returns an extra field:
  'trial_exhausted': bool

Inside `renewFromCloud`, after parsing the response data and before writing
the update companion, add:

  // If the server tells us the trial is exhausted and we're not ACTIVE,
  // force a hard-locked mode locally so checkLicense() blocks access
  // on the next call without waiting for expires_at to lapse.
  final trialExhausted = data['trial_exhausted'] == true;
  final serverMode = statusStr != null ? _serverStatusToLocalMode(statusStr) : null;
  final isActive = serverMode == 'CLOUD_ACTIVE';

  if (trialExhausted && !isActive) {
    await _setMode('HARD_LOCKED');
    debugPrint('[License] Server reports trial exhausted — forcing hard lock.');
    return;  // skip the normal update so we don't accidentally un-lock
  }

This protects against the edge case where a farm reinstalls, the server
correctly returns trial_exhausted: true in the status check, but the local
expires_at hasn't technically crossed the threshold yet.

═══════════════════════════════════════════════════════════════════
FIX 5 — Update lockout body copy to match mobile (consistency)
═══════════════════════════════════════════════════════════════════

FILE: lib/screens/lockout_screen.dart

Locate `_buildTrialExpiredVariant()`, find the body Text widget at
approximately line 322. Change the string from:

  'Your free trial or subscription has expired. Upgrade your plan to
   continue accessing your farm data.'

To (matches the updated mobile copy exactly):

  'Your farm\'s free trial has ended or your subscription has expired. '
  'Upgrade to Standard or Premium to restore access for all devices on your farm.'

This is a copy-only change. No logic or style changes to this file.

═══════════════════════════════════════════════════════════════════
VERIFICATION CHECKLIST
═══════════════════════════════════════════════════════════════════

After applying all fixes, manually verify these scenarios:

[ ] New device, farm has an ACTIVE trial still running
    → initTrialFromCloud returns null, writes CLOUD_TRIAL row with the
      FARM's expiry (not a fresh 30 days), user reaches main scaffold.

[ ] New device, farm's trial is EXHAUSTED (no payment)
    → initTrialFromCloud returns 'TRIAL_EXHAUSTED', writes HARD_LOCKED
      row, WelcomeOnboardingScreen navigates to LockoutScreen immediately.
      Next app boot: checkLicense() → hardLocked → LockoutScreen. 
      "I Just Paid - Check Again" → renewFromCloud → if ACTIVE, unlocks.

[ ] Existing registered device (already_registered: true from server)
    → initTrialFromCloud returns null, updates local row with farm-level
      expiry (no change in behavior from before).

[ ] Admin revokes farm on web
    → Within 6 hours, renewFromCloud gets status='REVOKED', maps to
      'HARD_LOCKED', _setMode writes it, next checkLicense() fires
      LockoutScreen in main_scaffold.dart's periodic check.

[ ] Farm pays for STANDARD
    → renewFromCloud gets status='PAID_STANDARD', maps correctly to
      'CLOUD_ACTIVE', new expires_at from server is written, app unlocks.

[ ] Farm pays for PREMIUM
    → Same as STANDARD, status='PAID_PREMIUM' → 'CLOUD_ACTIVE'.

[ ] Clock tamper still fires independently
    → Change to _serverStatusToLocalMode does not affect clockTampered
      path (which is checked BEFORE server status in checkLicense()).
```
