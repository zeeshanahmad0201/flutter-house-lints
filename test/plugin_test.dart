// Runs the real plugin through `dart analyze` on a throwaway app, the way an
// app repo loads it. Covers what the in-memory rule tests cannot: the rules
// are on by default, the namespaced ignore comment silences each one, and a
// rule switched off in the plugin's `diagnostics:` block reports nothing.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:flutter_house_lints/main.dart';
import 'package:flutter_house_lints/src/raw_material_rule.dart';
import 'package:test/test.dart';

import 'src/fake_flutter.dart';

void main() {
  late Directory tmp;
  late Directory app;

  void write(String path, String content) => File('${app.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  /// The import and declaration that make [rule] fire once. A rule with no
  /// case here fails the suite, so a new rule cannot skip these tests.
  (String, String) sample(AnalysisRule rule) => switch (rule) {
    RawMaterialRule(:var classes, :var name) => (
      "import 'package:flutter/material.dart';\n",
      'void build_$name() {\n  ${classes.first}();\n}\n',
    ),
    _ when rule.name == 'no_stateful_widget' => (
      "import 'package:flutter/widgets.dart';\n",
      'class Page extends StatefulWidget {}\n',
    ),
    _ => throw StateError('plugin_test.dart has no sample for ${rule.name}'),
  };

  String use(String className) =>
      "import 'package:flutter/material.dart';\n\n"
      'void build() {\n  $className();\n}\n';

  void writeOptions({String diagnostics = ''}) => write(
    'analysis_options.yaml',
    'plugins:\n'
        '  flutter_house_lints:\n'
        '    path: ${Directory.current.absolute.path}\n'
        '$diagnostics',
  );

  /// `(file name, rule id)` for each plugin warning `dart analyze` reports.
  Future<List<(String, String)>> analyze() async {
    var result = await Process.run(Platform.resolvedExecutable, [
      'analyze',
      '--format=machine',
    ], workingDirectory: app.path);
    var found = <(String, String)>[];
    for (var line in '${result.stdout}\n${result.stderr}'.split('\n')) {
      var fields = line.split('|');
      if (fields.length < 8) continue;
      expect(fields[0], 'WARNING', reason: line);
      found.add((fields[3].split('/').last, fields[2].toLowerCase()));
    }
    return found;
  }

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('flutter_house_lints_');
    app = Directory('${tmp.path}/app');
    write(
      '../flutter/pubspec.yaml',
      'name: flutter\nenvironment:\n  sdk: ^3.13.0\n',
    );
    write('../flutter/lib/material.dart', fakeMaterialLibrary);
    write('../flutter/lib/widgets.dart', fakeWidgetsLibrary);
    write(
      'pubspec.yaml',
      'name: app\nenvironment:\n  sdk: ^3.13.0\n'
          'dependencies:\n  flutter:\n    path: ../flutter\n',
    );
    var samples = [for (var rule in allRules) sample(rule)];
    write(
      'lib/page.dart',
      '${{for (var (imports, _) in samples) imports}.join()}\n'
          '${samples.map((s) => s.$2).join('\n')}',
    );
    for (var rule in allRules) {
      var (imports, declaration) = sample(rule);
      write(
        'lib/shared_${rule.name}.dart',
        '// ignore_for_file: flutter_house_lints/${rule.name}\n'
            '$imports\n$declaration',
      );
    }
    // The bare rule id, without the plugin namespace, does not silence it.
    write(
      'lib/bare_ignore.dart',
      '// ignore_for_file: no_raw_card\n${use('Card')}',
    );

    var pubGet = await Process.run(Platform.resolvedExecutable, [
      'pub',
      'get',
      '--offline',
    ], workingDirectory: app.path);
    expect(pubGet.exitCode, 0, reason: '${pubGet.stdout}${pubGet.stderr}');
  });

  tearDownAll(() => tmp.deleteSync(recursive: true));

  test(
    'every rule warns by default; the namespaced ignore silences it',
    () async {
      writeOptions();
      expect(
        await analyze(),
        unorderedEquals([
          for (var rule in allRules) ('page.dart', rule.name),
          ('bare_ignore.dart', 'no_raw_card'),
        ]),
      );
    },
  );

  test('a rule switched off in diagnostics reports nothing', () async {
    writeOptions(diagnostics: '    diagnostics:\n      no_raw_card: false\n');
    expect(
      await analyze(),
      unorderedEquals([
        for (var rule in allRules)
          if (rule.name != 'no_raw_card') ('page.dart', rule.name),
      ]),
    );
  });

  test('every rule can be switched off in diagnostics', () async {
    writeOptions(
      diagnostics:
          '    diagnostics:\n${allRules.map((r) => '      ${r.name}: false\n').join()}',
    );
    expect(await analyze(), isEmpty);
  });

  // The ids the plugin should ship come from the rule files, not from
  // allRules, so a rule left out of allRules fails here and in the other tests
  // is not silently skipped.
  test('allRules has every rule declared in lib/src/rules', () {
    var declared = {
      for (var file in Directory('lib/src/rules').listSync().whereType<File>())
        for (var m in RegExp(
          "name: '(no_[a-z_]+)'",
        ).allMatches(file.readAsStringSync()))
          m.group(1)!,
    };
    expect(allRules.map((r) => r.name).toSet(), declared);
    expect(declared, contains('no_stateful_widget'));
  });
}
