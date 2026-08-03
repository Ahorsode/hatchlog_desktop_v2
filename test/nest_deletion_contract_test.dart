import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/services/hatchlog_api_client.dart';

/// Documents desktop pending-deletion → Nest endpoint mapping.
void main() {
  group('Desktop Nest deletion contract', () {
    test('local table aliases map to Nest delete domains', () {
      String mapTable(String local) {
        switch (local) {
          case 'mortalities':
          case 'mortality':
            return 'mortality';
          case 'feeding_logs':
          case 'daily_feeding_logs':
            return 'feeding';
          case 'egg_productions':
          case 'egg_production':
            return 'eggs';
          case 'inventory':
            return 'inventory';
          case 'sales':
            return 'sales';
          case 'expenses':
            return 'expenses';
          case 'batches':
          case 'livestock':
            return 'livestock';
          case 'customers':
            return 'customers';
          case 'feed_formulations':
            return 'feed-formulations';
          case 'houses':
            return 'houses';
          default:
            return 'unsupported';
        }
      }

      expect(mapTable('mortalities'), 'mortality');
      expect(mapTable('daily_feeding_logs'), 'feeding');
      expect(mapTable('egg_production'), 'eggs');
      expect(mapTable('batches'), 'livestock');
      expect(mapTable('feed_formulations'), 'feed-formulations');
      expect(mapTable('unknown_table'), 'unsupported');
    });

    test('HatchlogApiClient exposes Nest delete helpers', () {
      final client = HatchlogApiClient(baseUrl: 'http://localhost:3001');
      expect(client.isConfigured, isTrue);
      expect(client.deleteMortality, isA<Function>());
      expect(client.deleteFeeding, isA<Function>());
      expect(client.deleteEgg, isA<Function>());
      expect(client.deleteInventory, isA<Function>());
      expect(client.deleteSale, isA<Function>());
      expect(client.deleteExpense, isA<Function>());
      expect(client.deleteCustomer, isA<Function>());
      expect(client.deleteFeedFormulation, isA<Function>());
      expect(client.deleteLivestock, isA<Function>());
      expect(client.deleteHouse, isA<Function>());
    });
  });
}
