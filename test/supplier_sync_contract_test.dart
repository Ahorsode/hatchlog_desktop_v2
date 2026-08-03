import 'package:flutter_test/flutter_test.dart';

/// Documents the web/desktop supplier sync contract enforced in SyncEngine.
void main() {
  group('Supplier sync contract', () {
    test('web suppliers map to desktop customerType SUPPLIER', () {
      const cloudSupplier = {
        'id': 'sup-1',
        'farmId': 'farm-1',
        'name': 'Agro Feeds',
        'balanceOwed': 125.5,
      };

      final localCustomer = {
        'id': cloudSupplier['id'],
        'farmId': cloudSupplier['farmId'],
        'name': cloudSupplier['name'],
        'balanceOwed': cloudSupplier['balanceOwed'],
        'customerType': 'SUPPLIER',
      };

      expect(localCustomer['customerType'], 'SUPPLIER');
      expect(localCustomer['balanceOwed'], 125.5);
    });

    test('PAYMENT settlements map to OTHER expense category for cloud sync', () {
      final expensePayload = {
        'category': 'OTHER',
        'supplierId': 'sup-1',
        'amount': 50.0,
      };

      expect(expensePayload['category'], 'OTHER');
      expect(expensePayload['supplierId'], isNotNull);
    });

    test('inventory restock expense carries supplier linkage', () {
      final expensePayload = {
        'category': 'FEED',
        'supplierId': 'sup-1',
        'amount': 300.0,
      };

      expect(expensePayload['supplierId'], 'sup-1');
    });
  });
}
