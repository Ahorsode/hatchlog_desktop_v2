import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/services/ledger_allocation_service.dart';

void main() {
  group('LedgerAllocationService', () {
    test('buildEvenAllocations splits percentage evenly', () {
      final batches = [
        const AllocationBatch(id: 'a', name: 'A', currentCount: 100),
        const AllocationBatch(id: 'b', name: 'B', currentCount: 200),
      ];
      final rows = LedgerAllocationService.buildEvenAllocations(
        batches,
        100,
        AllocationMode.percentage,
      );
      expect(rows.length, 2);
      expect(rows.fold<double>(0, (sum, row) => sum + (row.percentage ?? 0)), 100);
    });

    test('encode and parse ledger allocation suffix', () {
      final encoded = LedgerAllocationService.encodeLedgerAllocation([
        (batchId: 'batch-1', amount: 50.25),
      ]);
      expect(
        LedgerAllocationService.parseLedgerAllocation('Note $encoded')?.first.batchId,
        'batch-1',
      );
      expect(
        LedgerAllocationService.stripLedgerAllocation('Note $encoded'),
        'Note',
      );
    });

    test('mapCategoryToExpenseType maps feed purchases', () {
      expect(
        LedgerAllocationService.mapCategoryToExpenseType('Feed Purchases'),
        'FEED',
      );
    });
  });
}
