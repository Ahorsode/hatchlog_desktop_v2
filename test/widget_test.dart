import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/data/local_db.dart';
import 'package:poultry_pms_desktop/utils/id_utils.dart';

/// Mirrors how screens obtain AppDatabase via Provider: file-free in-memory DB.
void main() {
  test('in-memory AppDatabase supports UI-style farm insert', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final farmId = newLocalId();
    await db.into(db.farms).insert(
      FarmsCompanion.insert(
        id: farmId,
        name: 'UI Farm',
        capacity: 100,
        userId: newLocalId(),
      ),
    );

    final farms = await db.select(db.farms).get();
    expect(farms, hasLength(1));
    expect(farms.first.id, farmId);
    expect(int.tryParse(farms.first.id), isNull);
  });
}
