import 'package:flutter_house_lints/src/rules/no_raw_dialog.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawDialogTest);
  });
}

@reflectiveTest
class NoRawDialogTest extends RawMaterialRuleTest {
  @override
  NoRawDialog createRule() => NoRawDialog();

  @override
  String get component => 'dialog';

  @override
  List<String> get flaggedUses => [
    'AlertDialog',
    'AlertDialog.adaptive',
    'SimpleDialog',
    'Dialog',
    'Dialog.fullscreen',
    'showDialog',
    'showGeneralDialog',
    'showAdaptiveDialog',
  ];
}
