// test_reflective_loader runs methods named test_*.
// ignore_for_file: non_constant_identifier_names

import 'package:flutter_house_lints/src/rules/no_raw_scaffold.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../src/raw_material_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoRawScaffoldTest);
  });
}

@reflectiveTest
class NoRawScaffoldTest extends RawMaterialRuleTest {
  @override
  NoRawScaffold createRule() => NoRawScaffold();

  @override
  String get component => 'scaffold';

  @override
  List<String> get flaggedUses => ['Scaffold'];

  /// `Scaffold.of`, `Scaffold.maybeOf` and `ScaffoldMessenger` are not
  /// constructors of `Scaffold`: reading the nearest scaffold is fine.
  Future<void> test_staticLookupsAndMessengerAreNotFlagged() async {
    await assertNoDiagnostics(
      "import 'package:flutter/material.dart';\n\n"
      'void build(Object context) {\n'
      '  Scaffold.of(context);\n'
      '  Scaffold.maybeOf(context);\n'
      '  const ScaffoldMessenger();\n'
      '}\n',
    );
  }
}
