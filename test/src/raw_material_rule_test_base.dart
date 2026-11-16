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

  /// The class or function a use names: `SliverAppBar` for
  /// `SliverAppBar.medium`.
  String _named(String use) => use.split('.').first;

  /// The constructor a use calls: `new` for `AppBar`, `medium` for
  /// `SliverAppBar.medium`.
  String _constructor(String use) =>
      use.contains('.') ? use.split('.').last : 'new';

  /// Whether a use calls a function (the sheet functions), not a constructor.
  bool _isFunction(String use) => _rule.functions.contains(_named(use));

  /// Asserts [content] gets exactly one diagnostic per entry of [flagged]: on
  /// the `range` part of `line` (which appears once in [content]), naming the
  /// class or function `name`.
  Future<void> _assertFlags(
    String content,
    List<({String line, String range, String name})> flagged,
  ) async {
    int offsetOf(String line) {
      var offset = content.indexOf(line);
      expect(offset, isNonNegative, reason: line);
      expect(content.lastIndexOf(line), offset, reason: 'not unique: $line');
      return offset;
    }

    await assertDiagnostics(content, [
      for (var (:line, :range, :name) in flagged)
        lint(
          offsetOf(line) + line.indexOf(range),
          range.length,
          messageContainsAll: [
            "Raw $name in app code: use this repo's shared $component widget "
                '(see its REFERENCES.md).',
          ],
          correctionContains:
              "Only that widget's own file may use $name, with "
              '// ignore_for_file: flutter_house_lints/${rule.name}.',
        ),
    ]);
  }

  Future<void> _assertFlagsEveryUse(String library) =>
      _assertFlags(_source(flaggedUses, library: library), [
        for (var use in flaggedUses)
          (line: '  $use();', range: use, name: _named(use)),
      ]);

  Future<void> test_flagsEveryUse() =>
      _assertFlagsEveryUse('package:flutter/material.dart');

  Future<void> test_flagsEveryUseFromMaterialUi() =>
      _assertFlagsEveryUse('package:material_ui/material_ui.dart');

  /// `const`, `new` and a prefixed import (`m.AppBar()`): the underline
  /// covers the prefix and the constructor name; for a function, its name.
  Future<void> test_flagsConstNewAndPrefixedUses() {
    var flagged = [
      for (var use in flaggedUses)
        if (_isFunction(use))
          (line: '  m.$use();', range: use, name: use)
        else ...[
          (line: '  const m.$use();', range: 'm.$use', name: _named(use)),
          (line: '  new m.$use();', range: 'm.$use', name: _named(use)),
        ],
    ];
    return _assertFlags(
      "import 'package:flutter/material.dart' as m;\n\n"
      'void build() {\n${flagged.map((f) => f.line).join('\n')}\n}\n',
      flagged,
    );
  }

  /// `.new()` and `.named()` where the context type is the class, plain and
  /// `const`: the underline is the constructor name after the dot.
  Future<void> test_flagsDotShorthands() {
    var uses = flaggedUses.where((use) => !_isFunction(use));
    var flagged = [
      for (var (i, use) in uses.indexed)
        for (var (function, keyword) in [('f', ''), ('g', 'const ')])
          (
            line:
                '${_named(use)} $function$i() => '
                '$keyword.${_constructor(use)}();',
            range: _constructor(use),
            name: _named(use),
          ),
    ];
    return _assertFlags(
      "import 'package:flutter/material.dart';\n\n"
      '${flagged.map((f) => f.line).join('\n')}\n',
      flagged,
    );
  }

  void test_coversEveryClassAndFunction() {
    var covered = flaggedUses.map(_named).toSet();
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

  Future<void> test_generatedFilesAreNotFlagged() async {
    for (var suffix in [
      '.g.dart',
      '.freezed.dart',
      '.mocks.dart',
      '.gr.dart',
      '.config.dart',
    ]) {
      var file = newFile(
        '$testPackageRootPath/lib/page$suffix',
        _source(flaggedUses),
      );
      await assertNoDiagnosticsInFile(file.path);
    }
  }
}
