import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../services/license_service.dart';
import '../data/sync_engine.dart';
import '../services/session_mode_service.dart';

class SessionModeBadge extends StatelessWidget {
  final bool compact;

  const SessionModeBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final syncEngine = context.watch<SyncEngine>();
    final db = context.read<AppDatabase>();

    return FutureBuilder<_SessionBadgeState>(
      future: _loadState(db),
      builder: (context, snapshot) {
        final state = snapshot.data;
        final storedMode = state?.sessionMode ?? SessionMode.cloudSync;
        final offline =
            storedMode == SessionMode.secureOffline || !syncEngine.isOnline;
        final color = offline
            ? const Color(0xFFF59E0B)
            : const Color(0xFF22C55E);
        final icon = offline
            ? Icons.enhanced_encryption_rounded
            : Icons.cloud_done_rounded;
        final label = offline ? 'SECURE LOCAL OFFLINE MODE' : 'CLOUD SYNC MODE';

        final modeBadge = Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            if (!compact) ...[
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        );

        return Tooltip(
          message: label,
          child: Container(
            width: compact ? 34 : double.infinity,
            height: compact ? 30 : null,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 0 : 10,
              vertical: compact ? 0 : 8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: compact
                ? modeBadge
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      modeBadge,
                      if (state?.licenseConfig != null) ...[
                        const SizedBox(height: 9),
                        Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SUBSCRIPTION',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subscriptionText(state!),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _subscriptionColor(state),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<_SessionBadgeState> _loadState(AppDatabase db) async {
    final sessionMode = await SessionModeService.currentMode();
    LicenseConfig? config;
    LicenseStatus? status;
    try {
      final service = LicenseService(db);
      config = await service.getConfig();
      status = await service.checkLicense();
    } catch (_) {}
    return _SessionBadgeState(
      sessionMode: sessionMode,
      licenseConfig: config,
      licenseStatus: status,
    );
  }

  String _subscriptionText(_SessionBadgeState state) {
    final config = state.licenseConfig;
    if (config == null) return '';
    final now = DateTime.now();
    final days = config.expiresAt.difference(now).inDays.clamp(0, 9999);
    if (state.licenseStatus == LicenseStatus.softLocked) {
      return 'Expiring in $days days';
    }
    switch (config.mode) {
      case 'CLOUD_TRIAL':
        return 'Trial · $days days remaining';
      case 'CLOUD_ACTIVE':
        return 'Active · Renews ${_monthDay(config.expiresAt)}';
      case 'EXPIRED':
        return 'Expired · 0 days remaining';
      case 'HARD_LOCKED':
        return 'Locked · subscription required';
      default:
        return '${config.mode} · $days days remaining';
    }
  }

  Color _subscriptionColor(_SessionBadgeState state) {
    final config = state.licenseConfig;
    if (config == null) return Colors.white60;
    final days = config.expiresAt.difference(DateTime.now()).inDays;
    if (state.licenseStatus == LicenseStatus.softLocked || days < 7) {
      return const Color(0xFFF59E0B);
    }
    return Colors.white60;
  }

  String _monthDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _SessionBadgeState {
  final SessionMode sessionMode;
  final LicenseConfig? licenseConfig;
  final LicenseStatus? licenseStatus;

  const _SessionBadgeState({
    required this.sessionMode,
    required this.licenseConfig,
    required this.licenseStatus,
  });
}
