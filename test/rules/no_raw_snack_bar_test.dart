import 'package:flutter_house_lints/src/rules/no_raw_snack_bar.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawSnackBarTest);
  });
}

@reflectiveTest
class NoRawSnackBarTest extends RawMaterialRuleTest {
  @override
  NoRawSnackBar createRule() => NoRawSnackBar();

  @override
  String get component => 'snack bar';

  @override
  List<String> get flaggedUses => ['SnackBar'];
}
