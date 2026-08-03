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

class CombinedMortalityLog {
  final Mortality mortality;
  final String batchName;
  CombinedMortalityLog(this.mortality, this.batchName);
}

class MortalityScreen extends StatefulWidget {
  const MortalityScreen({super.key});

  @override
  State<MortalityScreen> createState() => _MortalityScreenState();
}

class _MortalityScreenState extends State<MortalityScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String id) {
    return _controllers.putIfAbsent(id, () => TextEditingController());
  }

  Stream<List<CombinedMortalityLog>> _getCombinedLogs(AppDatabase db) {
    final mortalitiesStream = (db.select(db.mortalities)
          ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]))
        .watch();
    final batchesStream = db.select(db.batches).watch();

    return Rx.combineLatest2(
      mortalitiesStream,
      batchesStream,
      (List<Mortality> mortalities, List<Batch> batches) {
        final batchMap = {for (var b in batches) b.id: b.batchName};
        return mortalities
            .where(
              (m) => isDeadMortalityRecord(
                healthType: m.healthType,
                category: m.category,
              ),
            )
            .map((m) => CombinedMortalityLog(m, batchMap[m.batchId] ?? 'Unknown Unit'))
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

            // Health Alert Banner
            _buildHealthAlerts(db),

            // Stats row — responsive via LayoutBuilder
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth < 1000
                    ? (constraints.maxWidth - 48) / 2
                    : (constraints.maxWidth - 48) / 3;
                final clampedWidth = cardWidth.clamp(280.0, 500.0);
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    SizedBox(
                      width: clampedWidth,
                      child: _buildTotalDeathsCard(db),
                    ),
                    SizedBox(
                      width: clampedWidth,
                      child: _buildHealthTipCard(),
                    ),
                    SizedBox(
                      width: clampedWidth,
                      child: _buildVetsCard(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // Quick Mortality Logging
            _buildSectionHeader(
              icon: Icons.add_alert_rounded,
              title: 'QUICK MORTALITY LOGGING',
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            _buildQuickLoggingList(db),
            const SizedBox(height: 48),

            // Mortality History Table
            _buildSectionHeader(
              icon: Icons.history_rounded,
              title: 'MORTALITY LOG HISTORY',
              iconColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            _buildHistoryTable(db),
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
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dangerous_outlined, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
                children: [
                  TextSpan(text: 'MORTALITY ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  TextSpan(text: 'TRACKING', style: TextStyle(color: Colors.red.shade400, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Log, track, and monitor livestock deaths to detect early biosecurity threats.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildHealthAlerts(AppDatabase db) {
    return StreamBuilder<List<Batch>>(
      stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
      builder: (context, batchSnap) {
        if (!batchSnap.hasData) return const SizedBox.shrink();
        final batches = batchSnap.data!;

        return StreamBuilder<List<Mortality>>(
          stream: db.select(db.mortalities).watch(),
          builder: (context, mortSnap) {
            if (!mortSnap.hasData) return const SizedBox.shrink();
            final mortalities = mortSnap.data!;
            final now = DateTime.now();
            final oneDayAgo = now.subtract(const Duration(hours: 24));

            final alerts = <String>[];
            for (var batch in batches) {
              final last24hCount = mortalities
                  .where(
                    (m) =>
                        m.batchId == batch.id &&
                        m.logDate.isAfter(oneDayAgo) &&
                        isDeadMortalityRecord(
                          healthType: m.healthType,
                          category: m.category,
                        ),
                  )
                  .fold<int>(0, (sum, m) => sum + m.count);

              if (last24hCount > 0 && batch.currentCount > 0) {
                final rate = (last24hCount / (batch.currentCount + last24hCount)) * 100;
                if (rate >= 1.0) {
                  alerts.add('${batch.batchName} has lost $last24hCount birds (${rate.toStringAsFixed(1)}% rate) in the last 24 hours!');
                }
              }
            }

            if (alerts.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CRITICAL HEALTH ALERTS DETECTED',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        ...alerts.map((alert) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $alert',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalDeathsCard(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Mortality>>(
      stream: db.select(db.mortalities).watch(),
      builder: (context, snapshot) {
        final total = snapshot.data
                ?.where(
                  (m) => isDeadMortalityRecord(
                    healthType: m.healthType,
                    category: m.category,
                  ),
                )
                .fold<int>(0, (sum, m) => sum + m.count) ??
            0;
        return Container(
          constraints: const BoxConstraints(minHeight: 160, maxHeight: 210),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.red.shade900.withValues(alpha: 0.8), Colors.red.shade800.withValues(alpha: 0.4)]
                  : [const Color(0xFFEF4444), const Color(0xFFF87171)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark
                    ? Colors.red.shade700.withValues(alpha: 0.3)
                    : Colors.red.shade200.withValues(alpha: 0.5)),
            boxShadow: isDark
                ? []
                : [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.cancel_outlined, size: 100, color: Colors.white.withValues(alpha: 0.1)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL HISTORIC DEATHS',
                    style: TextStyle(
                        color: isDark ? Colors.redAccent : Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('#,###').format(total),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('birds', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Across all active & archived batches',
                    style: TextStyle(
                        color: isDark ? Colors.red.shade300 : Colors.white.withValues(alpha: 0.7),
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

  Widget _buildHealthTipCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 210),
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
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                'BIOSECURITY TIP',
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
            'Keep detailed reason logs. If a mortality event occurs with neurological signs or facial swelling, isolate immediately and restrict farm entry.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVetsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 210),
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
              Icon(Icons.local_hospital_rounded, color: Colors.red.shade400, size: 18),
              const SizedBox(width: 8),
              Text(
                'VETERINARY DIRECTORY',
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone_rounded, color: Colors.green.shade400, size: 16),
              const SizedBox(width: 8),
              Text(
                '+233 (0) 555-BIOLAB',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Call our district veterinary officers for prompt diagnostic assistance and post-mortem verification.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLoggingList(AppDatabase db) {
    return StreamBuilder<List<Batch>>(
      stream: (db.select(db.batches)..where((t) => t.status.equals('active'))).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
        }
        final batches = snapshot.data!;
        if (batches.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Text(
                'No active units to log mortality for.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: batches.length,
            separatorBuilder: (_, _) => Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05), height: 1),
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(batch.batchName,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            '${batch.currentCount} ${batch.type.toLowerCase().replaceAll('poultry_', '')} remaining (${batch.isolationCount} isolated)',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _getController(batch.id),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Lost',
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _submitMortality(db, batch),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('LOG LOSS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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

  Widget _buildHistoryTable(AppDatabase db) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<CombinedMortalityLog>>(
      stream: _getCombinedLogs(db),
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
                'No mortality logs recorded yet.',
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
              // Table Header Row
              Container(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('LOG DATE / TIME',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('BATCH NAME',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('LOSS COUNT',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('REASON / NOTES',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
              // Table List Data Rows
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
                          child: Text(
                            log.batchName,
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '-${log.mortality.count}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w800),
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

  Future<void> _submitMortality(AppDatabase db, Batch batch) async {
    final controller = _getController(batch.id);
    final count = int.tryParse(controller.text) ?? 0;

    if (count <= 0) return;

    if (count > batch.currentCount) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cannot log loss exceeding current batch flock size.'),
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
        // 1. Insert mortality record
        await db.into(db.mortalities).insert(MortalitiesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: batch.id,
              count: count,
              logDate: DateTime.now(),
              healthType: const Value('DEAD'),
              category: const Value('Unknown'),
              subCategory: const Value('Unknown cause yet'),
              userId: Value(workerId),
              synced: const Value(false),
            ));

        // 2. Update batch currentCount
        await (db.update(db.batches)..where((t) => t.id.equals(batch.id))).write(
          BatchesCompanion(
            currentCount: Value(batch.currentCount - count),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
      });

      controller.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mortality logged successfully'),
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
