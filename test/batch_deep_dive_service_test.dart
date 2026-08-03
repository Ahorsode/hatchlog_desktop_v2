import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/models/batch_deep_dive_models.dart';
import 'package:poultry_pms_desktop/services/batch_consumption_finance.dart';
import 'package:poultry_pms_desktop/services/batch_finance_service.dart';
import 'package:poultry_pms_desktop/services/batch_log_entries_service.dart';
import 'package:poultry_pms_desktop/services/batch_revenue_service.dart';

void main() {
  group('batch finance computer', () {
    test('computeBatchFinance aggregates revenue and expenses', () {
      final service = BatchFinanceService(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
      final arrival = DateTime(2026, 1, 1);
      final result = service.computeBatchFinance(
        batchId: 'batch-1',
        arrivalDate: arrival,
        initialActualCost: 1000,
        directExpenses: const [],
        allocatedExpenses: const [],
        generalExpenses: const [],
        revenueItems: [
          BatchRevenueItem(
            id: 'sale-1',
            description: 'Direct sale',
            totalPrice: 500,
            orderDate: DateTime(2026, 2, 1),
            orderStatus: 'COMPLETED',
            kind: 'Direct',
          ),
        ],
        activeBatches: const [
          HeadcountBatch(id: 'batch-1', currentCount: 100),
        ],
        consumptionContext: ConsumptionContext(
          feedByInventoryId: {},
          feedLogsByInventoryId: {},
          feedLogsByFormulationId: {},
          formulations: const [],
          formulationNameById: {},
          healthByItemName: {},
          inventoryIdByName: {},
          inventoryCostPerUnitById: {},
        ),
      );

      expect(result.initialInvestment, 1000);
      expect(result.totalRevenue, 500);
      expect(result.totalExpenses, 1000);
      expect(result.netProfit, -500);
      expect(result.financeSummary.length, 5);
    });
  });

  group('batch revenue service', () {
    test('buildBatchRevenueItems attributes livestock sale directly', () {
      final items = buildBatchRevenueItems(
        'batch-1',
        orderItems: [
          (
            id: 'item-1',
            description: 'Broiler sale',
            quantity: 10,
            unitPrice: 25,
            totalPrice: 250,
            livestockId: 'batch-1',
            eggAllocationMode: null,
            eggBatchId: null,
            orderDate: DateTime(2026, 2, 1),
            orderStatus: 'COMPLETED',
          ),
        ],
        batchAllocations: const [],
        manualLedgerTransactions: const [],
        activeBatches: const [
          HeadcountBatch(id: 'batch-1', currentCount: 100),
        ],
      );

      expect(items, hasLength(1));
      expect(items.first.kind, 'Direct');
      expect(items.first.totalPrice, 250);
    });
  });

  group('batch log entries service', () {
    test('buildBatchLogEntries merges feed and finance logs', () {
      final entries = BatchLogEntriesService.buildBatchLogEntries(
        logs: BatchDeepDiveLogs(
          weightRecords: const [],
          feedingLogs: [
            {
              'id': 'f1',
              'logDate': '2026-02-01T10:00:00.000',
              'amountConsumed': 12,
              'feedTypeId': 'feed-1',
              'inventory': {'itemName': 'Grower Feed', 'unit': 'bags'},
              'userId': 'u1',
            },
          ],
          eggProduction: const [],
          mortalityRecords: const [],
          vaccinations: const [],
          medications: const [],
          salesRecords: [
            {
              'id': 's1',
              'description': 'Sale',
              'quantity': 5,
              'unitPrice': 20,
              'totalPrice': 100,
              'logDate': '2026-02-02T10:00:00.000',
            },
          ],
        ),
        expenseBreakdown: [
          ExpenseBreakdownItem(
            id: 'e1',
            date: DateTime(2026, 2, 3),
            category: 'FEED',
            description: 'Feed purchase',
            amount: 80,
            kind: 'Direct',
          ),
        ],
        canViewFinance: true,
      );

      expect(entries.length, greaterThanOrEqualTo(3));
      expect(entries.any((e) => e.type == BatchLogEntryType.feed), isTrue);
      expect(entries.any((e) => e.type == BatchLogEntryType.sales), isTrue);
      expect(entries.any((e) => e.type == BatchLogEntryType.expense), isTrue);
    });
  });
}
