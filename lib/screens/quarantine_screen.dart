import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:rxdart/rxdart.dart';
import '../data/local_db.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/mortality_log_utils.dart';

class CombinedQuarantineLog {
  final Mortality mortality;
  final String batchName;
  final String originHouseName;
  CombinedQuarantineLog(this.mortality, this.batchName, this.originHouseName);
}

class ActiveQuarantineBatch {
  final Batch batch;
  final String originHouseName;
  ActiveQuarantineBatch(this.batch, this.originHouseName);
}

class ActiveBatchWithHouse {
  final Batch batch;
  final String houseName;
  ActiveBatchWithHouse(this.batch, this.houseName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveBatchWithHouse &&
          runtimeType == other.runtimeType &&
          batch.id == other.batch.id;

  @override
  int get hashCode => batch.id.hashCode;
}

class RoomWithOccupancy {
  final House room;
  final int occupancy;
  RoomWithOccupancy(this.room, this.occupancy);
}

class QuarantineScreen extends StatefulWidget {
  const QuarantineScreen({super.key});

  @override
  State<QuarantineScreen> createState() => _QuarantineScreenState();
}

class _QuarantineScreenState extends State<QuarantineScreen> {
  final Map<String, TextEditingController> _releaseControllers = {};
  final Map<String, TextEditingController> _deathControllers = {};
  final _roomNameController = TextEditingController();
  final _roomCapacityController = TextEditingController();

  // Isolation Form state
  final _isolationFormKey = GlobalKey<FormState>();
  final _isolateCountController = TextEditingController();
  final _isolateReasonController = TextEditingController();
  ActiveBatchWithHouse? _selectedSourceBatch;
  House? _selectedIsolationRoom;

  @override
  void dispose() {
    for (var ctrl in _releaseControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _deathControllers.values) {
      ctrl.dispose();
    }
    _roomNameController.dispose();
    _roomCapacityController.dispose();
    _isolateCountController.dispose();
    _isolateReasonController.dispose();
    super.dispose();
  }

  TextEditingController _getReleaseController(String id) {
    return _releaseControllers.putIfAbsent(id, () => TextEditingController());
  }

  TextEditingController _getDeathController(String id) {
    return _deathControllers.putIfAbsent(id, () => TextEditingController());
  }

  Stream<Map<String, int>> _getRoomOccupancyMap(AppDatabase db) {
    final batchesStream = (db.select(db.batches)..where((t) => t.status.equals('active') & t.isolationCount.isBiggerThanValue(0))).watch();
    final mortalitiesStream = (db.select(db.mortalities)
          ..where((t) => t.healthType.equals('SICK')))
        .watch();

    return Rx.combineLatest2(
      batchesStream,
      mortalitiesStream,
      (List<Batch> batches, List<Mortality> logs) {
        final Map<String, int> occupancy = {};
        for (final b in batches) {
          final batchLogs = logs.where((m) => m.batchId == b.id).toList()
            ..sort((a, b) => b.logDate.compareTo(a.logDate));
          
          final String room = batchLogs.isNotEmpty 
              ? (batchLogs.first.subCategory ?? 'General Quarantine Zone')
              : 'General Quarantine Zone';
          
          occupancy[room] = (occupancy[room] ?? 0) + b.isolationCount;
        }
        return occupancy;
      },
    );
  }

  Stream<List<RoomWithOccupancy>> _getRoomsWithOccupancy(AppDatabase db) {
    final roomsStream = (db.select(db.houses)..where((t) => t.isIsolation.equals(true))).watch();
    final occupancyStream = _getRoomOccupancyMap(db);

    return Rx.combineLatest2(
      roomsStream,
      occupancyStream,
      (List<House> rooms, Map<String, int> occupancyMap) {
        return rooms.map((r) {
          final occ = occupancyMap[r.name] ?? 0;
          return RoomWithOccupancy(r, occ);
        }).toList();
      },
    );
  }

  Stream<List<ActiveBatchWithHouse>> _getAllActiveBatchesWithHouse(AppDatabase db) {
    final batchesStream = (db.select(db.batches)..where((t) => t.status.equals('active'))).watch();
    final housesStream = db.select(db.houses).watch();

    return Rx.combineLatest2(
      batchesStream,
      housesStream,
      (List<Batch> batches, List<House> houses) {
        final houseMap = {for (var h in houses) h.id: h.name};
        return batches
            .map((b) => ActiveBatchWithHouse(b, houseMap[b.houseId] ?? 'General Unit'))
            .toList();
      },
    );
  }

  Stream<List<ActiveQuarantineBatch>> _getActiveQuarantineBatches(AppDatabase db) {
    final batchesStream = (db.select(db.batches)..where((t) => t.status.equals('active'))).watch();
    final housesStream = db.select(db.houses).watch();

    return Rx.combineLatest2(
      batchesStream,
      housesStream,
      (List<Batch> batches, List<House> houses) {
        final houseMap = {for (var h in houses) h.id: h.name};
        return batches
            .where((b) => b.isolationCount > 0)
            .map((b) => ActiveQuarantineBatch(b, houseMap[b.houseId] ?? 'General Unit'))
            .toList();
      },
    );
  }

  Stream<List<CombinedQuarantineLog>> _getCombinedQuarantineLogs(AppDatabase db) {
    final mortalitiesStream = (db.select(db.mortalities)
          ..where((t) => t.healthType.equals('SICK'))
          ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]))
        .watch();
    final batchesStream = db.select(db.batches).watch();
    final housesStream = db.select(db.houses).watch();

    return Rx.combineLatest3(
      mortalitiesStream,
      batchesStream,
      housesStream,
      (List<Mortality> mortalities, List<Batch> batches, List<House> houses) {
        final batchMap = {for (var b in batches) b.id: b};
        final houseMap = {for (var h in houses) h.id: h.name};
        return mortalities
            .map((m) {
              final batch = batchMap[m.batchId];
              final batchName = batch?.batchName ?? 'Unknown Unit';
              final originHouseName = batch?.houseId != null ? (houseMap[batch!.houseId] ?? 'General Unit') : 'General Unit';
              return CombinedQuarantineLog(m, batchName, originHouseName);
            })
            .toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Stats row — responsive via LayoutBuilder
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth < 1000
                    ? (constraints.maxWidth - 48) / 2  // 2 columns on medium
                    : (constraints.maxWidth - 48) / 3; // 3 columns on wide
                final clampedWidth = cardWidth.clamp(280.0, 500.0);
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    SizedBox(
                      width: clampedWidth,
                      child: _buildCurrentlyIsolatedCard(db),
                    ),
                    SizedBox(
                      width: clampedWidth,
                      child: _buildCapacityUtilizationCard(db),
                    ),
                    SizedBox(
                      width: clampedWidth,
                      child: _buildBiosecurityTipCard(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // New Isolation Form
            _buildSectionHeader(
              icon: Icons.add_circle_outline,
              title: 'LOG NEW ISOLATION',
              subtitle: 'Select source unit and move birds to a quarantine room.',
              iconColor: Colors.redAccent,
              isLarge: true,
            ),
            const SizedBox(height: 16),
            _buildNewIsolationAction(context, db),
            const SizedBox(height: 40),

            // Active Quarantine Management (Recover / Log death in isolation)
            _buildSectionHeader(
              icon: Icons.health_and_safety_outlined,
              title: 'ACTIVE QUARANTINE BAYS & RECOVERY ACTIONS',
              iconColor: Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildActiveQuarantineList(db),
            const SizedBox(height: 48),

            // Custom Isolation Rooms configuration
            _buildSectionHeader(
              icon: Icons.home_work_outlined,
              title: 'CONFIGURED ISOLATION ROOMS',
              subtitle: 'Setup physical quarantine structures on your farm premises.',
              iconColor: Colors.tealAccent.shade700,
              isLarge: true,
            ),
            const SizedBox(height: 24),
            _buildIsolationRoomsSection(db),
            const SizedBox(height: 48),

            // Quarantine Historic Logs Table
            _buildSectionHeader(
              icon: Icons.history_rounded,
              title: 'QUARANTINE HISTORIC ENTRY LOGS',
              iconColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            _buildQuarantineLogsTable(db),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety_outlined, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
                children: [
                  TextSpan(text: 'QUARANTINE & ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(text: 'ISOLATION', style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Manage physical isolation houses, recover birds back to flock, or track active treatment quarantines.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCurrentlyIsolatedCard(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Batch>>(
      stream: db.select(db.batches).watch(),
      builder: (context, snapshot) {
        final totalIsolated = snapshot.data?.fold<int>(0, (sum, b) => sum + b.isolationCount) ?? 0;
        return Container(
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.amber.shade900.withValues(alpha: 0.8), Colors.amber.shade800.withValues(alpha: 0.4)]
                  : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark
                    ? Colors.amber.shade700.withValues(alpha: 0.3)
                    : Colors.amber.shade200.withValues(alpha: 0.5)),
            boxShadow: isDark
                ? []
                : [BoxShadow(color: Colors.amber.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.sick_outlined, size: 100, color: Colors.white.withValues(alpha: 0.1)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENTLY IN ISOLATION',
                    style: TextStyle(
                        color: isDark ? Colors.amberAccent : Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('#,###').format(totalIsolated),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('sick / injured', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Separated from the healthy flock',
                    style: TextStyle(
                        color: isDark ? Colors.amber.shade300 : Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCapacityUtilizationCard(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<House>>(
      stream: (db.select(db.houses)..where((t) => t.isIsolation.equals(true))).watch(),
      builder: (context, roomsSnap) {
        final totalCapacity = roomsSnap.data?.fold<int>(0, (sum, h) => sum + h.capacity) ?? 0;

        return StreamBuilder<List<Batch>>(
          stream: db.select(db.batches).watch(),
          builder: (context, batchSnap) {
            final totalIsolated = batchSnap.data?.fold<int>(0, (sum, b) => sum + b.isolationCount) ?? 0;
            final countText = totalCapacity > 0 ? '$totalIsolated / $totalCapacity birds' : '$totalIsolated birds';
            final rate = totalCapacity > 0 ? (totalIsolated / totalCapacity) * 100 : 0.0;

            return Container(
              constraints: const BoxConstraints(minHeight: 160, maxHeight: 200),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROOM CAPACITY UTILIZATION',
                    style: TextStyle(
                        color: isDark ? Colors.amberAccent : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    countText,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalCapacity > 0 ? (totalIsolated / totalCapacity).clamp(0.0, 1.0) : 0.0,
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(rate > 90 ? Colors.redAccent : Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalCapacity > 0 ? '${rate.toStringAsFixed(1)}% Capacity Occupied' : 'No isolation bays configured',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBiosecurityTipCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 220),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.green.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                'QUARANTINE RULES',
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Always attend to isolated sick birds AFTER feeding and caring for healthy flocks. Footbaths must be used at quarantine entrances.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: isLarge ? 24 : 18),
            const SizedBox(width: 12),
            Text(
              isLarge ? title : title.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: isLarge ? 20 : 13,
                letterSpacing: isLarge ? 0 : 1,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildActiveQuarantineList(AppDatabase db) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<ActiveQuarantineBatch>>(
      stream: _getActiveQuarantineBatches(db),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'No birds currently flagged for isolation on this farm!',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => Divider(color: colorScheme.outline.withValues(alpha: 0.05), height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final batch = item.batch;
              final originHouseName = item.originHouseName;
              final releaseCtrl = _getReleaseController(batch.id);
              final deathCtrl = _getDeathController(batch.id);

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(batch.batchName,
                              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Origin Unit: $originHouseName',
                              style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '${batch.isolationCount} Sick Birds Isolated',
                                  style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action 1: Recover / Release
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: releaseCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Qty',
                              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65), fontWeight: FontWeight.w600),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _releaseBirds(db, batch, releaseCtrl),
                          icon: const Icon(Icons.healing_rounded, size: 14),
                          label: const Text('RELEASE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    // Action 2: Died in isolation
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: deathCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Qty',
                              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65), fontWeight: FontWeight.w600),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _recordDeathInIsolation(db, batch, deathCtrl),
                          icon: const Icon(Icons.dangerous_outlined, size: 14),
                          label: const Text('LOG LOSS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildIsolationRoomsSection(AppDatabase db) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1000;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCreateRoomCard(db),
              const SizedBox(height: 24),
              _buildIsolationRoomsGrid(db),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildCreateRoomCard(db),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: _buildIsolationRoomsGrid(db),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateRoomCard(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Create New Isolation Bay'.toUpperCase(),
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('ROOM NAME / CODE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _roomNameController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: _roomInputDecoration('e.g. Isolation Bay A'),
          ),
          const SizedBox(height: 20),
          Text('MAX CAPACITY', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _roomCapacityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: _roomInputDecoration('e.g. 50 birds'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _createIsolationRoom(db),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CONFIRM CREATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _roomInputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1))),
    );
  }

  Widget _buildIsolationRoomsGrid(AppDatabase db) {
    return StreamBuilder<List<RoomWithOccupancy>>(
      stream: _getRoomsWithOccupancy(db),
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? [];
        if (rooms.isEmpty) {
          return Container(
            height: 320,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1), style: BorderStyle.solid),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No dedicated isolation rooms configured yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 110,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final item = rooms[index];
            final room = item.room;
            final occupancy = item.occupancy;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final rate = room.capacity > 0 ? occupancy / room.capacity : 0.0;
            final isFull = rate >= 1.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isFull ? Colors.redAccent.withValues(alpha: 0.4) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFull ? Colors.redAccent.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.house_rounded, color: isFull ? Colors.redAccent : Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          room.name, 
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Occupancy: $occupancy / ${room.capacity} birds', 
                          style: TextStyle(
                            color: isFull ? Colors.redAccent : Theme.of(context).colorScheme.onSurfaceVariant, 
                            fontSize: 11,
                            fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: rate.clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(isFull ? Colors.redAccent : Colors.amber),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _deleteRoom(db, room),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuarantineLogsTable(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<CombinedQuarantineLog>>(
      stream: _getCombinedQuarantineLogs(db),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }
        final logs = snapshot.data!;

        if (logs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Text(
                'No quarantine events logged yet.',
                style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Container(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('ISOLATION DATE',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('SOURCE BATCH',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('QUARANTINE ZONE',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('QTY ISOLATED',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('SYMPTOMS / DIAGNOSIS NOTES',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
              // Data rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.05)),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(log.mortality.logDate);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            formattedDate,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                log.batchName,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Origin: ${log.originHouseName}',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Icon(Icons.house_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  log.mortality.subCategory ?? 'General Zone',
                                  style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${log.mortality.count} sick',
                                style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            log.mortality.reason ?? 'N/A',
                            style: TextStyle(
                              color: log.mortality.reason != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: 13.5,
                              fontStyle: log.mortality.reason == null ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _releaseBirds(AppDatabase db, Batch batch, TextEditingController controller) async {
    final count = int.tryParse(controller.text) ?? 0;
    if (count <= 0) return;

    if (count > batch.isolationCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot release more birds than the currently isolated size.'),
          backgroundColor: Colors.orange,
        ));
      }
      return;
    }

    try {
      await db.transaction(() async {
        // Update batch counts: return birds from isolation back to healthy flock
        await (db.update(db.batches)..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            currentCount: Value(batch.currentCount + count),
            isolationCount: Value(batch.isolationCount - count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });

      controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Successfully recovered and released $count birds back to the active flock!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _recordDeathInIsolation(AppDatabase db, Batch batch, TextEditingController controller) async {
    final count = int.tryParse(controller.text) ?? 0;
    if (count <= 0) return;

    if (count > batch.isolationCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot log deaths exceeding isolated flock size.'),
          backgroundColor: Colors.orange,
        ));
      }
      return;
    }

    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) return;

    try {
      await db.transaction(() async {
        // 1. Log mortality
        await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: batch.id,
              count: count,
              logDate: DateTime.now(),
              healthType: const Value('DEAD'),
              category: const Value(isolationMortalityCategory),
              subCategory: const Value(isolationMortalitySubCategory),
              reason: const Value('Died inside quarantine isolation room'),
              userId: Value(workerId),
              synced: const Value(false),
            ));

        // 2. Decrement isolationCount (do not touch currentCount since isolated birds were already deducted from active flock)
        await (db.update(db.batches)..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            isolationCount: Value(batch.isolationCount - count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });

      controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Logged loss of $count birds inside quarantine. Count successfully adjusted.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _createIsolationRoom(AppDatabase db) async {
    final name = _roomNameController.text.trim();
    final capacity = int.tryParse(_roomCapacityController.text) ?? 0;

    if (name.isEmpty || capacity <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a valid room name and max capacity (must be greater than 0)'),
          backgroundColor: Colors.orange,
        ));
      }
      return;
    }

    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) return;

    try {
      await db.into(db.houses).insert(HousesCompanion.insert(
            id: newLocalId(),
            farmId: farmId,
            name: name,
            capacity: capacity,
            userId: Value(workerId),
            isIsolation: const Value(true),
            synced: const Value(false),
          ));

      _roomNameController.clear();
      _roomCapacityController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('New isolation room created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteRoom(AppDatabase db, House room) async {
    try {
      await (db.delete(db.houses)..where((t) => t.id.equals(room.id))).go();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Isolation room deleted'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildNewIsolationAction(BuildContext context, AppDatabase db) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _isolationFormKey,
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            // 1. Source Batch Selection
            SizedBox(
              width: 300,
              child: StreamBuilder<List<ActiveBatchWithHouse>>(
                stream: _getAllActiveBatchesWithHouse(db),
                builder: (context, snapshot) {
                  final batches = snapshot.data ?? [];
                  // Reset selection if it no longer exists in the current list
                  final validSelection = _selectedSourceBatch != null &&
                      batches.any((b) => b.batch.id == _selectedSourceBatch!.batch.id)
                      ? batches.firstWhere((b) => b.batch.id == _selectedSourceBatch!.batch.id)
                      : null;
                  if (validSelection != _selectedSourceBatch) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedSourceBatch = validSelection);
                    });
                  }
                  return DropdownButtonFormField<ActiveBatchWithHouse>(
                    decoration: _inputDecoration(context, 'Source House / Unit', Icons.storefront_outlined),
                    initialValue: validSelection,
                    isExpanded: true,
                    items: batches.map((b) {
                      return DropdownMenuItem(
                        value: b,
                        child: Text(
                          '${b.houseName} - ${b.batch.batchName} (${b.batch.currentCount} active)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSourceBatch = val),
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
              ),
            ),
            // 2. Count
            SizedBox(
              width: 150,
              child: TextFormField(
                controller: _isolateCountController,
                decoration: _inputDecoration(context, 'Qty Isolated', Icons.numbers_outlined),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  final num = int.tryParse(val);
                  if (num == null || num <= 0) return 'Invalid';
                  if (_selectedSourceBatch != null && num > _selectedSourceBatch!.batch.currentCount) {
                    return 'Exceeds active';
                  }
                  return null;
                },
              ),
            ),
            // 3. Destination Room
            SizedBox(
              width: 300,
              child: StreamBuilder<List<RoomWithOccupancy>>(
                stream: _getRoomsWithOccupancy(db),
                builder: (context, snapshot) {
                  final rooms = snapshot.data ?? [];
                  return DropdownButtonFormField<House>(
                    decoration: _inputDecoration(context, 'Target Isolation Room', Icons.health_and_safety_outlined),
                    initialValue: _selectedIsolationRoom,
                    isExpanded: true,
                    items: rooms.map((r) {
                      final isFull = r.occupancy >= r.room.capacity;
                      return DropdownMenuItem(
                        value: r.room,
                        enabled: !isFull,
                        child: Text(
                          '${r.room.name} (${r.occupancy}/${r.room.capacity})',
                          style: TextStyle(color: isFull ? Colors.redAccent : null),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedIsolationRoom = val),
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
              ),
            ),
            // 4. Symptoms / Reason
            SizedBox(
              width: 350,
              child: TextFormField(
                controller: _isolateReasonController,
                decoration: _inputDecoration(context, 'Symptoms / Reason', Icons.description_outlined),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ),
            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _submitNewIsolation(db),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('ISOLATE BIRDS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54, size: 20),
      filled: true,
      fillColor: isDark ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
    );
  }

  Future<void> _submitNewIsolation(AppDatabase db) async {
    if (!_isolationFormKey.currentState!.validate()) return;
    
    final count = int.parse(_isolateCountController.text);
    final batch = _selectedSourceBatch!.batch;
    final room = _selectedIsolationRoom!;
    final reason = _isolateReasonController.text;
    final farmId = await FarmUtils.getBoundFarmId();
    final workerId = await FarmUtils.getRequiredUserId();
    if (farmId == null) return;

    // Check capacity again
    final occupancyStream = await _getRoomOccupancyMap(db).first;
    final currentOccupancy = occupancyStream[room.name] ?? 0;
    if (currentOccupancy + count > room.capacity) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Not enough capacity in selected isolation room!'),
          backgroundColor: Colors.orange,
        ));
      }
      return;
    }

    try {
      await db.transaction(() async {
        await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
          id: newLocalId(),
          farmId: farmId,
          batchId: batch.id,
          count: count,
          logDate: DateTime.now(),
          healthType: const Value('SICK'),
          category: const Value('Disease'),
          subCategory: Value(reason.trim().isEmpty ? 'Unknown cause yet' : reason.trim()),
          reason: Value(reason),
          isolationRoomId: Value(room.id),
          userId: Value(workerId),
          synced: const Value(false),
        ));

        await (db.update(db.batches)..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            currentCount: Value(batch.currentCount - count),
            isolationCount: Value(batch.isolationCount + count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });

      setState(() {
        _isolateCountController.clear();
        _isolateReasonController.clear();
        _selectedSourceBatch = null;
        _selectedIsolationRoom = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Isolation record added successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
