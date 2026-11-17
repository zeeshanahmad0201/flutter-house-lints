import 'package:flutter_house_lints/src/rules/no_raw_bottom_sheet.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawBottomSheetTest);
  });
}

@reflectiveTest
class NoRawBottomSheetTest extends RawMaterialRuleTest {
  @override
  NoRawBottomSheet createRule() => NoRawBottomSheet();

  @override
  String get component => 'bottom sheet';

  @override
  List<String> get flaggedUses => [
    'BottomSheet',
    'showModalBottomSheet',
    'showBottomSheet',
  ];
}
