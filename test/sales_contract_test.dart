import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/features/sales/sale_line_draft.dart';
import 'package:poultry_pms_desktop/services/local_sales_service.dart';

void main() {
  group('LocalSalesService contract', () {
    test('roundMoney keeps two decimal places', () {
      expect(LocalSalesService.roundMoney(10.556), 10.56);
      expect(LocalSalesService.roundMoney(10.554), 10.55);
    });

    test('SaleLineDraft lineTotal matches web order item math', () {
      const draft = SaleLineDraft(
        productType: SaleProductType.livestock,
        description: 'Layer Batch',
        quantity: 5,
        unitPrice: 12.5,
        livestockId: 'batch-42',
      );

      expect(draft.lineTotal, 62.5);
    });

    test('rejects locked-total mismatch for worker sales', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final service = LocalSalesService(db);

      expect(
        () => service.recordMultiLineSale(
          farmId: 'farm-1',
          userId: 'user-1',
          orderDate: DateTime.utc(2026, 6, 27),
          totalCashReceived: 40,
          requireExactCashTotal: true,
          items: const [
            SaleLineDraft(
              productType: SaleProductType.inventory,
              description: 'Eggs',
              quantity: 5,
              unitPrice: 10,
              inventoryId: 'inv-1',
            ),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
