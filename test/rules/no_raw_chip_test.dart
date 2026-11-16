import 'package:flutter_house_lints/src/rules/no_raw_chip.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawChipTest);
  });
}

@reflectiveTest
class NoRawChipTest extends RawMaterialRuleTest {
  @override
  NoRawChip createRule() => NoRawChip();

  @override
  String get component => 'chip';

  @override
  List<String> get flaggedUses => [
    'Chip',
    'ActionChip',
    'ActionChip.elevated',
    'ChoiceChip',
    'ChoiceChip.elevated',
    'FilterChip',
    'FilterChip.elevated',
    'InputChip',
  ];
}
