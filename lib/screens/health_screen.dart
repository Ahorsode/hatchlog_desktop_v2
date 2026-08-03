import 'package:drift/drift.dart' hide Column, Batch;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../utils/farm_utils.dart';
import '../utils/health_constants.dart';
import '../utils/id_utils.dart';
import '../services/health_inventory_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String _filterStatus = 'PENDING';
  String _filterType = 'ALL';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    return StreamBuilder<List<_CombinedSchedule>>(
      stream: _mergedScheduleStream(db),
      builder: (context, snapshot) {
        final allRows = snapshot.data ?? const [];
        final pendingCount =
            allRows.where((row) => row.status.toUpperCase() == 'PENDING').length;
        final filtered = allRows.where((row) {
          final statusOk = _filterStatus == 'ALL' ||
              row.status.toUpperCase() == _filterStatus;
          final typeOk = _filterType == 'ALL' ||
              (_filterType == 'VACCINATION' &&
                  row.kind == HealthScheduleKind.vaccination) ||
              (_filterType == 'MEDICATION' &&
                  row.kind == HealthScheduleKind.medication);
          return statusOk && typeOk;
        }).toList();

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.health_and_safety_rounded,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Health Schedules ($pendingCount pending)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _openCreateDialog(context, db),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Schedule'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _filterStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All statuses')),
                        DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                        DropdownMenuItem(
                          value: 'COMPLETED',
                          child: Text('Completed'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _filterStatus = value ?? 'PENDING'),
                    ),
                    DropdownButton<String>(
                      value: _filterType,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All types')),
                        DropdownMenuItem(
                          value: 'VACCINATION',
                          child: Text('Vaccination'),
                        ),
                        DropdownMenuItem(
                          value: 'MEDICATION',
                          child: Text('Medication'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _filterType = value ?? 'ALL'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            _filterStatus == 'PENDING'
                                ? 'No pending health schedules.'
                                : 'No schedules match the current filters.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final row = filtered[index];
                            return _ScheduleTile(
                              row: row,
                              db: db,
                              onChanged: () => setState(() {}),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Stream<List<_CombinedSchedule>> _mergedScheduleStream(AppDatabase db) {
    final vaccinations = (db.select(db.vaccinationSchedules)
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
        .watch();
    final medications = (db.select(db.medicationSchedules)
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
        .watch();
    final batches = db.select(db.batches).watch();

    return Rx.combineLatest3(vaccinations, medications, batches,
        (List<VaccinationSchedule> vax, List<MedicationSchedule> meds, batches) {
      final batchMap = {for (final b in batches) b.id: b.batchName};
      final rows = <_CombinedSchedule>[
        ...vax.map(
          (row) => _CombinedSchedule(
            id: row.id,
            kind: HealthScheduleKind.vaccination,
            name: row.vaccineName,
            batchId: row.batchId,
            batchName: batchMap[row.batchId] ?? row.batchId,
            scheduledDate: row.scheduledDate,
            status: row.status,
            notes: row.notes,
            quantity: row.quantity,
            usageType: row.usageType,
            unit: row.unit,
            farmId: row.farmId,
          ),
        ),
        ...meds.map(
          (row) => _CombinedSchedule(
            id: row.id,
            kind: HealthScheduleKind.medication,
            name: row.medicationName,
            batchId: row.batchId,
            batchName: batchMap[row.batchId] ?? row.batchId,
            scheduledDate: row.scheduledDate,
            status: row.status,
            notes: row.notes,
            quantity: row.quantity,
            usageType: row.usageType,
            unit: row.unit,
            farmId: row.farmId,
          ),
        ),
      ];
      rows.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      return rows;
    });
  }

  Future<void> _openCreateDialog(BuildContext context, AppDatabase db) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CreateScheduleDialog(db: db),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.row,
    required this.db,
    required this.onChanged,
  });

  final _CombinedSchedule row;
  final AppDatabase db;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final typeLabel = row.kind == HealthScheduleKind.vaccination
        ? 'Vaccination'
        : 'Medication';
    final isPending = row.status.toUpperCase() == 'PENDING';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        row.name,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '$typeLabel · ${row.batchName} · ${DateFormat.yMMMd().format(row.scheduledDate)} · ${row.quantity} ${row.unit ?? 'dose'}',
      ),
      trailing: isPending
          ? FilledButton.tonal(
              onPressed: () => _markCompleted(context),
              child: const Text('Complete'),
            )
          : Chip(
              label: Text(row.status.toUpperCase()),
            ),
    );
  }

  Future<void> _markCompleted(BuildContext context) async {
    String? inventoryId;
    final qtyController = TextEditingController(text: row.quantity.toString());
    final inventoryItems = await (db.select(db.inventory)
          ..where((t) => t.farmId.equals(row.farmId)))
        .get();
    final filteredInventory = inventoryItems.where((item) {
      if (row.kind == HealthScheduleKind.vaccination) {
        return isVaccineCategory(item.category);
      }
      return isMedicineCategory(item.category);
    }).toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mark schedule completed?'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${row.name} for ${row.batchName}'),
                const SizedBox(height: 16),
                const Text(
                  'Deduct from inventory (optional)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: inventoryId,
                  decoration: const InputDecoration(
                    labelText: 'Inventory item',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Skip inventory deduction'),
                    ),
                    ...filteredInventory.map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          '${item.itemName} (${item.stockLevel} ${item.unit})',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => inventoryId = value),
                ),
                if (inventoryId != null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity to deduct',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) {
      qtyController.dispose();
      return;
    }

    final service = HealthInventoryService(db);
    try {
      if (inventoryId != null) {
        final deductQty = double.tryParse(qtyController.text.trim()) ?? row.quantity;
        final item = filteredInventory.firstWhere((it) => it.id == inventoryId);
        await (db.update(db.inventory)..where((t) => t.id.equals(item.id))).write(
          InventoryCompanion(
            stockLevel: Value(item.stockLevel - deductQty),
            synced: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      if (row.kind == HealthScheduleKind.vaccination) {
        await service.applyScheduleStatusChange(
          farmId: row.farmId,
          itemName: row.name,
          previousStatus: row.status,
          newStatus: 'COMPLETED',
          quantity: row.quantity,
        );
        await (db.update(db.vaccinationSchedules)
              ..where((t) => t.id.equals(row.id)))
            .write(
          const VaccinationSchedulesCompanion(
            status: Value('COMPLETED'),
            synced: Value(false),
          ),
        );
      } else {
        await service.applyScheduleStatusChange(
          farmId: row.farmId,
          itemName: row.name,
          previousStatus: row.status,
          newStatus: 'COMPLETED',
          quantity: row.quantity,
        );
        await (db.update(db.medicationSchedules)
              ..where((t) => t.id.equals(row.id)))
            .write(
          const MedicationSchedulesCompanion(
            status: Value('COMPLETED'),
            synced: Value(false),
          ),
        );
      }

      if (context.mounted) {
        context.read<SyncEngine>().syncNow();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule marked completed')),
        );
      }
      onChanged();
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      qtyController.dispose();
    }
  }
}

class _CombinedSchedule {
  const _CombinedSchedule({
    required this.id,
    required this.kind,
    required this.name,
    required this.batchId,
    required this.batchName,
    required this.scheduledDate,
    required this.status,
    required this.notes,
    required this.quantity,
    required this.usageType,
    required this.unit,
    required this.farmId,
  });

  final String id;
  final HealthScheduleKind kind;
  final String name;
  final String batchId;
  final String batchName;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final double quantity;
  final String? usageType;
  final String? unit;
  final String farmId;
}

class _ScheduleDraft {
  _ScheduleDraft({
    required this.kind,
    required this.batchId,
    required this.batchLabel,
    required this.name,
    required this.usageType,
    required this.scheduledDate,
    required this.quantity,
    required this.unit,
    required this.notes,
  });

  final HealthScheduleKind kind;
  final String batchId;
  final String batchLabel;
  final String name;
  final HealthUsageType usageType;
  final DateTime scheduledDate;
  final double quantity;
  final String unit;
  final String notes;
}

class _CreateScheduleDialog extends StatefulWidget {
  const _CreateScheduleDialog({required this.db});

  final AppDatabase db;

  @override
  State<_CreateScheduleDialog> createState() => _CreateScheduleDialogState();
}

class _CreateScheduleDialogState extends State<_CreateScheduleDialog> {
  HealthScheduleKind _kind = HealthScheduleKind.vaccination;
  String? _batchId;
  String? _namePreset;
  String _customName = '';
  HealthUsageType _usageType = HealthUsageType.oneTime;
  DateTime _scheduledDate = DateTime.now();
  final _quantityController = TextEditingController(text: '1');
  String _unit = 'dose';
  final _notesController = TextEditingController();
  final List<_ScheduleDraft> _drafts = [];

  List<String> get _presets => _kind == HealthScheduleKind.vaccination
      ? vaccinationNamePresets
      : medicationNamePresets;

  String? get _resolvedName {
    if (_namePreset == null || _namePreset!.isEmpty) return null;
    if (_namePreset == healthCustomPreset) {
      final custom = _customName.trim();
      return custom.isEmpty ? null : custom;
    }
    return _namePreset;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addDraft() {
    final name = _resolvedName;
    if (_batchId == null || name == null) return;
    final batchLabel = _batchId!;
    setState(() {
      _drafts.add(
        _ScheduleDraft(
          kind: _kind,
          batchId: _batchId!,
          batchLabel: batchLabel,
          name: name,
          usageType: _usageType,
          scheduledDate: _scheduledDate,
          quantity: double.tryParse(_quantityController.text.trim()) ?? 1,
          unit: _unit,
          notes: _notesController.text.trim(),
        ),
      );
    });
  }

  Future<void> _saveAll() async {
    final farmId = await FarmUtils.getBoundFarmId();
    if (farmId == null || farmId.isEmpty) return;

    final toSave = [..._drafts];
    final currentName = _resolvedName;
    if (_batchId != null && currentName != null) {
      toSave.add(
        _ScheduleDraft(
          kind: _kind,
          batchId: _batchId!,
          batchLabel: _batchId!,
          name: currentName,
          usageType: _usageType,
          scheduledDate: _scheduledDate,
          quantity: double.tryParse(_quantityController.text.trim()) ?? 1,
          unit: _unit,
          notes: _notesController.text.trim(),
        ),
      );
    }

    if (toSave.isEmpty) return;

    for (final draft in toSave) {
      final id = safeIdString(newLocalId());
      if (draft.kind == HealthScheduleKind.vaccination) {
        await widget.db.into(widget.db.vaccinationSchedules).insert(
          VaccinationSchedulesCompanion.insert(
            id: id,
            farmId: farmId,
            batchId: draft.batchId,
            vaccineName: draft.name,
            scheduledDate: draft.scheduledDate,
            status: const Value('PENDING'),
            notes: Value(draft.notes.isEmpty ? null : draft.notes),
            quantity: Value(draft.quantity),
            usageType: Value(healthUsageTypeDbValue(draft.usageType)),
            unit: Value(draft.unit),
            synced: const Value(false),
          ),
        );
      } else {
        await widget.db.into(widget.db.medicationSchedules).insert(
          MedicationSchedulesCompanion.insert(
            id: id,
            farmId: farmId,
            batchId: draft.batchId,
            medicationName: draft.name,
            scheduledDate: draft.scheduledDate,
            status: const Value('PENDING'),
            notes: Value(draft.notes.isEmpty ? null : draft.notes),
            quantity: Value(draft.quantity),
            usageType: Value(healthUsageTypeDbValue(draft.usageType)),
            unit: Value(draft.unit),
            synced: const Value(false),
          ),
        );
      }
    }

    if (mounted) {
      context.read<SyncEngine>().syncNow();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Health Schedule'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<HealthScheduleKind>(
                segments: const [
                  ButtonSegment(
                    value: HealthScheduleKind.vaccination,
                    label: Text('Vaccination'),
                  ),
                  ButtonSegment(
                    value: HealthScheduleKind.medication,
                    label: Text('Medication'),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (values) {
                  setState(() {
                    _kind = values.first;
                    _namePreset = null;
                    _unit = _kind == HealthScheduleKind.vaccination
                        ? 'dose'
                        : 'ml';
                  });
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Batch>>(
                stream: widget.db.select(widget.db.batches).watch(),
                builder: (context, snapshot) {
                  final batches = (snapshot.data ?? [])
                      .where((b) => b.status.toUpperCase() == 'ACTIVE')
                      .toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _batchId,
                    decoration: const InputDecoration(labelText: 'Batch'),
                    items: batches
                        .map(
                          (batch) => DropdownMenuItem(
                            value: batch.id,
                            child: Text(batch.batchName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _batchId = value),
                  );
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _namePreset,
                decoration: InputDecoration(
                  labelText: _kind == HealthScheduleKind.vaccination
                      ? 'Vaccine'
                      : 'Medication',
                ),
                items: _presets
                    .map(
                      (preset) => DropdownMenuItem(
                        value: preset,
                        child: Text(preset),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _namePreset = value),
              ),
              if (_namePreset == healthCustomPreset)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Custom name'),
                  onChanged: (value) => _customName = value,
                ),
              DropdownButtonFormField<HealthUsageType>(
                initialValue: _usageType,
                decoration: const InputDecoration(labelText: 'Usage type'),
                items: const [
                  DropdownMenuItem(
                    value: HealthUsageType.oneTime,
                    child: Text('ONE_TIME'),
                  ),
                  DropdownMenuItem(
                    value: HealthUsageType.quantity,
                    child: Text('RECURRING / QUANTITY'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _usageType = value ?? HealthUsageType.oneTime),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scheduled date'),
                subtitle: Text(DateFormat.yMMMd().format(_scheduledDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: _scheduledDate,
                  );
                  if (picked != null) setState(() => _scheduledDate = picked);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: healthUnitOptions
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _unit = value ?? _unit),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              if (_drafts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Drafts (${_drafts.length})',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                ..._drafts.map(
                  (draft) => ListTile(
                    dense: true,
                    title: Text(draft.name),
                    subtitle: Text(
                      '${draft.kind == HealthScheduleKind.vaccination ? 'Vaccination' : 'Medication'} · ${DateFormat.yMMMd().format(draft.scheduledDate)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _drafts.remove(draft)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _addDraft,
          child: const Text('Add to Draft'),
        ),
        FilledButton(
          onPressed: _saveAll,
          child: Text(
            _drafts.isEmpty
                ? 'Save'
                : 'Save All (${_drafts.length + (_resolvedName != null && _batchId != null ? 1 : 0)})',
          ),
        ),
      ],
    );
  }
}
