import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../utils/farm_utils.dart';

class ClimateScreen extends StatelessWidget {
  const ClimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<String?>(
        future: FarmUtils.getBoundFarmId(),
        builder: (context, farmSnapshot) {
          final farmId = farmSnapshot.data;
          if (farmSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (farmId == null) {
            return _emptyShell(
              context,
              'No farm is bound to this device.',
              Icons.home_work_outlined,
            );
          }

          final query = db.select(db.houses)
            ..where((h) => h.farmId.equals(farmId))
            ..orderBy([(h) => OrderingTerm.asc(h.name)]);

          return StreamBuilder<List<House>>(
            stream: query.watch(),
            builder: (context, snapshot) {
              final houses = snapshot.data ?? const <House>[];
              final lastUpdated = houses.isEmpty
                  ? null
                  : houses
                        .map((h) => h.updatedAt)
                        .reduce((a, b) => a.isAfter(b) ? a : b);

              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Climate Monitor',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Environmental status per house',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _InfoPill(
                          icon: Icons.update_rounded,
                          label: lastUpdated == null
                              ? 'No readings yet'
                              : 'Updated ${DateFormat('MMM d, HH:mm').format(lastUpdated)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: houses.isEmpty
                          ? _emptyShell(
                              context,
                              'No houses registered. Add houses in the Houses screen to start monitoring.',
                              Icons.thermostat_rounded,
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final columns = width >= 1200
                                    ? 3
                                    : width >= 760
                                    ? 2
                                    : 1;
                                final gap = 18.0;
                                final cardWidth =
                                    (width - (gap * (columns - 1))) / columns;

                                return SingleChildScrollView(
                                  child: Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      for (final house in houses)
                                        SizedBox(
                                          width: cardWidth,
                                          child: _ClimateHouseCard(
                                            db: db,
                                            house: house,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyShell(BuildContext context, String message, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outline.withValues(alpha: 0.16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClimateHouseCard extends StatelessWidget {
  final AppDatabase db;
  final House house;

  const _ClimateHouseCard({required this.db, required this.house});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final temp = house.currentTemperature;
    final humidity = house.currentHumidity;
    final tempInRange = temp != null && temp >= 18 && temp <= 32;
    final humidityInRange =
        humidity != null && humidity >= 40 && humidity <= 70;
    final bothNull = temp == null && humidity == null;
    final outCount = [
      if (temp != null && !tempInRange) 1,
      if (humidity != null && !humidityInRange) 1,
    ].length;
    final status = bothNull
        ? ('UNKNOWN', Colors.grey)
        : outCount == 0
        ? ('OPTIMAL', const Color(0xFF22C55E))
        : outCount == 1
        ? ('ATTENTION', const Color(0xFFF59E0B))
        : ('CRITICAL', const Color(0xFFEF4444));

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  house.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit readings',
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricBadge(
                icon: Icons.thermostat_rounded,
                label: temp == null
                    ? 'Not set'
                    : '${temp.toStringAsFixed(1)} C',
                color: _tempColor(temp),
              ),
              _MetricBadge(
                icon: Icons.water_drop_rounded,
                label: humidity == null
                    ? 'Not set'
                    : '${humidity.toStringAsFixed(0)}%',
                color: _humidityColor(humidity),
              ),
              if (house.isIsolation)
                _MetricBadge(
                  icon: Icons.health_and_safety_rounded,
                  label: 'Isolation',
                  color: const Color(0xFFF59E0B),
                ),
              _MetricBadge(
                icon: Icons.fact_check_rounded,
                label: status.$1,
                color: status.$2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _tempColor(double? value) {
    if (value == null) return Colors.grey;
    if (value < 18) return const Color(0xFF3B82F6);
    if (value > 32) return const Color(0xFFEF4444);
    return const Color(0xFF22C55E);
  }

  Color _humidityColor(double? value) {
    if (value == null) return Colors.grey;
    if (value < 40) return const Color(0xFFF59E0B);
    if (value > 70) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final tempController = TextEditingController(
      text: house.currentTemperature?.toStringAsFixed(1) ?? '',
    );
    final humidityController = TextEditingController(
      text: house.currentHumidity?.toStringAsFixed(0) ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update ${house.name}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tempController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Temperature (C)',
                  prefixIcon: Icon(Icons.thermostat_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: humidityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Humidity (%)',
                  prefixIcon: Icon(Icons.water_drop_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final tempValue = double.tryParse(tempController.text.trim());
              final humidityValue = double.tryParse(
                humidityController.text.trim(),
              );
              await (db.update(
                db.houses,
              )..where((h) => h.id.equals(house.id))).write(
                HousesCompanion(
                  currentTemperature: Value(tempValue),
                  currentHumidity: Value(humidityValue),
                  updatedAt: Value(DateTime.now()),
                  synced: const Value(false),
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
