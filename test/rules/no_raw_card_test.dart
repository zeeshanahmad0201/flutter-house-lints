import 'package:flutter_house_lints/src/rules/no_raw_card.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawCardTest);
  });
}

@reflectiveTest
class NoRawCardTest extends RawMaterialRuleTest {
  @override
  NoRawCard createRule() => NoRawCard();

  @override
  String get component => 'card';

  @override
  List<String> get flaggedUses => ['Card', 'Card.filled', 'Card.outlined'];
}
