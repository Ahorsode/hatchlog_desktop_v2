import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db.dart';
import '../utils/id_utils.dart';

/// Local-first settle/delete for `financial_transactions` rows (web parity).
class FinanceTransactionService {
  FinanceTransactionService(this._db);

  final AppDatabase _db;

  Future<void> settleTransaction({
    required String transactionId,
    String? referenceNum,
  }) async {
    final rows = await _db.customSelect(
      '''
      SELECT id, description, reference_num, payment_status
      FROM financial_transactions
      WHERE id = ? AND is_deleted = 0
      LIMIT 1
      ''',
      variables: [Variable<String>(transactionId)],
      readsFrom: {},
    ).get();

    if (rows.isEmpty) {
      throw StateError('Transaction not found');
    }

    final row = rows.first;
    final existingStatus = row.read<String>('payment_status').toUpperCase();
    if (existingStatus == 'PAID') {
      throw StateError('Transaction is already settled');
    }

    final baseDesc = row.read<String?>('description') ?? '';
    final now = DateTime.now();
    final dateLabel =
        '${now.month}/${now.day}/${now.year}';
    final settledSuffix =
        'Fully settled on $dateLabel${referenceNum != null && referenceNum.trim().isNotEmpty ? ' (ref: ${referenceNum.trim()})' : ''}';
    final updatedDesc = baseDesc.trim().isEmpty
        ? settledSuffix
        : '$baseDesc | $settledSuffix';

    await _db.customUpdate(
      '''
      UPDATE financial_transactions
      SET payment_status = 'PAID',
          reference_num = ?,
          description = ?,
          settled_at = ?,
          updated_at = ?,
          synced = 0
      WHERE id = ?
      ''',
      variables: [
        Variable<String>(
          referenceNum != null && referenceNum.trim().isNotEmpty
              ? referenceNum.trim()
              : (row.read<String?>('reference_num') ?? ''),
        ),
        Variable<String>(updatedDesc),
        Variable<String>(now.toIso8601String()),
        Variable<String>(now.toIso8601String()),
        Variable<String>(transactionId),
      ],
      updates: {},
    );
  }

  Future<void> deleteTransaction({
    required String transactionId,
    required String reason,
    required String farmId,
    required String userId,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.length < 5) {
      throw ArgumentError(
        'A valid reason (minimum 5 characters) is required for deletion',
      );
    }

    final rows = await _db.customSelect(
      '''
      SELECT id FROM financial_transactions
      WHERE id = ? AND farm_id = ? AND is_deleted = 0
      LIMIT 1
      ''',
      variables: [
        Variable<String>(transactionId),
        Variable<String>(farmId),
      ],
      readsFrom: {},
    ).get();

    if (rows.isEmpty) {
      throw StateError('Transaction not found');
    }

    final now = DateTime.now().toIso8601String();
    await _db.customUpdate(
      '''
      UPDATE financial_transactions
      SET is_deleted = 1,
          updated_at = ?,
          synced = 0
      WHERE id = ?
      ''',
      variables: [
        Variable<String>(now),
        Variable<String>(transactionId),
      ],
      updates: {},
    );

    try {
      await Supabase.instance.client.from('delete_logs').insert({
        'id': newLocalId(),
        'user_id': userId,
        'farm_id': farmId,
        'table_name': 'financial_transactions',
        'record_id': transactionId,
        'reason': trimmedReason,
        'created_at': now,
      });
    } catch (_) {
      // Offline — local soft delete still applies; cloud log syncs later.
    }
  }
}
