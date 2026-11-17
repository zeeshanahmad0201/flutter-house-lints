// Runs the real plugin through `dart analyze` on a throwaway app, the way an
// app repo loads it. Covers what the in-memory rule tests cannot: the rules
// are on by default, the namespaced ignore comment silences each one, and a
// rule switched off in the plugin's `diagnostics:` block reports nothing.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:flutter_house_lints/main.dart';
import 'package:flutter_house_lints/src/raw_material_rule.dart';
import 'package:test/test.dart';

import 'src/fake_flutter.dart';

void main() {
  late Directory tmp;
  late Directory app;
  var rules = allRules.whereType<RawMaterialRule>().toList();

  void write(String path, String content) => File('${app.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

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
    write(
      'pubspec.yaml',
      'name: app\nenvironment:\n  sdk: ^3.13.0\n'
          'dependencies:\n  flutter:\n    path: ../flutter\n',
    );
    write(
      'lib/page.dart',
      "import 'package:flutter/material.dart';\n\nvoid build() {\n"
          '${rules.map((r) => '  ${r.classes.first}();\n').join()}}\n',
    );
    for (var rule in rules) {
      write(
        'lib/shared_${rule.name}.dart',
        '// ignore_for_file: flutter_house_lints/${rule.name}\n'
            '${use(rule.classes.first)}',
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
          for (var rule in rules) ('page.dart', rule.name),
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
        for (var rule in rules)
          if (rule.name != 'no_raw_card') ('page.dart', rule.name),
      ]),
    );
  });
}
