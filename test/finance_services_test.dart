import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/services/batch_finance_service.dart';
import 'package:poultry_pms_desktop/services/finance_category_labels.dart';

void main() {
  group('finance_category_labels', () {
    test('maps enum values to finance hub labels', () {
      expect(expenseCategoryLabel('FEED'), 'Feed Purchases');
      expect(expenseCategoryLabel('SALARY'), 'Labor & Salaries');
    });
  });

  group('BatchFinanceBreakdown', () {
    test('aggregates expense layers and net profit', () {
      const breakdown = BatchFinanceBreakdown(
        batchId: 'batch-1',
        batchLabel: 'Layer A',
        initial: 500,
        operating: 100,
        consumption: 80,
        general: 20,
        revenue: 900,
      );

      expect(breakdown.totalExpense, 700);
      expect(breakdown.netProfit, 200);
    });
  });
}
