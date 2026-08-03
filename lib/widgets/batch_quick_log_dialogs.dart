import 'package:drift/drift.dart' hide Batch, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../features/sales/sale_line_draft.dart';
import '../models/batch_deep_dive_models.dart';
import '../services/ledger_allocation_service.dart';
import '../services/local_sales_service.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/user_role.dart';
import 'batch_actions_dialogs.dart';

Future<bool?> showBatchWeightLogDialog(
  BuildContext context, {
  required String batchId,
  required String farmId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _BatchWeightLogDialog(batchId: batchId, farmId: farmId),
  );
}

Future<bool?> showBatchFeedLogDialog(
  BuildContext context, {
  required String batchId,
  required String farmId,
  required List<FeedInventoryOption> feedInventory,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _BatchFeedLogDialog(
      batchId: batchId,
      farmId: farmId,
      feedInventory: feedInventory,
    ),
  );
}

Future<bool?> showBatchEggLogDialog(
  BuildContext context, {
  required String batchId,
  required String farmId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _BatchEggLogDialog(batchId: batchId, farmId: farmId),
  );
}

Future<bool?> showBatchExpenseLogDialog(
  BuildContext context, {
  required String batchId,
  required String farmId,
  required List<AllocationBatchOption> allocationBatches,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _BatchExpenseLogDialog(
      batchId: batchId,
      farmId: farmId,
      allocationBatches: allocationBatches,
    ),
  );
}

Future<bool?> showBatchQuickSaleDialog(
  BuildContext context, {
  required Batch batch,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => QuickSaleDialog(batch: batch),
  );
}

class _BatchWeightLogDialog extends StatefulWidget {
  const _BatchWeightLogDialog({
    required this.batchId,
    required this.farmId,
  });

  final String batchId;
  final String farmId;

  @override
  State<_BatchWeightLogDialog> createState() => _BatchWeightLogDialogState();
}

class _BatchWeightLogDialogState extends State<_BatchWeightLogDialog> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _logDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Average Weight'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Average Weight (kg)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Log Date'),
              subtitle: Text(_logDate.toLocal().toString().split('.').first),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _logDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    setState(() => _logDate = picked);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final workerId = await FarmUtils.getRequiredUserId();
    final weight = double.parse(_weightController.text.trim());

    await db.into(db.weightRecords).insert(
          WeightRecordsCompanion.insert(
            id: newLocalId(),
            farmId: widget.farmId,
            batchId: widget.batchId,
            averageWeight: weight,
            logDate: _logDate,
            userId: Value(workerId),
            synced: const Value(false),
          ),
        );

    if (mounted) Navigator.pop(context, true);
  }
}

class _BatchFeedLogDialog extends StatefulWidget {
  const _BatchFeedLogDialog({
    required this.batchId,
    required this.farmId,
    required this.feedInventory,
  });

  final String batchId;
  final String farmId;
  final List<FeedInventoryOption> feedInventory;

  @override
  State<_BatchFeedLogDialog> createState() => _BatchFeedLogDialogState();
}

class _BatchFeedLogDialogState extends State<_BatchFeedLogDialog> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _feedTypeId;
  DateTime _logDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Feed Consumption'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _feedTypeId,
              decoration: const InputDecoration(
                labelText: 'Feed type',
                border: OutlineInputBorder(),
              ),
              items: widget.feedInventory
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        '${item.itemName} (${item.stockLevel} ${item.unit})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _feedTypeId = value),
              validator: (v) => v == null ? 'Select feed' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount consumed',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final workerId = await FarmUtils.getRequiredUserId();
    final amount = double.parse(_amountController.text.trim());

    await db.into(db.feedingLogs).insert(
          FeedingLogsCompanion.insert(
            id: newLocalId(),
            farmId: widget.farmId,
            batchId: Value(widget.batchId),
            feedTypeId: Value(_feedTypeId),
            amountConsumed: amount,
            logDate: _logDate,
            userId: Value(workerId),
            synced: const Value(false),
          ),
        );

    if (mounted) Navigator.pop(context, true);
  }
}

class _BatchEggLogDialog extends StatefulWidget {
  const _BatchEggLogDialog({
    required this.batchId,
    required this.farmId,
  });

  final String batchId;
  final String farmId;

  @override
  State<_BatchEggLogDialog> createState() => _BatchEggLogDialogState();
}

class _BatchEggLogDialogState extends State<_BatchEggLogDialog> {
  final _eggsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _logDate = DateTime.now();

  @override
  void dispose() {
    _eggsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Egg Production'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _eggsController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Eggs collected',
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final workerId = await FarmUtils.getRequiredUserId();
    final eggs = int.parse(_eggsController.text.trim());

    await db.into(db.eggProductions).insert(
          EggProductionsCompanion.insert(
            id: newLocalId(),
            farmId: widget.farmId,
            batchId: widget.batchId,
            eggsCollected: eggs,
            eggsRemaining: Value(eggs),
            logDate: _logDate,
            userId: Value(workerId),
            synced: const Value(false),
          ),
        );

    if (mounted) Navigator.pop(context, true);
  }
}

class _BatchExpenseLogDialog extends StatefulWidget {
  const _BatchExpenseLogDialog({
    required this.batchId,
    required this.farmId,
    required this.allocationBatches,
  });

  final String batchId;
  final String farmId;
  final List<AllocationBatchOption> allocationBatches;

  @override
  State<_BatchExpenseLogDialog> createState() => _BatchExpenseLogDialogState();
}

class _BatchExpenseLogDialogState extends State<_BatchExpenseLogDialog> {
  static const _categories = [
    'FEED',
    'MEDICATION',
    'EQUIPMENT',
    'UTILITIES',
    'SALARY',
    'MAINTENANCE',
    'TRANSPORT',
    'OTHER',
  ];

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = _categories.first;
  bool _splitExpense = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (GH₵)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              if (widget.allocationBatches.length > 1) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Split evenly across active batches'),
                  value: _splitExpense,
                  onChanged: (value) => setState(() => _splitExpense = value),
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
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final db = context.read<AppDatabase>();
    final workerId = await FarmUtils.getRequiredUserId();
    final amount = double.parse(_amountController.text.trim());
    final baseDescription = _descriptionController.text.trim();

    if (_splitExpense && widget.allocationBatches.length > 1) {
      final allocations = LedgerAllocationService.buildEvenAllocations(
        widget.allocationBatches
            .map(
              (batch) => AllocationBatch(
                id: batch.id,
                name: batch.name,
                currentCount: batch.currentCount,
              ),
            )
            .toList(),
        amount,
        AllocationMode.amount,
      );
      final groupId = newLocalId();
      for (final row in allocations) {
        final batch = widget.allocationBatches.firstWhere(
          (item) => item.id == row.batchId,
        );
        final description = [
          '[SHARED ALLOCATION: group=$groupId; percent=${row.percentage?.toStringAsFixed(2) ?? '0'}%; base=${amount.toStringAsFixed(2)}]',
          if (baseDescription.isNotEmpty) baseDescription,
        ].join(' ');
        await db.into(db.expenses).insert(
              ExpensesCompanion.insert(
                id: newLocalId(),
                farmId: widget.farmId,
                batchId: Value(batch.id),
                category: _category,
                amount: row.amount ?? 0,
                description: Value(description),
                allocationGroupId: Value(groupId),
                allocationPercent: Value(row.percentage),
                isSharedAllocation: const Value(true),
                userId: Value(workerId),
                synced: const Value(false),
              ),
            );
      }
    } else {
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: newLocalId(),
              farmId: widget.farmId,
              batchId: Value(widget.batchId),
              category: _category,
              amount: amount,
              description:
                  baseDescription.isEmpty ? const Value.absent() : Value(baseDescription),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );
    }

    if (mounted) Navigator.pop(context, true);
  }
}
