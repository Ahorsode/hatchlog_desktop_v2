import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../widgets/register_unit_dialog.dart';
import '../widgets/batch_actions_dialogs.dart';
import 'batch_details_screen.dart';
import '../utils/id_utils.dart';
import '../utils/livestock_breed_options.dart';
import '../utils/growth_utils.dart';
import '../widgets/worker_stamp.dart';
import '../widgets/financial_init_wizard.dart';
import '../utils/worker_permissions_loader.dart';
import 'comparative_analytics_screen.dart';

class LivestockManager extends StatefulWidget {
  const LivestockManager({super.key});

  @override
  State<LivestockManager> createState() => _LivestockManagerState();
}

class _LivestockManagerState extends State<LivestockManager> {
  String _selectedFilter = 'All';
  String _lifecycleFilter = 'Active';
  bool _canEditBatches = true;
  bool _checkedFinancialInit = false;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = context.read<AppDatabase>();
      final permissions = await loadWorkerPermissions(db);
      if (!mounted) return;
      final role = (await SharedPreferences.getInstance()).getString('user_role');
      final normalized = (role ?? 'OWNER').toUpperCase();
      setState(() {
        _canEditBatches = normalized == 'OWNER' ||
            normalized == 'MANAGER' ||
            permissions.contains('can_edit_batches');
      });
      if (!_checkedFinancialInit && mounted) {
        _checkedFinancialInit = true;
        await FinancialInitWizard.promptIfNeeded(context);
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 900;
          return Column(
            children: [
              // ── Header ──
              _buildHeader(context, db, cs, isCompact),

              // ── Body ──
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 16.0 : 28.0),
                  child: Column(
                    children: [
                      // Filter chips
                      _buildFilterRow(cs),
                      const SizedBox(height: 12),
                      _buildLifecycleRow(cs),
                      const SizedBox(height: 12),
                      _buildMissingCostBanner(db, cs),
                      const SizedBox(height: 12),

                      // Table
                      Expanded(child: _buildTableCard(db, cs, isCompact)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────
  //  HEADER
  // ────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    AppDatabase db,
    ColorScheme cs,
    bool isCompact,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isCompact ? 16 : 32,
        isCompact ? 20 : 32,
        isCompact ? 16 : 32,
        isCompact ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 16,
        children: [
          // Title block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Livestock ',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isCompact ? 22 : 30,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: isCompact ? 22 : 30,
                        color: const Color(0xFF10B981),
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIFECYCLE & PERFORMANCE TRACKING',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ComparativeAnalyticsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: Text(
                  isCompact ? 'REPORTS' : 'PERFORMANCE REPORTS',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  side: BorderSide(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _canEditBatches
                    ? () => _showAddBatchDialog(context, db)
                    : null,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  isCompact ? 'ADD' : 'ADD UNIT',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleRow(ColorScheme cs) {
    const filters = ['Active', 'Inactive', 'All'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = _lifecycleFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: selected,
              onSelected: (_) => setState(() => _lifecycleFilter = f),
              selectedColor: const Color(0xFF10B981),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMissingCostBanner(AppDatabase db, ColorScheme cs) {
    return StreamBuilder<List<Batch>>(
      stream: (db.select(db.batches)..where((t) => t.status.equals('active')))
          .watch(),
      builder: (context, snapshot) {
        final missing = (snapshot.data ?? [])
            .where((batch) => (batch.initialActualCost ?? 0) <= 0)
            .toList();
        if (missing.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${missing.length} active batch(es) are missing initial cost. Accurate profit reporting requires financial setup.',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (_canEditBatches)
                TextButton(
                  onPressed: () async {
                    await FinancialInitWizard.promptIfNeeded(context);
                  },
                  child: const Text('Set up now'),
                ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  //  FILTER ROW
  // ────────────────────────────────────────────
  Widget _buildFilterRow(ColorScheme cs) {
    const filters = ['All', 'Poultry', 'Cattle', 'Pig', 'Sheep', 'Other'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              label: Text(
                f,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
              avatar: selected
                  ? null
                  : Icon(_filterIcon(f), size: 16, color: cs.onSurfaceVariant),
              selectedColor: const Color(0xFF10B981),
              backgroundColor: cs.surfaceContainerLowest,
              side: BorderSide(
                color: selected ? Colors.transparent : cs.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _filterIcon(String label) {
    return switch (label) {
      'All' => Icons.select_all_rounded,
      'Poultry' => Icons.flutter_dash_rounded,
      'Cattle' => Icons.grass_rounded,
      'Pig' => Icons.set_meal_rounded,
      'Sheep' => Icons.waves_rounded,
      _ => Icons.category_outlined,
    };
  }

  // ────────────────────────────────────────────
  //  TABLE CARD
  // ────────────────────────────────────────────
  Widget _buildTableCard(AppDatabase db, ColorScheme cs, bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<List<Batch>>(
        stream: db.select(db.batches).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }
          final allBatches = snapshot.data!;
          if (allBatches.isEmpty) return _buildEmptyState(context, db, cs);

          return StreamBuilder<List<Mortality>>(
            stream: db.select(db.mortalities).watch(),
            builder: (context, mortSnapshot) {
              final mortalities = mortSnapshot.data ?? [];
              final mortalityMap = <String, int>{};
              for (var m in mortalities) {
                mortalityMap[m.batchId] =
                    (mortalityMap[m.batchId] ?? 0) + m.count;
              }

              final batches = _applyFilter(allBatches);

              return LayoutBuilder(
                builder: (context, tableConstraints) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(
                          cs.primary.withValues(alpha: 0.5),
                        ),
                        thickness: WidgetStateProperty.all(8),
                        radius: const Radius.circular(4),
                      ),
                    ),
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      notificationPredicate: (n) => n.depth == 1,
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        notificationPredicate: (n) => n.depth == 0,
                        child: SizedBox(
                          height: tableConstraints.maxHeight,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              controller: _verticalController,
                              scrollDirection: Axis.vertical,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: tableConstraints.maxWidth > 1200
                                      ? tableConstraints.maxWidth
                                      : 1200,
                                  minHeight: tableConstraints.maxHeight,
                                ),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                    isDark
                                        ? const Color(0xFF121417)
                                        : const Color(0xFF1E293B),
                                  ),
                                  headingRowHeight: 52,
                                  dataRowMinHeight: 72,
                                  dataRowMaxHeight: 72,
                                  horizontalMargin: 20,
                                  columnSpacing: 24,
                                  columns: [
                                    _col('#'),
                                    _col('UNIT NAME / IDENTITY'),
                                    _col('TYPE & SPECIES'),
                                    _col('WORKER STAMPS'),
                                    _col('NO. COUNT'),
                                    _col('ARRIVAL DATE'),
                                    _col('STATUS'),
                                    _col('ACTIONS'),
                                  ],
                                  rows: batches.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final batch = entry.value;
                                    return _row(
                                      batch,
                                      index,
                                      db,
                                      cs,
                                      mortalityMap[batch.id] ?? 0,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Batch> _applyFilter(List<Batch> batches) {
    Iterable<Batch> filtered = batches;

    filtered = switch (_lifecycleFilter) {
      'Active' => filtered.where(
          (b) => b.status.toLowerCase() == 'active',
        ),
      'Inactive' => filtered.where(
          (b) => b.status.toLowerCase() != 'active',
        ),
      _ => filtered,
    };

    if (_selectedFilter != 'All') {
      filtered = filtered.where((b) {
        final type = b.type.toUpperCase();
        return switch (_selectedFilter) {
          'Poultry' => type.startsWith('POULTRY'),
          'Cattle' => type == 'CATTLE',
          'Pig' => type == 'PIG',
          'Sheep' => type == 'SHEEP_GOAT',
          'Other' => type == 'OTHER',
          _ => true,
        };
      });
    }

    return filtered.toList();
  }

  DataColumn _col(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _getBatchTypeLabel(String type) {
    return formatLivestockType(type);
  }

  DataRow _row(
    Batch batch,
    int index,
    AppDatabase db,
    ColorScheme cs,
    int totalMortality,
  ) {
    final arrivalDate = DateFormat('dd MMM yyyy').format(batch.arrivalDate);
    final typeLabel = _getBatchTypeLabel(batch.type);
    final breed = LivestockBreedCatalog.labelForKey(batch.breedType);

    return DataRow(
      cells: [
        // Index
        DataCell(
          Text(
            '${index + 1}',
            style: TextStyle(
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        // Unit name / Identity
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batch.batchName,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Color(0xFF10B981),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Type & Species
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                typeLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              Text(
                breed,
                style: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Worker Stamps
        DataCell(
          batch.userId == null || batch.userId!.isEmpty
              ? Text(
                  '—',
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                )
              : WorkerStamp(
                  color: const Color(0xFF3B82F6),
                  fullName: 'Batch Operator',
                  position: batch.userId!.length > 8
                      ? batch.userId!.substring(0, 8)
                      : batch.userId!,
                ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NumberFormat('#,###').format(batch.currentCount),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              if (batch.isolationCount > 0 ||
                  (batch.initialCount -
                          batch.currentCount -
                          batch.isolationCount) >
                      0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (batch.isolationCount > 0)
                        _countBadge(
                          '${batch.isolationCount} ISO',
                          const Color(0xFFD97706),
                          const Color(0xFFFFFBEB),
                        ),
                      if (batch.initialCount -
                              batch.currentCount -
                              batch.isolationCount >
                          0)
                        _countBadge(
                          '${batch.initialCount - batch.currentCount - batch.isolationCount} DEAD',
                          const Color(0xFFB91C1C),
                          const Color(0xFFFEF2F2),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Arrival Date
        DataCell(
          Text(
            arrivalDate,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        // Status
        DataCell(_statusChip(batch.status)),
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _manageBtn(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BatchDetailsScreen(batch: batch),
                  ),
                );
              }),
              const SizedBox(width: 8),
              _iconAction(
                Icons.coronavirus_outlined,
                const Color(0xFFEF4444),
                'Mortality',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => MortalityDialog(batch: batch),
                  );
                },
              ),
              const SizedBox(width: 8),
              _iconAction(
                Icons.shopping_cart_outlined,
                const Color(0xFF10B981),
                'Sales',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => QuickSaleDialog(batch: batch),
                  );
                },
              ),
              const SizedBox(width: 8),
              if (_canEditBatches) ...[
                _iconAction(
                  Icons.edit_outlined,
                  const Color(0xFF3B82F6),
                  'Edit',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => EditBatchDialog(batch: batch),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _iconAction(
                  Icons.delete_outline_rounded,
                  const Color(0xFF94A3B8),
                  'Delete',
                  onTap: () => _confirmDelete(batch, db),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _countBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _manageBtn(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 14,
              color: Color(0xFF10B981),
            ),
            const SizedBox(width: 6),
            const Text(
              'MANAGE',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction(
    IconData icon,
    Color color,
    String tooltip, {
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ────────────────────────────────────────────
  //  STATUS CHIP
  // ────────────────────────────────────────────
  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? const Color(0xFF10B981) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────
  //  DELETE CONFIRMATION
  // ────────────────────────────────────────────
  Future<void> _confirmDelete(Batch batch, AppDatabase db) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Delete Batch',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Are you sure you want to permanently delete ',
              ),
              TextSpan(
                text: batch.batchName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEF4444),
                ),
              ),
              const TextSpan(
                text:
                    '?\n\nThis will also remove all associated feeding, mortality, and production records.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'DELETE',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (batch.synced) {
        await db
            .into(db.pendingDeletions)
            .insert(
              PendingDeletionsCompanion.insert(
                id: newLocalId(),
                targetTableName: 'batches',
                recordId: batch.id,
                farmId: batch.farmId,
              ),
            );
      }

      await (db.delete(db.batches)..where((t) => t.id.equals(batch.id))).go();

      // Trigger sync in background
      if (mounted) {
        context.read<SyncEngine>().performSync();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${batch.batchName} deleted'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ────────────────────────────────────────────
  //  EMPTY STATE
  // ────────────────────────────────────────────
  Widget _buildEmptyState(
    BuildContext context,
    AppDatabase db,
    ColorScheme cs,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Livestock Units Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Register your first batch to start tracking.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showAddBatchDialog(context, db),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Register First Unit',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  //  DIALOG LAUNCHER
  // ────────────────────────────────────────────
  Future<void> _showAddBatchDialog(BuildContext context, AppDatabase db) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegisterUnitDialog(),
    );
  }
}
