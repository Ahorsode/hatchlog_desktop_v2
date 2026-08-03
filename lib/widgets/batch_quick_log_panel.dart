import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../models/batch_deep_dive_models.dart';
import 'batch_actions_dialogs.dart';
import 'batch_quick_log_dialogs.dart';

class BatchQuickLogPanel extends StatelessWidget {
  const BatchQuickLogPanel({
    super.key,
    required this.batch,
    required this.payload,
    required this.farmId,
    required this.onChanged,
  });

  final Batch batch;
  final BatchDeepDivePayload payload;
  final String farmId;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final buttons = <_QuickLogButton>[
      _QuickLogButton(
        label: 'Log Weight',
        icon: Icons.monitor_weight_outlined,
        color: const Color(0xFF10B981),
        onTap: () => _open(context, () => showBatchWeightLogDialog(
              context,
              batchId: batch.id,
              farmId: farmId,
            )),
      ),
      _QuickLogButton(
        label: 'Log Feed',
        icon: Icons.grain,
        color: const Color(0xFFF59E0B),
        onTap: () => _open(context, () => showBatchFeedLogDialog(
              context,
              batchId: batch.id,
              farmId: farmId,
              feedInventory: payload.forms.feedInventory,
            )),
      ),
      if (payload.metrics.isLayer)
        _QuickLogButton(
          label: 'Log Eggs',
          icon: Icons.egg_outlined,
          color: const Color(0xFFFB923C),
          onTap: () => _open(context, () => showBatchEggLogDialog(
                context,
                batchId: batch.id,
                farmId: farmId,
              )),
        ),
      _QuickLogButton(
        label: 'Log Mortality',
        icon: Icons.coronavirus_outlined,
        color: const Color(0xFFEF4444),
        onTap: () => _open(
          context,
          () => showDialog<bool>(
            context: context,
            builder: (_) => MortalityDialog(batch: batch),
          ),
        ),
      ),
      _QuickLogButton(
        label: 'Record Sale',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF0EA5E9),
        onTap: () => _open(
          context,
          () => showBatchQuickSaleDialog(context, batch: batch),
        ),
      ),
      if (payload.finance.canEditFinance)
        _QuickLogButton(
          label: 'Add Expense',
          icon: Icons.payments_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () => _open(context, () => showBatchExpenseLogDialog(
                context,
                batchId: batch.id,
                farmId: farmId,
                allocationBatches: payload.forms.allocationBatches,
              )),
        ),
    ];

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
              Text(
                'QUICK LOG',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                batch.batchName.toUpperCase(),
                style: TextStyle(
                  color: const Color(0xFF10B981).withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons
                .map(
                  (button) => ActionChip(
                    avatar: Icon(button.icon, size: 16, color: button.color),
                    label: Text(button.label),
                    onPressed: button.onTap,
                    backgroundColor: button.color.withValues(alpha: 0.08),
                    side: BorderSide(color: button.color.withValues(alpha: 0.2)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    Future<bool?> Function() opener,
  ) async {
    final changed = await opener();
    if (changed == true) {
      onChanged();
    }
  }
}

class _QuickLogButton {
  const _QuickLogButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
