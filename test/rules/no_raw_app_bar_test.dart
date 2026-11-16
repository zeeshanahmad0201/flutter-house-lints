import 'package:flutter_house_lints/src/rules/no_raw_app_bar.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawAppBarTest);
  });
}

@reflectiveTest
class NoRawAppBarTest extends RawMaterialRuleTest {
  @override
  NoRawAppBar createRule() => NoRawAppBar();

  @override
  String get component => 'app bar';

  @override
  List<String> get flaggedUses => [
    'AppBar',
    'SliverAppBar',
    'SliverAppBar.medium',
    'SliverAppBar.large',
  ];
}
