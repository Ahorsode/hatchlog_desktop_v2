import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:drift/drift.dart' as drift;

import '../data/local_db.dart';
import '../services/auth_service.dart';
import '../utils/farm_utils.dart';
import '../utils/user_role.dart';
import '../data/sync_engine.dart';
import '../utils/id_utils.dart';
import '../services/team_provisioning_service.dart';
import '../utils/team_seat_limit.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late AppDatabase db;
  final _roles = [
    'OWNER',
    'MANAGER',
    'WORKER',
    'CASHIER',
    'ACCOUNTANT',
    'FINANCE_OFFICER',
  ];
  static const _assignableRoles = assignableStaffRoles;
  final Map<String, String> _pendingRoleUpdates = {};
  StreamSubscription<List<Map<String, dynamic>>>? _profileRealtimeSub;
  late AnimationController _shimmerController;

  bool _isOwner = false;
  bool _isApplying = false;
  bool _canManage = false;
  bool _isHydratingProfiles = true;

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    final normalizedRole = UserRoleUtils.normalize(
      UserSession().currentWorkerRole,
    );
    _isOwner = normalizedRole == UserRoleUtils.owner;
    _canManage =
        normalizedRole == UserRoleUtils.owner ||
        normalizedRole == UserRoleUtils.manager;
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    unawaited(_startProfileRealtimeListener());
  }

  @override
  void dispose() {
    _profileRealtimeSub?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _startProfileRealtimeListener() async {
    final farmId = await _getFarmId();
    if (farmId == null || farmId.isEmpty) {
      if (mounted) setState(() => _isHydratingProfiles = false);
      return;
    }

    await _profileRealtimeSub?.cancel();
    _profileRealtimeSub = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('farmId', farmId)
        .listen(
          (rows) async {
            for (final row in rows) {
              await _upsertProfileFromJson(row, farmIdFallback: farmId);
            }
            if (mounted) setState(() => _isHydratingProfiles = false);
          },
          onError: (error) {
            debugPrint('Profile realtime listener failed: $error');
            if (mounted) setState(() => _isHydratingProfiles = false);
          },
        );
  }

  Future<void> _upsertProfileFromJson(
    Map<String, dynamic> row, {
    required String farmIdFallback,
  }) async {
    final id = (row['id'] ?? '').toString().trim();
    final phone = (row['phoneNumber'] ?? row['phone_number'] ?? '')
        .toString()
        .trim();
    if (id.isEmpty || phone.isEmpty) return;

    await db
        .into(db.profiles)
        .insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: id,
            farmId: (row['farmId'] ?? row['farm_id'] ?? farmIdFallback)
                .toString(),
            phoneNumber: phone,
            role: drift.Value((row['role'] ?? 'WORKER').toString()),
            firstName: drift.Value(
              _nullableString(row['firstName'] ?? row['first_name']),
            ),
            lastName: drift.Value(
              _nullableString(row['lastName'] ?? row['last_name']),
            ),
            status: drift.Value((row['status'] ?? 'PENDING').toString()),
            customPermissionsJson: drift.Value(
              _jsonText(
                row['customPermissionsJson'] ?? row['custom_permissions_json'],
              ),
            ),
            createdAt: drift.Value(
              _dateTimeFrom(row['createdAt'] ?? row['created_at']),
            ),
            updatedAt: drift.Value(
              _dateTimeFrom(row['updatedAt'] ?? row['updated_at']),
            ),
            synced: const drift.Value(true),
          ),
        );
  }

  String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _jsonText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List || value is Map) return jsonEncode(value);
    return value.toString();
  }

  DateTime _dateTimeFrom(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now().toUtc();
  }

  Future<void> _applyRoleChange(FarmMember member, String newRole) async {
    if (!_canManage) return;
    if (member.role == newRole) {
      _showMessage('The selected role is already assigned.');
      return;
    }

    setState(() => _isApplying = true);
    try {
      await db
          .into(db.farmMembers)
          .insertOnConflictUpdate(
            FarmMembersCompanion(
              id: drift.Value(member.id),
              farmId: drift.Value(member.farmId),
              userId: drift.Value(member.userId),
              role: drift.Value(newRole),
              joinedAt: drift.Value(member.joinedAt),
              synced: const drift.Value(false),
            ),
          );

      final rolePayload = {
        'id': member.id,
        'farmId': member.farmId,
        'userId': member.userId,
        'role': newRole,
      };
      await Supabase.instance.client.from('farm_members').upsert([
        rolePayload,
      ], onConflict: 'id');
      if (_isOwner) {
        await _revokeRemoteUserSession(member.userId);
        _showMessage(
          'Role updated and remote session revoked for ${member.userId}.',
        );
      } else {
        _showMessage('Role update queued for ${member.userId}.');
      }
      setState(() => _pendingRoleUpdates.remove(member.id));
    } catch (error) {
      _showMessage('Unable to apply promotion: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _revokeRemoteUserSession(String userId) async {
    try {
      await Supabase.instance.client.rpc(
        'invalidate_user_sessions',
        params: {'p_user_id': userId},
      );
    } catch (error) {
      debugPrint('Unable to call role invalidation RPC: $error');
    }
  }

  Future<Set<String>> _loadMemberPermissions(
    String farmId,
    String userId,
  ) async {
    try {
      final row = await Supabase.instance.client
          .from('user_permissions')
          .select()
          .eq('farm_id', farmId)
          .eq('user_id', userId)
          .maybeSingle();
      if (row == null) {
        return {};
      }
      final enabled = <String>{};
      for (final definition in teamPermissionDefinitions) {
        if (row[definition.key] == true) {
          enabled.add(definition.key);
        }
      }
      return enabled;
    } catch (error) {
      debugPrint('Unable to load member permissions: $error');
      return {};
    }
  }

  Future<void> _saveMemberPermissions({
    required String farmId,
    required String userId,
    required Set<String> permissions,
  }) async {
    final payload = <String, dynamic>{
      'id': 'perm_${farmId}_$userId',
      'farm_id': farmId,
      'user_id': userId,
    };
    for (final definition in teamPermissionDefinitions) {
      payload[definition.key] = permissions.contains(definition.key);
    }
    await Supabase.instance.client.from('user_permissions').upsert(payload);
    await _revokeRemoteUserSession(userId);
  }

  Future<void> _showInvitePermissionsDialog(Profile profile) async {
    var selectedPermissions = decodePermissions(profile.customPermissionsJson);
    if (selectedPermissions.isEmpty) {
      selectedPermissions = defaultPermissionsForRole(profile.role).toList();
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Permissions — ${profile.phoneNumber}'),
        content: StatefulBuilder(
          builder: (ctx, setState) => SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role: ${formatRoleLabel(profile.role)}'),
                  const SizedBox(height: 12),
                  _PermissionGroup(
                    title: 'View',
                    permissions: teamPermissionDefinitions
                        .where((it) => it.group == 'View')
                        .toList(),
                    selectedPermissions: selectedPermissions.toSet(),
                    onChanged: (key, checked) {
                      setState(() {
                        selectedPermissions = applyPermissionToggle(
                          selectedPermissions.toSet(),
                          key,
                          checked,
                        ).toList();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _PermissionGroup(
                    title: 'Edit',
                    permissions: teamPermissionDefinitions
                        .where((it) => it.group == 'Edit')
                        .toList(),
                    selectedPermissions: selectedPermissions.toSet(),
                    onChanged: (key, checked) {
                      setState(() {
                        selectedPermissions = applyPermissionToggle(
                          selectedPermissions.toSet(),
                          key,
                          checked,
                        ).toList();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isApplying = true);
              try {
                await (db.update(db.profiles)
                      ..where((p) => p.id.equals(profile.id)))
                    .write(
                  ProfilesCompanion(
                    customPermissionsJson: drift.Value(
                      encodePermissions(selectedPermissions),
                    ),
                    updatedAt: drift.Value(DateTime.now()),
                    synced: const drift.Value(false),
                  ),
                );
                await Supabase.instance.client.from('profiles').update({
                  'customPermissionsJson': encodePermissions(selectedPermissions),
                  'updatedAt': DateTime.now().toUtc().toIso8601String(),
                }).eq('id', profile.id);
                _showMessage('Invitation permissions updated.');
              } catch (error) {
                _showMessage('Unable to update permissions: $error', isError: true);
              } finally {
                if (mounted) setState(() => _isApplying = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberPermissionsDialog(
    FarmMember member,
    String role,
  ) async {
    final farmId = member.farmId;
    var selectedPermissions = await _loadMemberPermissions(farmId, member.userId);
    if (selectedPermissions.isEmpty) {
      selectedPermissions = defaultPermissionsForRole(role);
    }
    var permissionsCustomized = selectedPermissions.isNotEmpty;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Access Control — ${member.userId}'),
        content: StatefulBuilder(
          builder: (ctx, setState) => SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role: ${formatRoleLabel(role)}'),
                  const SizedBox(height: 12),
                  _PermissionGroup(
                    title: 'View',
                    permissions: teamPermissionDefinitions
                        .where((it) => it.group == 'View')
                        .toList(),
                    selectedPermissions: selectedPermissions,
                    onChanged: (key, checked) {
                      setState(() {
                        permissionsCustomized = true;
                        selectedPermissions = applyPermissionToggle(
                          selectedPermissions,
                          key,
                          checked,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _PermissionGroup(
                    title: 'Edit',
                    permissions: teamPermissionDefinitions
                        .where((it) => it.group == 'Edit')
                        .toList(),
                    selectedPermissions: selectedPermissions,
                    onChanged: (key, checked) {
                      setState(() {
                        permissionsCustomized = true;
                        selectedPermissions = applyPermissionToggle(
                          selectedPermissions,
                          key,
                          checked,
                        );
                      });
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        permissionsCustomized = false;
                        selectedPermissions = defaultPermissionsForRole(role);
                      });
                    },
                    icon: const Icon(Icons.restore_rounded),
                    label: Text(
                      'Reset to ${formatRoleLabel(role)} defaults',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isApplying = true);
              try {
                await _saveMemberPermissions(
                  farmId: farmId,
                  userId: member.userId,
                  permissions: permissionsCustomized
                      ? selectedPermissions
                      : defaultPermissionsForRole(role),
                );
                _showMessage('Permissions updated and sessions revoked.');
              } catch (error) {
                _showMessage('Unable to save permissions: $error', isError: true);
              } finally {
                if (mounted) setState(() => _isApplying = false);
              }
            },
            child: const Text('Save & Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddMemberDialog() async {
    final phoneCtrl = TextEditingController();
    String selectedRole = 'WORKER';
    var permissionsCustomized = false;
    var selectedPermissions = defaultPermissionsForRole(selectedRole);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Team Member'),
        content: StatefulBuilder(
          builder: (ctx, setState) => SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (e.g., +233XXXXXXXXX)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          items: _assignableRoles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(formatRoleLabel(role)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value ?? selectedRole;
                              if (!permissionsCustomized) {
                                selectedPermissions = defaultPermissionsForRole(
                                  selectedRole,
                                );
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'System Role',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Custom Access Permissions'),
                    subtitle: Text(
                      permissionsCustomized
                          ? 'Custom permissions will override the role preset'
                          : 'Untouched: ${selectedRole.toLowerCase()} default preset will be applied',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PermissionGroup(
                              title: 'View',
                              permissions: teamPermissionDefinitions
                                  .where((it) => it.group == 'View')
                                  .toList(),
                              selectedPermissions: selectedPermissions,
                              onChanged: (key, checked) {
                                setState(() {
                                  permissionsCustomized = true;
                                  selectedPermissions = applyPermissionToggle(
                                    selectedPermissions,
                                    key,
                                    checked,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _PermissionGroup(
                              title: 'Edit',
                              permissions: teamPermissionDefinitions
                                  .where((it) => it.group == 'Edit')
                                  .toList(),
                              selectedPermissions: selectedPermissions,
                              onChanged: (key, checked) {
                                setState(() {
                                  permissionsCustomized = true;
                                  selectedPermissions = applyPermissionToggle(
                                    selectedPermissions,
                                    key,
                                    checked,
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  permissionsCustomized = false;
                                  selectedPermissions =
                                      defaultPermissionsForRole(selectedRole);
                                });
                              },
                              icon: const Icon(Icons.restore_rounded),
                              label: const Text('Reset to Role Default'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final phone = phoneCtrl.text.trim();
              if (phone.isEmpty) return;
              Navigator.of(ctx).pop();
              _createWorkerProfile(
                phone,
                selectedRole,
                selectedPermissions,
                permissionsCustomized: permissionsCustomized,
              );
            },
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
    phoneCtrl.dispose();
  }

  Future<void> _createWorkerProfile(
    String phoneNumber,
    String role,
    Set<String> selectedPermissions, {
    required bool permissionsCustomized,
  }) async {
    setState(() => _isApplying = true);
    try {
      final syncEngine = Provider.of<SyncEngine>(context, listen: false);
      final farmId = await _getFarmId();
      if (farmId == null) throw Exception('No farm bound');

      final profileId = newLocalId();
      final normalizedRole = normalizeProvisioningRole(role);
      final effectivePermissions = permissionsCustomized
          ? sortedPermissions(selectedPermissions)
          : sortedPermissions(defaultPermissionsForRole(normalizedRole));

      final remoteProfile = await TeamProvisioningService().provisionTeamMember(
        TeamProvisioningRequest(
          profileId: profileId,
          farmId: farmId,
          phoneNumber: phoneNumber,
          role: normalizedRole,
          permissions: effectivePermissions,
          permissionsCustomized: permissionsCustomized,
        ),
      );

      await db
          .into(db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion.insert(
              id: (remoteProfile['id'] ?? profileId).toString(),
              farmId:
                  (remoteProfile['farmId'] ??
                          remoteProfile['farm_id'] ??
                          farmId)
                      .toString(),
              phoneNumber:
                  (remoteProfile['phoneNumber'] ??
                          remoteProfile['phone_number'] ??
                          phoneNumber)
                      .toString(),
              role: drift.Value(
                (remoteProfile['role'] ?? normalizedRole).toString(),
              ),
              status: const drift.Value('PENDING'),
              customPermissionsJson: drift.Value(
                _jsonText(remoteProfile['customPermissionsJson']) ??
                    encodePermissions(effectivePermissions),
              ),
              createdAt: drift.Value(
                _dateTimeFrom(
                  remoteProfile['createdAt'] ?? remoteProfile['created_at'],
                ),
              ),
              updatedAt: drift.Value(
                _dateTimeFrom(
                  remoteProfile['updatedAt'] ?? remoteProfile['updated_at'],
                ),
              ),
              synced: const drift.Value(true),
            ),
          );

      syncEngine.syncNow();
      _showMessage(
        'Worker profile created for $phoneNumber. Awaiting mobile setup.',
      );
    } catch (e) {
      _showMessage('Unable to create profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF16A34A),
      ),
    );
  }

  Future<String?> _getFarmId() async => FarmUtils.getBoundFarmId();

  Color _roleColor(String role) {
    switch (role) {
      case 'OWNER':
        return const Color(0xFF7C3AED);
      case 'MANAGER':
        return const Color(0xFF2563EB);
      case 'WORKER':
        return const Color(0xFF0891B2);
      case 'ACCOUNTANT':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF16A34A);
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'OWNER':
        return Icons.stars_rounded;
      case 'MANAGER':
        return Icons.admin_panel_settings_rounded;
      case 'WORKER':
        return Icons.agriculture_rounded;
      case 'ACCOUNTANT':
        return Icons.calculate_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View synced farm team members and access roles',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(
                  alpha: isDark ? 0.28 : 0.55,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_sync_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Provision phone numbers here, then watch mobile activations appear in realtime as workers complete setup.',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role legend
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _roles
                    .map(
                      (role) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _roleColor(role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _roleColor(role).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _roleIcon(role),
                                size: 14,
                                color: _roleColor(role),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                role,
                                style: TextStyle(
                                  color: _roleColor(role),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isOwner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.secondary.withOpacity(0.18)),
                ),
                child: Text(
                  'Promotion controls are reserved for Owners. Managers can view the team but may not force logout sessions or update access tokens.',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ),
            if (!_isOwner) const SizedBox(height: 16),

            if (_canManage)
              FutureBuilder<String?>(
                future: _getFarmId(),
                builder: (context, farmSnap) {
                  final farmId = farmSnap.data;
                  if (farmId == null || farmId.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return FutureBuilder<SeatLimitCheck>(
                    future: checkSeatLimit(db, farmId),
                    builder: (context, limitSnap) {
                      final limit = limitSnap.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (limit != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: limit.canAdd
                                      ? cs.primary.withValues(alpha: 0.2)
                                      : Colors.redAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${limit.current} / ${limit.isUnlimited ? '∞' : limit.limit} seats used',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: limit.isUnlimited
                                          ? null
                                          : (limit.current / limit.limit)
                                              .clamp(0.0, 1.0),
                                      backgroundColor: cs.outline.withValues(alpha: 0.15),
                                      color: limit.canAdd
                                          ? const Color(0xFF16A34A)
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  if (!limit.canAdd) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Seat limit reached. Upgrade to add more staff.',
                                      style: TextStyle(
                                        color: cs.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _isApplying ||
                                      (limit != null && !limit.canAdd)
                                  ? null
                                  : () => _showAddMemberDialog(),
                              icon: const Icon(Icons.person_add_rounded),
                              label: const Text('Add Member'),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            if (_canManage) const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<String?>(
                future: _getFarmId(),
                builder: (context, farmSnap) {
                  final farmId = farmSnap.data;
                  if (farmId == null || farmId.isEmpty) {
                    return Center(
                      child: Text(
                        'No farm is bound to this device.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<List<FarmMember>>(
                    stream: (db.select(
                      db.farmMembers,
                    )..where((m) => m.farmId.equals(farmId))).watch(),
                    builder: (ctx, memberSnap) {
                      final members = memberSnap.data ?? [];

                      return StreamBuilder<List<Profile>>(
                        stream: (db.select(
                          db.profiles,
                        )..where((p) => p.farmId.equals(farmId))).watch(),
                        builder: (ctx, profileSnap) {
                          final profiles = profileSnap.data ?? [];
                          final stillLoading =
                              _isHydratingProfiles ||
                              memberSnap.connectionState ==
                                  ConnectionState.waiting ||
                              profileSnap.connectionState ==
                                  ConnectionState.waiting;

                          if (stillLoading &&
                              members.isEmpty &&
                              profiles.isEmpty) {
                            return _TeamDirectoryShimmer(
                              animation: _shimmerController,
                            );
                          }

                          if (members.isEmpty && profiles.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_rounded,
                                    size: 72,
                                    color: cs.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team members yet.',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create profiles on desktop or sync active members from cloud.',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return FutureBuilder<List<User>>(
                            future:
                                (db.select(db.users)..where(
                                      (u) => u.id.isIn(
                                        members.map((it) => it.userId).toList(),
                                      ),
                                    ))
                                    .get(),
                            builder: (ctx, userSnap) {
                              final usersById = {
                                for (final user in userSnap.data ?? [])
                                  user.id: user,
                              };

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 64,
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      cs.primaryContainer.withOpacity(0.16),
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Name / Phone')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Role')),
                                      DataColumn(label: Text('Joined')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: [
                                      // Active members
                                      ...members.map((member) {
                                        final user = usersById[member.userId];
                                        final name =
                                            user?.name ??
                                            user?.email ??
                                            member.userId;
                                        final phone =
                                            user?.phoneNumber ?? member.userId;
                                        final role = member.role;
                                        final selectedRole =
                                            _pendingRoleUpdates[member.id] ??
                                            role;
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    phone,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF16A34A,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'Active',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF16A34A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    _roleIcon(role),
                                                    size: 16,
                                                    color: _roleColor(role),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(role),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(member.joinedAt),
                                              ),
                                            ),
                                            DataCell(
                                              Wrap(
                                                spacing: 8,
                                                children: [
                                                  if (_canManage)
                                                    SizedBox(
                                                      height: 32,
                                                      child: DropdownButton<String>(
                                                        value: selectedRole,
                                                        items: _assignableRoles
                                                            .map(
                                                              (r) =>
                                                                  DropdownMenuItem(
                                                                value: r,
                                                                child: Text(
                                                                  formatRoleLabel(
                                                                    r,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                        onChanged: (newRole) {
                                                          if (newRole != null) {
                                                            setState(() {
                                                              _pendingRoleUpdates[member
                                                                      .id] =
                                                                  newRole;
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  if (_canManage)
                                                    FilledButton(
                                                      onPressed: _isApplying
                                                          ? null
                                                          : () =>
                                                                _applyRoleChange(
                                                                  member,
                                                                  selectedRole,
                                                                ),
                                                      child: const Text(
                                                        'Apply',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  if (_isOwner)
                                                    OutlinedButton(
                                                      onPressed: _isApplying
                                                          ? null
                                                          : () =>
                                                                _showMemberPermissionsDialog(
                                                                  member,
                                                                  role,
                                                                ),
                                                      child: const Text(
                                                        'Perms',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  if (_isOwner)
                                                    OutlinedButton(
                                                      onPressed: _isApplying
                                                          ? null
                                                          : () =>
                                                                _revokeRemoteUserSession(
                                                                  member.userId,
                                                                ),
                                                      child: const Text(
                                                        'Kill',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                      // Provisioned profiles update in realtime from Supabase.
                                      ...profiles.map((profile) {
                                        final isPending =
                                            profile.status.toUpperCase() ==
                                            'PENDING';
                                        final fullName =
                                            [
                                                  profile.firstName,
                                                  profile.lastName,
                                                ]
                                                .where(
                                                  (part) =>
                                                      part != null &&
                                                      part.trim().isNotEmpty,
                                                )
                                                .join(' ');
                                        final displayName = isPending
                                            ? 'Pending Activation (${profile.phoneNumber})'
                                            : '${profile.role}: ${fullName.isNotEmpty ? fullName : profile.phoneNumber}';
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    profile.phoneNumber,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      (isPending
                                                              ? Colors.orange
                                                              : const Color(
                                                                  0xFF16A34A,
                                                                ))
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isPending
                                                      ? 'Pending'
                                                      : 'Active',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isPending
                                                        ? Colors.orange
                                                        : const Color(
                                                            0xFF16A34A,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    _roleIcon(profile.role),
                                                    size: 16,
                                                    color: _roleColor(
                                                      profile.role,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(profile.role),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(profile.createdAt),
                                              ),
                                            ),
                                            DataCell(
                                              isPending && _canManage
                                                  ? Row(
                                                      children: [
                                                        OutlinedButton(
                                                          onPressed: _isApplying
                                                              ? null
                                                              : () =>
                                                                    _showInvitePermissionsDialog(
                                                                      profile,
                                                                    ),
                                                          child: const Text(
                                                            'Edit Permissions',
                                                            style: TextStyle(fontSize: 11),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Awaiting mobile setup',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: cs.onSurfaceVariant,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      isPending
                                                          ? 'Awaiting mobile setup'
                                                          : 'Self-registered on mobile',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: cs.onSurfaceVariant,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  final String title;
  final List<PermissionDefinition> permissions;
  final Set<String> selectedPermissions;
  final void Function(String key, bool checked) onChanged;

  const _PermissionGroup({
    required this.title,
    required this.permissions,
    required this.selectedPermissions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...permissions.map(
          (permission) => CheckboxListTile(
            title: Text(permission.label),
            value: selectedPermissions.contains(permission.key),
            onChanged: (value) => onChanged(permission.key, value ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _TeamDirectoryShimmer extends StatelessWidget {
  final Animation<double> animation;

  const _TeamDirectoryShimmer({required this.animation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ShimmerRow(
                progress: animation.value,
                baseColor: cs.surfaceContainerHighest.withOpacity(0.34),
                shineColor: cs.surface.withOpacity(0.82),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  final double progress;
  final Color baseColor;
  final Color shineColor;

  const _ShimmerRow({
    required this.progress,
    required this.baseColor,
    required this.shineColor,
  });

  @override
  Widget build(BuildContext context) {
    final start = -1.0 + (progress * 2.0);
    final gradient = LinearGradient(
      begin: Alignment(start, 0),
      end: Alignment(start + 1.0, 0),
      colors: [baseColor, shineColor, baseColor],
      stops: const [0.25, 0.5, 0.75],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8),
        gradient: gradient,
      ),
      child: const SizedBox(height: 52),
    );
  }
}
