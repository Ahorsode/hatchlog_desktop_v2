import 'package:drift/drift.dart' hide Batch, Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../models/batch_deep_dive_models.dart';
import '../services/health_inventory_service.dart';
import '../utils/health_constants.dart';

class BatchHealthSchedulePanel extends StatelessWidget {
  const BatchHealthSchedulePanel({
    super.key,
    required this.batchId,
    required this.farmId,
    required this.vaccinations,
    required this.medications,
    required this.canEdit,
    required this.onChanged,
  });

  final String batchId;
  final String farmId;
  final List<Map<String, dynamic>> vaccinations;
  final List<Map<String, dynamic>> medications;
  final bool canEdit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final schedules = [
      ...vaccinations.map(
        (row) => _ScheduleView(
          id: row['id'] as String,
          kind: HealthScheduleKind.vaccination,
          name: row['vaccineName'] as String,
          scheduledDate: DateTime.parse(row['scheduledDate'] as String),
          status: row['status'] as String? ?? 'PENDING',
          quantity: (row['quantity'] as num?)?.toDouble() ?? 0,
          unit: row['unit'] as String? ?? 'dose',
        ),
      ),
      ...medications.map(
        (row) => _ScheduleView(
          id: row['id'] as String,
          kind: HealthScheduleKind.medication,
          name: row['medicationName'] as String,
          scheduledDate: DateTime.parse(row['scheduledDate'] as String),
          status: row['status'] as String? ?? 'PENDING',
          quantity: (row['quantity'] as num?)?.toDouble() ?? 0,
          unit: row['unit'] as String? ?? 'dose',
        ),
      ),
    ]..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Health Schedule',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (canEdit)
                IconButton(
                  tooltip: 'Add schedule from Health screen',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Create farm-wide schedules from the Health screen.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            Text(
              'No health schedules for this batch',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            )
          else
            ...schedules.map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(row.name),
                subtitle: Text(
                  '${row.kind == HealthScheduleKind.vaccination ? 'Vaccination' : 'Medication'} · ${DateFormat.yMMMd().format(row.scheduledDate)}',
                ),
                trailing: row.status.toUpperCase() == 'PENDING' && canEdit
                    ? TextButton(
                        onPressed: () => _completeSchedule(context, row),
                        child: const Text('Complete'),
                      )
                    : Chip(label: Text(row.status.toUpperCase())),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeSchedule(BuildContext context, _ScheduleView row) async {
    final db = context.read<AppDatabase>();
    final service = HealthInventoryService(db);
    if (row.kind == HealthScheduleKind.vaccination) {
      await service.applyScheduleStatusChange(
        farmId: farmId,
        itemName: row.name,
        previousStatus: row.status,
        newStatus: 'COMPLETED',
        quantity: row.quantity,
      );
      await (db.update(db.vaccinationSchedules)..where((t) => t.id.equals(row.id)))
          .write(
        const VaccinationSchedulesCompanion(
          status: Value('COMPLETED'),
          synced: Value(false),
        ),
      );
    } else {
      await service.applyScheduleStatusChange(
        farmId: farmId,
        itemName: row.name,
        previousStatus: row.status,
        newStatus: 'COMPLETED',
        quantity: row.quantity,
      );
      await (db.update(db.medicationSchedules)..where((t) => t.id.equals(row.id)))
          .write(
        const MedicationSchedulesCompanion(
          status: Value('COMPLETED'),
          synced: Value(false),
        ),
      );
    }
    if (context.mounted) {
      context.read<SyncEngine>().syncNow();
      onChanged();
    }
  }
}

class _ScheduleView {
  const _ScheduleView({
    required this.id,
    required this.kind,
    required this.name,
    required this.scheduledDate,
    required this.status,
    required this.quantity,
    required this.unit,
  });

  final String id;
  final HealthScheduleKind kind;
  final String name;
  final DateTime scheduledDate;
  final String status;
  final double quantity;
  final String unit;
}
