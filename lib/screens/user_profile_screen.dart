import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../data/local_db.dart';
import '../services/auth_service.dart';
import '../services/session_mode_service.dart';
import '../utils/farm_utils.dart';
import '../utils/secure_auth_storage.dart';
import '../utils/settings_profile_contract.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<_UserProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_UserProfileData> _loadProfile() async {
    final db = context.read<AppDatabase>();
    final prefs = await SharedPreferences.getInstance();
    final session = UserSession();
    final authUser = supa.Supabase.instance.client.auth.currentUser;
    final mode = await SessionModeService.currentMode();
    final offlineCredentialConfigured =
        await SecureAuthStorage.hasOfflineCredential() ||
        await SecureAuthStorage.isSetupComplete();
    final offlineIdentity =
        await SecureAuthStorage.getOfflineCredentialIdentity();
    final workerPermissionsJson =
        await SecureAuthStorage.getWorkerPermissionsJson();

    final userId =
        _firstNonEmpty([
          session.currentWorkerId,
          prefs.getString('user_id'),
          authUser?.id,
          offlineIdentity?.userId,
        ]) ??
        '';

    User? localUser;
    if (userId.isNotEmpty) {
      localUser = await (db.select(
        db.users,
      )..where((u) => u.id.equals(userId))).getSingleOrNull();
    }

    Profile? provisionedProfile;
    final phone = _firstNonEmpty([
      localUser?.phoneNumber,
      prefs.getString('user_phone'),
      offlineIdentity?.phoneNumber,
    ]);
    if (phone != null) {
      provisionedProfile = await (db.select(
        db.profiles,
      )..where((p) => p.phoneNumber.equals(phone))).getSingleOrNull();
    }

    Farm? farm;
    final farmId =
        _firstNonEmpty([
          prefs.getString('bound_farm_id'),
          prefs.getString('farm_id'),
          offlineIdentity?.farmId,
          provisionedProfile?.farmId,
        ]) ??
        await FarmUtils.getBoundFarmId();
    if (farmId != null && farmId.isNotEmpty) {
      farm = await (db.select(
        db.farms,
      )..where((f) => f.id.equals(farmId))).getSingleOrNull();
    }
    if (farm == null && userId.isNotEmpty) {
      final farms = await (db.select(
        db.farms,
      )..where((f) => f.userId.equals(userId))).get();
      farm = farms.isEmpty ? null : farms.first;
    }

    FarmMember? membership;
    if (userId.isNotEmpty) {
      final query = db.select(db.farmMembers)
        ..where((m) => m.userId.equals(userId));
      if (farm != null) {
        query.where((m) => m.farmId.equals(farm!.id));
      }
      final memberships = await query.get();
      membership = memberships.isEmpty ? null : memberships.first;
    }

    LicenseConfig? licenseConfig;
    if (farm != null) {
      licenseConfig = await (db.select(
        db.licenseConfigs,
      )..where((l) => l.farmId.equals(farm!.id))).getSingleOrNull();
    }

    final permissionRows = userId.isEmpty
        ? <UserPermission>[]
        : await (db.select(
            db.userPermissions,
          )..where((p) => p.userId.equals(userId))).get();

    final permissions = _decodePermissions([
      provisionedProfile?.customPermissionsJson,
      workerPermissionsJson,
      jsonEncode(
        permissionRows
            .where((permission) => permission.allowed)
            .map((permission) => permission.permissionKey)
            .toList(),
      ),
    ]);

    final metadata = authUser?.userMetadata ?? const <String, dynamic>{};
    final appMetadata = authUser?.appMetadata ?? const <String, dynamic>{};
    final provider =
        _text(appMetadata['provider']) ??
        offlineIdentity?.provider ??
        (authUser == null ? 'Local credential' : 'Supabase');

    return _UserProfileData(
      userId: userId,
      authUserId: authUser?.id,
      displayName:
          _firstNonEmpty([
            localUser?.name,
            '${localUser?.firstname ?? ''} ${localUser?.surname ?? ''}'.trim(),
            session.currentWorkerName,
            prefs.getString('user_name'),
            offlineIdentity?.displayName,
            _text(metadata['full_name']),
            authUser?.email,
          ]) ??
          'Current User',
      firstName: _firstNonEmpty([
        localUser?.firstname,
        provisionedProfile?.firstName,
        _text(metadata['first_name']),
      ]),
      middleName: localUser?.middleName,
      surname: _firstNonEmpty([
        localUser?.surname,
        provisionedProfile?.lastName,
        _text(metadata['last_name']),
      ]),
      email: _firstNonEmpty([
        localUser?.email,
        prefs.getString('user_email'),
        offlineIdentity?.email,
        authUser?.email,
      ]),
      phoneNumber: phone,
      role:
          _firstNonEmpty([
            localUser?.role,
            prefs.getString('user_role'),
            session.currentWorkerRole,
            provisionedProfile?.role,
            membership?.role,
            offlineIdentity?.role,
          ]) ??
          'OWNER',
      profileStatus: provisionedProfile?.status,
      avatarUrl: _firstNonEmpty([
        localUser?.image,
        _text(metadata['avatar_url']),
        _text(metadata['picture']),
      ]),
      authProvider: provider,
      sessionMode: mode,
      offlineCredentialConfigured: offlineCredentialConfigured,
      farm: farm,
      membership: membership,
      licenseConfig: licenseConfig,
      permissions: permissions,
      localUser: localUser,
      provisionedProfile: provisionedProfile,
      authCreatedAt: authUser?.createdAt,
      lastSignInAt: authUser?.lastSignInAt,
      emailConfirmedAt: authUser?.emailConfirmedAt,
    );
  }

  void _refresh() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _editProfile(_UserProfileData profile) async {
    final firstNameController = TextEditingController(text: profile.firstName ?? '');
    final surnameController = TextEditingController(text: profile.surname ?? '');
    final emailController = TextEditingController(text: profile.email ?? '');
    final phoneController = TextEditingController(text: profile.phoneNumber ?? '');

    bool isValid() {
      if (firstNameController.text.trim().isEmpty) return false;
      if (surnameController.text.trim().isEmpty) return false;
      final email = emailController.text.trim();
      if (email.isNotEmpty &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        return false;
      }
      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone.replaceAll(RegExp(r'\D'), '').length < 7) {
        return false;
      }
      return true;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'First Name *'),
                ),
                TextField(
                  controller: surnameController,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Last Name *'),
                ),
                TextField(
                  controller: emailController,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Email (optional)'),
                ),
                TextField(
                  controller: phoneController,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Phone (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: isValid() ? () => Navigator.pop(context, true) : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || profile.userId.isEmpty) {
      firstNameController.dispose();
      surnameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      return;
    }

    final displayName = SettingsProfileContract.buildDisplayName(
      firstName: firstNameController.text,
      middleName: profile.middleName,
      surname: surnameController.text,
    );

    final db = context.read<AppDatabase>();
    await (db.update(db.users)..where((u) => u.id.equals(profile.userId))).write(
      UsersCompanion(
        firstname: Value(firstNameController.text.trim()),
        surname: Value(surnameController.text.trim()),
        email: Value(emailController.text.trim().isEmpty ? null : emailController.text.trim()),
        phoneNumber: Value(phoneController.text.trim().isEmpty ? null : phoneController.text.trim()),
        name: Value(displayName),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );

    try {
      await supa.Supabase.instance.client.auth.updateUser(
        supa.UserAttributes(
          data: {
            'firstName': firstNameController.text.trim(),
            'lastName': surnameController.text.trim(),
          },
        ),
      );
      await supa.Supabase.instance.client.from('users').update({
        'firstname': firstNameController.text.trim(),
        'surname': surnameController.text.trim(),
        'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        'phoneNumber': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        'name': displayName,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', profile.userId);
    } catch (_) {}

    firstNameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_UserProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ProfileError(message: snapshot.error.toString());
        }

        final profile = snapshot.data!;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(profile: profile, onRefresh: _refresh, onEdit: _editProfile),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final account = _ProfileSection(
                        title: 'Account',
                        icon: Icons.badge_rounded,
                        rows: [
                          _InfoRow('User ID', profile.userId),
                          _InfoRow('Auth User ID', profile.authUserId),
                          _InfoRow('Display Name', profile.displayName),
                          _InfoRow('First Name', profile.firstName),
                          _InfoRow('Middle Name', profile.middleName),
                          _InfoRow('Surname', profile.surname),
                          _InfoRow('Email', profile.email),
                          _InfoRow('Phone', profile.phoneNumber),
                          _InfoRow('Role', profile.role),
                          _InfoRow('Profile Status', profile.profileStatus),
                        ],
                      );
                      final farm = _ProfileSection(
                        title: 'Farm & Membership',
                        icon: Icons.agriculture_rounded,
                        rows: [
                          _InfoRow('Farm Name', profile.farm?.name),
                          _InfoRow('Farm ID', profile.farm?.id),
                          _InfoRow('Location', profile.farm?.location),
                          _InfoRow(
                            'Capacity',
                            profile.farm?.capacity.toString(),
                          ),
                          _InfoRow(
                            'Subscription Tier',
                            profile.farm?.subscriptionTier,
                          ),
                          _InfoRow('Sync Status', profile.farm?.syncStatus),
                          _InfoRow('Membership ID', profile.membership?.id),
                          _InfoRow('Membership Role', profile.membership?.role),
                        ],
                      );

                      if (!isWide) {
                        return Column(
                          children: [
                            account,
                            const SizedBox(height: 16),
                            farm,
                            const SizedBox(height: 16),
                            _buildAccessSection(profile),
                            const SizedBox(height: 16),
                            _buildActivitySection(profile),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: account),
                              const SizedBox(width: 16),
                              Expanded(child: farm),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildAccessSection(profile)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildActivitySection(profile)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessSection(_UserProfileData profile) {
    return _ProfileSection(
      title: 'Access & Security',
      icon: Icons.verified_user_rounded,
      rows: [
        _InfoRow('Auth Provider', _titleCase(profile.authProvider)),
        _InfoRow('Session Mode', profile.sessionModeLabel),
        _InfoRow('Email Confirmed', _formatDateText(profile.emailConfirmedAt)),
        _InfoRow(
          'Offline Credential',
          profile.offlineCredentialConfigured ? 'Configured' : 'Not configured',
        ),
      ],
      footer: profile.permissions.isEmpty
          ? const Text(
              'No custom permissions are stored for this account.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.permissions
                  .map((permission) => _PermissionChip(label: permission))
                  .toList(),
            ),
    );
  }

  Widget _buildActivitySection(_UserProfileData profile) {
    return _ProfileSection(
      title: 'Dates & Device State',
      icon: Icons.event_note_rounded,
      rows: [
        _InfoRow('Local User Created', _formatDateText(profile.createdAt)),
        _InfoRow('Local User Updated', _formatDateText(profile.updatedAt)),
        _InfoRow('Provisioned At', _formatDateText(profile.profileCreatedAt)),
        _InfoRow(
          'Provision Updated',
          _formatDateText(profile.profileUpdatedAt),
        ),
        _InfoRow('Auth Created', _formatDateText(profile.authCreatedAt)),
        _InfoRow('Last Sign In', _formatDateText(profile.lastSignInAt)),
        _InfoRow('License Status', profile.licenseStatus),
        _InfoRow('License Expires', _formatDateText(profile.licenseExpiresAt)),
        _InfoRow('Hardware ID', profile.hardwareId),
        _InfoRow('Installed At', _formatDateText(profile.installedAt)),
        _InfoRow('Last Used', _formatDateText(profile.lastUsed)),
        _InfoRow('Last Cloud Check', _formatDateText(profile.lastCloudCheckAt)),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final _UserProfileData profile;
  final VoidCallback onRefresh;
  final Future<void> Function(_UserProfileData profile)? onEdit;

  const _ProfileHeader({
    required this.profile,
    required this.onRefresh,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final initials = profile.initials;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF16A34A),
            foregroundImage: profile.avatarUrl == null
                ? null
                : NetworkImage(profile.avatarUrl!),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(
                      icon: Icons.admin_panel_settings_rounded,
                      label: profile.role,
                    ),
                    _StatusPill(
                      icon: Icons.cloud_done_rounded,
                      label: profile.sessionModeLabel,
                    ),
                    if (profile.farm?.name != null)
                      _StatusPill(
                        icon: Icons.agriculture_rounded,
                        label: profile.farm!.name,
                      ),
                    if (profile.membership?.joinedAt != null)
                      _StatusPill(
                        icon: Icons.calendar_month_rounded,
                        label:
                            'Member since ${DateFormat.yMMMM().format(profile.membership!.joinedAt)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh profile',
          ),
          if (onEdit != null)
            IconButton.filledTonal(
              onPressed: () => onEdit!(profile),
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit profile',
            ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  final Widget? footer;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.map((row) => _InfoTile(row: row)),
          if (footer != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _InfoRow row;

  const _InfoTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final value = _cleanDisplay(row.value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              row.label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value == 'Not available'
                    ? const Color(0xFF94A3B8)
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF16A34A).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF16A34A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF166534),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;

  const _PermissionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.check_circle_rounded, size: 16),
      label: Text(_humanize(label)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String? value;

  const _InfoRow(this.label, this.value);
}

class _UserProfileData {
  final String userId;
  final String? authUserId;
  final String displayName;
  final String? firstName;
  final String? middleName;
  final String? surname;
  final String? email;
  final String? phoneNumber;
  final String role;
  final String? profileStatus;
  final String? avatarUrl;
  final String authProvider;
  final SessionMode sessionMode;
  final bool offlineCredentialConfigured;
  final Farm? farm;
  final FarmMember? membership;
  final LicenseConfig? licenseConfig;
  final List<String> permissions;
  final User? localUser;
  final Profile? provisionedProfile;
  final String? authCreatedAt;
  final String? lastSignInAt;
  final String? emailConfirmedAt;

  const _UserProfileData({
    required this.userId,
    required this.authUserId,
    required this.displayName,
    required this.firstName,
    required this.middleName,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.profileStatus,
    required this.avatarUrl,
    required this.authProvider,
    required this.sessionMode,
    required this.offlineCredentialConfigured,
    required this.farm,
    required this.membership,
    required this.licenseConfig,
    required this.permissions,
    required this.localUser,
    required this.provisionedProfile,
    required this.authCreatedAt,
    required this.lastSignInAt,
    required this.emailConfirmedAt,
  });

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  String get sessionModeLabel => sessionMode == SessionMode.secureOffline
      ? 'Secure Offline'
      : 'Cloud Sync';

  DateTime? get createdAt => localUser?.createdAt;
  DateTime? get updatedAt => localUser?.updatedAt;
  DateTime? get profileCreatedAt => provisionedProfile?.createdAt;
  DateTime? get profileUpdatedAt => provisionedProfile?.updatedAt;
  String? get licenseStatus => licenseConfig?.mode;
  DateTime? get licenseExpiresAt => licenseConfig?.expiresAt;
  String? get hardwareId => licenseConfig?.hardwareId;
  DateTime? get installedAt => licenseConfig?.installedAt;
  DateTime? get lastUsed => licenseConfig?.lastUsed;
  DateTime? get lastCloudCheckAt => licenseConfig?.lastCloudCheckAt;
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    final cleaned = value?.trim();
    if (cleaned != null && cleaned.isNotEmpty) return cleaned;
  }
  return null;
}

String? _text(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String _cleanDisplay(String? value) {
  final cleaned = value?.trim();
  return cleaned == null || cleaned.isEmpty ? 'Not available' : cleaned;
}

String? _formatDateText(Object? value) {
  if (value == null) return null;
  final date = value is DateTime ? value : DateTime.tryParse(value.toString());
  if (date == null) return value.toString();
  return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
}

List<String> _decodePermissions(Iterable<String?> sources) {
  final values = <String>{};
  for (final source in sources) {
    if (source == null || source.trim().isEmpty) continue;
    try {
      final decoded = jsonDecode(source);
      if (decoded is List) {
        values.addAll(decoded.map((item) => item.toString()));
      }
    } catch (_) {}
  }
  return values.where((item) => item.trim().isNotEmpty).toList()..sort();
}

String _humanize(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _titleCase(String value) {
  return _humanize(value.replaceAll('-', ' '));
}
