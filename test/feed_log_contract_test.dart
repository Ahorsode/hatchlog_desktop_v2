import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_pms_desktop/utils/feed_source_utils.dart';

void main() {
  test('parseFeedSource maps inventory prefix to feed_type_id', () {
    final selection = parseFeedSource(
      'inv_item-1',
      label: '[Inventory] Grower Feed',
    );

    expect(selection.feedTypeId, 'item-1');
    expect(selection.formulationId, isNull);
    expect(selection.label, '[Inventory] Grower Feed');
  });

  test('parseFeedSource maps formulation prefix to formulation_id', () {
    final selection = parseFeedSource(
      'form_starter',
      label: '[Formulation] Starter',
    );

    expect(selection.feedTypeId, isNull);
    expect(selection.formulationId, 'starter');
    expect(selection.label, '[Formulation] Starter');
  });
}
