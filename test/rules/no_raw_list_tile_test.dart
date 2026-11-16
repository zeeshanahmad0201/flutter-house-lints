import 'package:flutter_house_lints/src/rules/no_raw_list_tile.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawListTileTest);
  });
}

@reflectiveTest
class NoRawListTileTest extends RawMaterialRuleTest {
  @override
  NoRawListTile createRule() => NoRawListTile();

  @override
  String get component => 'list row';

  @override
  List<String> get flaggedUses => [
    'ListTile',
    'CheckboxListTile',
    'CheckboxListTile.adaptive',
    'RadioListTile',
    'RadioListTile.adaptive',
    'SwitchListTile',
    'SwitchListTile.adaptive',
    'ExpansionTile',
  ];
}
