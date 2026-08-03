import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/auth_service.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/inventory_constants.dart';
import '../utils/livestock_breed_options.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/session_mode_badge.dart';
import 'egg_production_screen.dart';
import 'feed_management_screen.dart';
import 'mortality_screen.dart';
import 'offline_terminal_login_screen.dart';
import 'quarantine_screen.dart';
import 'report_log_screen.dart';

class OperationalDashboard extends StatefulWidget {
  const OperationalDashboard({super.key});

  @override
  State<OperationalDashboard> createState() => _OperationalDashboardState();
}

class _OperationalDashboardState extends State<OperationalDashboard> {
  int _selectedIndex = 0;
  bool _collapsed = false;

  static const _sections = [
    SidebarMenuSection(
      title: 'WORKER WORKSPACE',
      items: [
        SidebarMenuItem(
          index: 0,
          icon: Icons.dashboard_rounded,
          label: 'Daily Workspace',
        ),
        SidebarMenuItem(index: 1, icon: Icons.egg_rounded, label: 'Egg Log'),
        SidebarMenuItem(
          index: 2,
          icon: Icons.restaurant_rounded,
          label: 'Feed Log',
        ),
        SidebarMenuItem(
          index: 3,
          icon: Icons.dangerous_outlined,
          label: 'Mortality',
        ),
        SidebarMenuItem(
          index: 4,
          icon: Icons.healing_rounded,
          label: 'Quarantine',
        ),
      ],
    ),
    SidebarMenuSection(
      title: 'SUPPORT',
      items: [
        SidebarMenuItem(
          index: 5,
          icon: Icons.library_books_rounded,
          label: 'Operation Logs',
        ),
      ],
    ),
  ];

  final List<Widget> _pages = const [
    _OperationalHome(),
    EggProductionScreen(),
    FeedManagementScreen(),
    MortalityScreen(),
    QuarantineScreen(),
    ReportLogScreen(),
  ];

  void _selectPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final syncEngine = context.watch<SyncEngine>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 1000;
          final collapsed = _collapsed || narrow;

          return Row(
            children: [
              AppSidebar(
                selectedIndex: _selectedIndex,
                isCollapsed: collapsed,
                onToggleCollapse: () =>
                    setState(() => _collapsed = !_collapsed),
                onDestinationSelected: _selectPage,
                onLogout: () => _logout(context),
                sections: _sections,
                sessionMode: SessionModeBadge(compact: collapsed),
                syncStatus: _SyncStatus(
                  syncEngine: syncEngine,
                  collapsed: collapsed,
                ),
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Colors.black12,
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signout warning: $e');
    }

    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await UserSession().clearSession();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OfflineTerminalLoginScreen()),
      (route) => false,
    );
  }
}

class _OperationalHome extends StatefulWidget {
  const _OperationalHome();

  @override
  State<_OperationalHome> createState() => _OperationalHomeState();
}

class _OperationalHomeState extends State<_OperationalHome> {
  final _cratesController = TextEditingController();
  final _crackedController = TextEditingController();
  final _rejectedController = TextEditingController();
  final _mortalityController = TextEditingController();
  final _feedBagsController = TextEditingController();

  String? _eggBatchId;
  String? _mortalityBatchId;
  String? _feedBatchId;
  String? _feedItemId;
  bool _savingEggs = false;
  bool _savingMortality = false;
  bool _savingFeed = false;

  @override
  void dispose() {
    _cratesController.dispose();
    _crackedController.dispose();
    _rejectedController.dispose();
    _mortalityController.dispose();
    _feedBagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return Scaffold(
      body: StreamBuilder<List<Batch>>(
        stream: (db.select(
          db.batches,
        )..where((t) => t.status.equals('active'))).watch(),
        builder: (context, batchSnap) {
          final batches = batchSnap.data ?? const <Batch>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  totalBirds: batches.fold<int>(
                    0,
                    (sum, batch) => sum + batch.currentCount,
                  ),
                ),
                const SizedBox(height: 20),
                _FlockSummaryBanner(batches: batches),
                const SizedBox(height: 20),
                _VaccinationAlertsBanner(batches: batches),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 1000;
                    final cardWidth = narrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 32) / 3;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _DataCard(
                            icon: Icons.egg_rounded,
                            title: 'Daily Production Log',
                            accent: const Color(0xFFD97706),
                            children: [
                              _BatchDropdown(
                                batches: batches,
                                value: _eggBatchId,
                                label: 'House unit / flock',
                                onChanged: (value) =>
                                    setState(() => _eggBatchId = value),
                              ),
                              const SizedBox(height: 12),
                              _NumberField(
                                controller: _cratesController,
                                label: 'Total crates',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _NumberField(
                                      controller: _crackedController,
                                      label: 'Cracked eggs',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _NumberField(
                                      controller: _rejectedController,
                                      label: 'Rejected eggs',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _SubmitButton(
                                label: 'Save egg count',
                                saving: _savingEggs,
                                onPressed: () => _submitEggLog(db),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _DataCard(
                            icon: Icons.remove_circle_outline_rounded,
                            title: 'Mortality/Loss Tracker',
                            accent: const Color(0xFFDC2626),
                            children: [
                              _BatchDropdown(
                                batches: batches,
                                value: _mortalityBatchId,
                                label: 'Affected flock',
                                onChanged: (value) =>
                                    setState(() => _mortalityBatchId = value),
                              ),
                              const SizedBox(height: 12),
                              _NumberField(
                                controller: _mortalityController,
                                label: 'Bird deaths',
                              ),
                              const SizedBox(height: 16),
                              _SubmitButton(
                                label: 'Record loss',
                                saving: _savingMortality,
                                onPressed: () => _submitMortality(db, batches),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _DataCard(
                            icon: Icons.restaurant_rounded,
                            title: 'Feed Log',
                            accent: const Color(0xFF2563EB),
                            children: [
                              _BatchDropdown(
                                batches: batches,
                                value: _feedBatchId,
                                label: 'Fed house unit',
                                onChanged: (value) =>
                                    setState(() => _feedBatchId = value),
                              ),
                              const SizedBox(height: 12),
                              _FeedDropdown(
                                db: db,
                                value: _feedItemId,
                                onChanged: (value) =>
                                    setState(() => _feedItemId = value),
                              ),
                              const SizedBox(height: 12),
                              _NumberField(
                                controller: _feedBagsController,
                                label: 'Bags given',
                              ),
                              const SizedBox(height: 16),
                              _SubmitButton(
                                label: 'Save feed log',
                                saving: _savingFeed,
                                onPressed: () => _submitFeedLog(db),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitEggLog(AppDatabase db) async {
    final crates = double.tryParse(_cratesController.text.trim()) ?? 0;
    final cracked = int.tryParse(_crackedController.text.trim()) ?? 0;
    final rejected = int.tryParse(_rejectedController.text.trim()) ?? 0;
    if (_eggBatchId == null || crates <= 0 || cracked < 0 || rejected < 0) {
      _showMessage('Select a flock and enter valid egg counts.', isError: true);
      return;
    }

    setState(() => _savingEggs = true);
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm ID not found');

      final totalEggs = (crates * 30).round();
      final unusable = cracked + rejected;
      await db
          .into(db.eggProductions)
          .insert(
            EggProductionsCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: _eggBatchId!,
              eggsCollected: totalEggs,
              unusableCount: Value(unusable),
              eggsRemaining: Value(
                (totalEggs - unusable).clamp(0, totalEggs).toInt(),
              ),
              cratesCollected: Value(crates),
              qualityGrade: Value('cracked:$cracked;rejected:$rejected'),
              logDate: DateTime.now(),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );
      _cratesController.clear();
      _crackedController.clear();
      _rejectedController.clear();
      _showMessage('Daily egg collection saved.');
    } catch (e) {
      _showMessage('Unable to save egg collection: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingEggs = false);
    }
  }

  Future<void> _submitMortality(AppDatabase db, List<Batch> batches) async {
    final count = int.tryParse(_mortalityController.text.trim()) ?? 0;
    final batch = batches.where((b) => b.id == _mortalityBatchId).firstOrNull;
    if (batch == null || count <= 0) {
      _showMessage(
        'Select a flock and enter a valid loss count.',
        isError: true,
      );
      return;
    }
    if (count > batch.currentCount) {
      _showMessage(
        'Loss count cannot exceed the active flock size.',
        isError: true,
      );
      return;
    }

    setState(() => _savingMortality = true);
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm ID not found');

      await db.transaction(() async {
        await db
            .into(db.mortalities)
            .insert(
              MortalitiesCompanion.insert(
                id: newLocalId(),
                farmId: farmId,
                batchId: batch.id,
                count: count,
                category: const Value('MORTALITY'),
                logDate: DateTime.now(),
                userId: Value(workerId),
                synced: const Value(false),
              ),
            );
        await (db.update(
          db.batches,
        )..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            currentCount: Value(batch.currentCount - count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });
      _mortalityController.clear();
      _showMessage('Mortality record saved.');
    } catch (e) {
      _showMessage('Unable to save mortality record: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingMortality = false);
    }
  }

  Future<void> _submitFeedLog(AppDatabase db) async {
    final bags = double.tryParse(_feedBagsController.text.trim()) ?? 0;
    if (_feedBatchId == null || _feedItemId == null || bags <= 0) {
      _showMessage(
        'Select a flock, feed item, and valid bag count.',
        isError: true,
      );
      return;
    }

    setState(() => _savingFeed = true);
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm ID not found');

      await db
          .into(db.feedingLogs)
          .insert(
            FeedingLogsCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: Value(_feedBatchId),
              feedTypeId: Value(_feedItemId),
              amountConsumed: bags,
              logDate: DateTime.now(),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );
      _feedBagsController.clear();
      _showMessage('Feed log saved.');
    } catch (e) {
      _showMessage('Unable to save feed log: $e', isError: true);
    } finally {
      if (mounted) setState(() => _savingFeed = false);
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
}

class _Header extends StatelessWidget {
  final int totalBirds;

  const _Header({required this.totalBirds});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operational Worker Workspace',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Fast daily logging for eggs, losses, feed, and medical alerts.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _MetricPill(
          icon: Icons.pets_rounded,
          label: 'Active birds',
          value: '$totalBirds',
        ),
      ],
    );
  }
}

class _FlockSummaryBanner extends StatelessWidget {
  final List<Batch> batches;

  const _FlockSummaryBanner({required this.batches});

  static const _trackedKeys = ['ross_308', 'isa_brown', 'bovans_black'];
  static const _shortLabels = {
    'ross_308': 'White Broilers',
    'isa_brown': 'Brown Layers',
    'bovans_black': 'Black Layers',
  };

  @override
  Widget build(BuildContext context) {
    final counts = {for (final key in _trackedKeys) key: 0};
    for (final batch in batches) {
      final key = LivestockBreedCatalog.normalizeBreedKey(batch.breedType);
      if (counts.containsKey(key)) {
        counts[key] = counts[key]! + batch.currentCount;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flock Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 760
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _trackedKeys.map((key) {
                  final option = LivestockBreedCatalog.optionForKey(key);
                  return SizedBox(
                    width: width,
                    child: _PlumageTile(
                      label: _shortLabels[key]!,
                      count: counts[key]!,
                      color: option.color,
                      borderColor: option.borderColor,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VaccinationAlertsBanner extends StatelessWidget {
  final List<Batch> batches;

  const _VaccinationAlertsBanner({required this.batches});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final now = DateTime.now();
    final until = now.add(const Duration(days: 14));
    final batchNames = {for (final batch in batches) batch.id: batch.batchName};

    return StreamBuilder<List<VaccinationSchedule>>(
      stream: db.select(db.vaccinationSchedules).watch(),
      builder: (context, snapshot) {
        final alerts =
            (snapshot.data ?? const <VaccinationSchedule>[])
                .where(
                  (alert) =>
                      alert.status == 'PENDING' &&
                      !alert.scheduledDate.isBefore(now) &&
                      !alert.scheduledDate.isAfter(until),
                )
                .toList()
              ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vaccination Alerts',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (alerts.isEmpty)
                      const Text(
                        'No upcoming medical events in the next 14 days.',
                        style: TextStyle(color: Color(0xFF92400E)),
                      )
                    else
                      ...alerts.take(4).map((alert) {
                        final unit = batchNames[alert.batchId] ?? alert.batchId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${alert.vaccineName} due on $unit',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;
  final List<Widget> children;

  const _DataCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _BatchDropdown extends StatelessWidget {
  final List<Batch> batches;
  final String? value;
  final String label;
  final ValueChanged<String?> onChanged;

  const _BatchDropdown({
    required this.batches,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: batches.any((batch) => batch.id == value) ? value : null,
      isExpanded: true,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(context, label, Icons.home_work_rounded),
      items: batches
          .map(
            (batch) => DropdownMenuItem(
              value: batch.id,
              child: Text(
                '${batch.batchName} (${batch.currentCount} birds)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _FeedDropdown extends StatelessWidget {
  final AppDatabase db;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FeedDropdown({
    required this.db,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: (db.select(
        db.inventory,
      )..where((t) => t.category.equals(kFeedInventoryCategory))).watch(),
      builder: (context, snapshot) {
        final feeds = snapshot.data ?? const <InventoryItem>[];
        return DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: feeds.any((feed) => feed.id == value) ? value : null,
          isExpanded: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: _inputDecoration(
            context,
            'Feed item',
            Icons.inventory_2_rounded,
          ),
          items: feeds
              .map(
                (feed) => DropdownMenuItem(
                  value: feed.id,
                  child: Text(feed.itemName, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _NumberField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(context, label, Icons.pin_rounded),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool saving;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.saving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.icon(
        onPressed: saving ? null : onPressed,
        icon: saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _PlumageTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color borderColor;

  const _PlumageTile({
    required this.label,
    required this.count,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: borderColor == Colors.transparent
                    ? Colors.black12
                    : borderColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '$count birds',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF15803D), size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF166534),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  final SyncEngine syncEngine;
  final bool collapsed;

  const _SyncStatus({required this.syncEngine, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: syncEngine.syncStatus,
      initialData: syncEngine.isSyncing,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;
        return Tooltip(
          message: isSyncing ? 'Synchronizing data...' : 'Click to sync now',
          child: InkWell(
            onTap: isSyncing ? null : () => syncEngine.syncNow(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSyncing)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.cloud_done_rounded,
                      color: Color(0xFF22C55E),
                      size: 16,
                    ),
                  if (!collapsed) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isSyncing ? 'SYNCING...' : 'CLOUD SYNCED',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isSyncing
                              ? Colors.white70
                              : const Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: isDark ? Colors.white70 : const Color(0xFF475569),
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(
      icon,
      size: 18,
      color: isDark ? Colors.white54 : const Color(0xFF64748B),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFCBD5E1),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? Colors.white54 : const Color(0xFF10B981),
        width: 2,
      ),
    ),
    filled: true,
    fillColor: isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFFBFCFD),
    hintStyle: TextStyle(
      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

BoxDecoration _panelDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
