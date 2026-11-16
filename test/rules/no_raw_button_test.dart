import 'package:flutter_house_lints/src/rules/no_raw_button.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawButtonTest);
  });
}

@reflectiveTest
class NoRawButtonTest extends RawMaterialRuleTest {
  @override
  NoRawButton createRule() => NoRawButton();

  @override
  String get component => 'button';

  @override
  List<String> get flaggedUses => [
    'ElevatedButton',
    'ElevatedButton.icon',
    'FilledButton',
    'FilledButton.tonal',
    'FilledButton.icon',
    'TextButton',
    'TextButton.icon',
    'OutlinedButton',
    'OutlinedButton.icon',
    'IconButton',
    'IconButton.filled',
    'IconButton.outlined',
    'FloatingActionButton',
    'FloatingActionButton.extended',
    'FloatingActionButton.small',
  ];
}
