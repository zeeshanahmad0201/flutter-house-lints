import 'package:flutter_house_lints/src/rules/no_raw_text_field.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawTextFieldTest);
  });
}

@reflectiveTest
class NoRawTextFieldTest extends RawMaterialRuleTest {
  @override
  NoRawTextField createRule() => NoRawTextField();

  @override
  String get component => 'text field';

  @override
  List<String> get flaggedUses => ['TextField', 'TextFormField'];
}
