import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_db.dart';
import '../widgets/financial_init_dialog.dart';

/// Steps through batches missing initial cost after login/sync (web wizard parity).
class FinancialInitWizard {
  static Future<void> promptIfNeeded(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final prefs = await SharedPreferences.getInstance();
    final batches = await (db.select(db.batches)
          ..where((t) => t.status.equals('active')))
        .get();

    for (final batch in batches) {
      final cost = batch.initialActualCost;
      if (cost != null && cost > 0) continue;

      final dismissKey = 'financial_init_dismissed_${batch.id}';
      if (prefs.getBool(dismissKey) == true) continue;
      if (!context.mounted) return;

      final completed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => FinancialInitDialog(batch: batch),
      );

      if (completed != true) {
        await prefs.setBool(dismissKey, true);
      }
      if (!context.mounted) return;
    }
  }
}
