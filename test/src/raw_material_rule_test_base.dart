// test_reflective_loader runs methods named test_*.
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:flutter_house_lints/src/raw_material_rule.dart';
import 'package:test/test.dart';

import 'fake_flutter.dart';

/// The cases every `no_raw_*` rule must pass. A rule's test class supplies
/// the rule and every use it must flag; the `test_` methods here run for it.
abstract class RawMaterialRuleTest extends AnalysisRuleTest {
  /// The rule under test, built fresh for each test.
  RawMaterialRule createRule();

  /// The component word in the rule's correction message, e.g. 'app bar'.
  String get component;

  /// Every use the rule flags, as written in source: a class constructor
  /// (`AppBar`, `SliverAppBar.medium`) or a function name. Covers each class
  /// and function in the rule's set, plus at least one named constructor
  /// where Flutter has one.
  List<String> get flaggedUses;

  RawMaterialRule get _rule => rule as RawMaterialRule;

  @override
  void setUp() {
    rule = createRule();
    newPackage('flutter').addFile('lib/material.dart', fakeMaterialLibrary);
    newPackage('material_ui')
        .addFile('lib/material_ui.dart', fakeMaterialLibrary);
    super.setUp();
  }

  String _source(
    List<String> uses, {
    String library = 'package:flutter/material.dart',
  }) {
    var calls = uses.map((use) => '  $use();').join('\n');
    return "import '$library';\n\nvoid build() {\n$calls\n}\n";
  }

  Future<void> _assertFlagsEveryUse(String library) async {
    var content = _source(flaggedUses, library: library);
    await assertDiagnostics(content, [
      for (var use in flaggedUses)
        lint(
          content.indexOf('  $use();') + 2,
          use.length,
          messageContainsAll: [
            'Raw ${use.split('.').first} in app code: use this repo\'s shared '
                '$component widget (see its REFERENCES.md).',
          ],
          correctionContains:
              "Only that widget's own file may use ${use.split('.').first}, "
              'with // ignore_for_file: flutter_house_lints/${rule.name}.',
        ),
    ]);
  }

  Future<void> test_flagsEveryUse() =>
      _assertFlagsEveryUse('package:flutter/material.dart');

  Future<void> test_flagsEveryUseFromMaterialUi() =>
      _assertFlagsEveryUse('package:material_ui/material_ui.dart');

  void test_coversEveryClassAndFunction() {
    var covered = flaggedUses.map((use) => use.split('.').first).toSet();
    expect(covered, {..._rule.classes, ..._rule.functions});
  }

  Future<void> test_sameNamedUserClassIsNotFlagged() async {
    var names = {..._rule.classes, ..._rule.functions};
    var declarations = [
      for (var name in _rule.classes) 'class $name { $name(); }',
      for (var name in _rule.functions) 'void $name() {}',
    ].join('\n');
    var calls = names.map((name) => '  $name();').join('\n');
    await assertNoDiagnostics('$declarations\n\nvoid build() {\n$calls\n}\n');
  }

  Future<void> test_subclassIsNotFlagged() async {
    var base = _rule.classes.first;
    await assertNoDiagnostics(
      "import 'package:flutter/material.dart';\n\n"
      'class SharedWidget extends $base { SharedWidget() : super(); }\n\n'
      'void build() {\n  SharedWidget();\n}\n',
    );
  }

  Future<void> test_tearOffIsNotFlagged() async {
    var base = _rule.classes.first;
    await assertNoDiagnostics(
      "import 'package:flutter/material.dart';\n\n"
      'void build() {\n  $base.new;\n}\n',
    );
  }

  Future<void> test_testDirectoryIsNotFlagged() async {
    var file = newFile(
      '$testPackageRootPath/test/page_test.dart',
      _source(flaggedUses),
    );
    await assertNoDiagnosticsInFile(file.path);
  }

  Future<void> test_generatedFileIsNotFlagged() async {
    var file = newFile(
      '$testPackageRootPath/lib/page.g.dart',
      _source(flaggedUses),
    );
    await assertNoDiagnosticsInFile(file.path);
  }
}
